import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Trie "mo:base/Trie";
import Nat32 "mo:base/Nat32";
import StadiumTypes "../stadium/Types";
import Player "../models/Player";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Debug "mo:base/Debug";
import Random "mo:base/Random";
import Int "mo:base/Int";
import Int32 "mo:base/Int32";
import Prelude "mo:base/Prelude";
import Nat8 "mo:base/Nat8";
import Iter "mo:base/Iter";
import TrieMap "mo:base/TrieMap";
import Float "mo:base/Float";
import Text "mo:base/Text";
import Order "mo:base/Order";
import RandomX "mo:random/RandomX";
import PseudoRandomX "mo:random/PseudoRandomX";
import StadiumUtil "StadiumUtil";
import IterTools "mo:itertools/Iter";
import MatchAura "../models/MatchAura";
import Base "../models/Base";
import Curse "../models/Curse";
import Blessing "../models/Blessing";
import Team "../models/Team";
import FieldPosition "../models/FieldPosition";
import Skill "../models/Skill";
import Hook "../models/Hook";
import MutableState "../models/MutableState";
import HookCompiler "HookCompiler";
import Season "../models/Season";
import Scenario "../models/Scenario";
import LeagueTypes "../league/Types";

module {

    type PlayerId = Player.PlayerId;
    type MatchAura = MatchAura.MatchAura;
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    type SimulationResult = {
        #endMatch : MatchEndReason;
        #inProgress;
    };

    type MatchEndReason = {
        #noMoreRounds;
        #stateBroken : StadiumTypes.BrokenStateError;
    };

    public type TeamInitData = {
        id : Principal;
        name : Text;
        logoUrl : Text;
        scenario : Scenario.InstanceWithChoice;
        positions : {
            firstBase : Player.PlayerWithId;
            secondBase : Player.PlayerWithId;
            thirdBase : Player.PlayerWithId;
            shortStop : Player.PlayerWithId;
            pitcher : Player.PlayerWithId;
            leftField : Player.PlayerWithId;
            centerField : Player.PlayerWithId;
            rightField : Player.PlayerWithId;
        };
    };

    public func initState(
        aura : MatchAura.MatchAura,
        team1 : TeamInitData,
        team2 : TeamInitData,
        team1StartOffense : Bool,
        prng : Prng,
    ) : StadiumTypes.InProgressMatch {
        let (team1State, team1Players) = buildTeamState(team1, #team1, prng);
        let (team2State, team2Players) = buildTeamState(team2, #team2, prng);
        let (offensePlayers, defensePlayers) = if (team1StartOffense) {
            (team1Players, team2Players);
        } else {
            (team2Players, team1Players);
        };
        let randomIndex = prng.nextNat(0, offensePlayers.size() - 1);
        let atBatPlayer = offensePlayers.get(randomIndex);

        let players = Buffer.merge(
            team1Players,
            team2Players,
            func(
                p1 : StadiumTypes.PlayerStateWithId,
                p2 : StadiumTypes.PlayerStateWithId,
            ) : Order.Order = Nat32.compare(p1.id, p2.id),
        );
        {
            offenseTeamId = if (team1StartOffense) #team1 else #team2;
            team1 = team1State;
            team2 = team2State;
            aura = aura;
            log = {
                rounds = [];
            };
            players = Buffer.toArray(players);
            bases = {
                atBat = atBatPlayer.id;
                firstBase = null;
                secondBase = null;
                thirdBase = null;
            };
            round = 0;
            outs = 0;
            strikes = 0;
        };
    };

    private func buildTeamState(
        team : TeamInitData,
        teamId : Team.TeamId,
        prng : Prng,
    ) : (StadiumTypes.TeamState, Buffer.Buffer<StadiumTypes.PlayerStateWithId>) {

        let mapPlayer = func(player : Player.PlayerWithId) : StadiumTypes.PlayerStateWithId = {
            id = player.id;
            name = player.name;
            teamId = teamId;
            condition = #ok;
            skills = player.skills;
            position = player.position;
            matchStats = {
                battingStats = {
                    atBats = 0;
                    hits = 0;
                    runs = 0;
                    strikeouts = 0;
                    homeRuns = 0;
                };
                catchingStats = {
                    successfulCatches = 0;
                    missedCatches = 0;
                    throws = 0;
                    throwOuts = 0;
                };
                pitchingStats = {
                    pitches = 0;
                    strikes = 0;
                    hits = 0;
                    runs = 0;
                    strikeouts = 0;
                    homeRuns = 0;
                };
                injuries = 0;
            };
        };
        let playerStates = Buffer.Buffer<StadiumTypes.PlayerStateWithId>(8);
        playerStates.add(mapPlayer(team.positions.pitcher));
        playerStates.add(mapPlayer(team.positions.firstBase));
        playerStates.add(mapPlayer(team.positions.secondBase));
        playerStates.add(mapPlayer(team.positions.thirdBase));
        playerStates.add(mapPlayer(team.positions.shortStop));
        playerStates.add(mapPlayer(team.positions.leftField));
        playerStates.add(mapPlayer(team.positions.centerField));
        playerStates.add(mapPlayer(team.positions.rightField));

        let teamState : StadiumTypes.TeamState = {
            id = team.id;
            name = team.name;
            logoUrl = team.logoUrl;
            score = 0;
            scenario = team.scenario;
            positions = {
                pitcher = team.positions.pitcher.id;
                firstBase = team.positions.firstBase.id;
                secondBase = team.positions.secondBase.id;
                thirdBase = team.positions.thirdBase.id;
                shortStop = team.positions.shortStop.id;
                leftField = team.positions.leftField.id;
                centerField = team.positions.centerField.id;
                rightField = team.positions.rightField.id;
            };
        };
        (teamState, playerStates);
    };

    private func normalizeVotes(votes : Trie.Trie<MatchAura, Nat>) : Trie.Trie<MatchAura, Float> {
        var totalVotes = 0;
        for ((id, voteCount) in Trie.iter(votes)) {
            totalVotes += voteCount;
        };
        if (totalVotes == 0) {
            return Trie.empty();
        };
        Trie.mapFilter<MatchAura, Nat, Float>(
            votes,
            func(voteCount : (MatchAura, Nat)) : ?Float = ?(Float.fromInt(voteCount.1) / Float.fromInt(totalVotes)),
        );
    };

    public func tick(match : StadiumTypes.InProgressMatch, random : Prng) : StadiumTypes.TickResult {
        let compiledHooks = HookCompiler.compile(match);
        let simulation = MatchSimulation(match, random, compiledHooks);
        simulation.tick();
    };

    class MatchSimulation(
        initialState : StadiumTypes.InProgressMatch,
        prng : Prng,
        compiledHooks : Hook.CompiledHooks,
    ) {

        let state : MutableState.MutableMatchState = MutableState.MutableMatchState(initialState);

        public func tick() : StadiumTypes.TickResult {
            state.startTurn();
            if (state.log.rounds.size() < 1) {
                // Need to log first batter, others handled when batter switches
                updateStats(
                    state.bases.atBat,
                    func(stats : MutableState.MutablePlayerMatchStats) {
                        stats.battingStats.atBats += 1;
                    },
                );
                ignore compiledHooks.matchStart({
                    prng = prng;
                    state = state;
                    context = ();
                });
            };

            // TODO divine intervention
            // let roll = Hook.trigger(state, #divineInterventionRoll);
            // let divineInterventionRoll = prng.nextNat(0, 999);
            // let result = if (divineInterventionRoll <= 9) {
            //     state.log.add({
            //         message = "Divine intervention!";
            //         isImportant = true;
            //     });
            //     let ?randomPlayerId = getRandomAvailablePlayer(null, null, false) else Prelude.unreachable();
            //     blessOrCursePlayer(randomPlayerId);
            // } else {
            let result = pitch();
            // };

            buildTickResult(result);
        };

        private func buildTickResult(result : SimulationResult) : StadiumTypes.TickResult {

            switch (result) {
                case (#inProgress) #inProgress(buildLiveMatch());
                case (#endMatch(reason)) #completed(buildCompletedMatch(reason));
            };
        };

        private func mapMutableTeam(team : MutableState.MutableTeamState) : StadiumTypes.TeamState {
            {
                id = team.id;
                name = team.name;
                logoUrl = team.logoUrl;
                score = team.score;
                scenario = team.scenario;
                positions = {
                    pitcher = team.positions.pitcher;
                    firstBase = team.positions.firstBase;
                    secondBase = team.positions.secondBase;
                    thirdBase = team.positions.thirdBase;
                    shortStop = team.positions.shortStop;
                    leftField = team.positions.leftField;
                    centerField = team.positions.centerField;
                    rightField = team.positions.rightField;
                };
            };
        };

        private func buildLiveMatch() : StadiumTypes.InProgressMatch {

            let players = Iter.toArray(
                Iter.map(
                    state.players.entries(),
                    func(player : (Nat32, MutableState.MutablePlayerState)) : StadiumTypes.PlayerStateWithId {
                        {
                            id = player.0;
                            name = player.1.name;
                            teamId = player.1.teamId;
                            condition = player.1.condition;
                            skills = {
                                battingPower = player.1.skills.battingPower;
                                battingAccuracy = player.1.skills.battingAccuracy;
                                throwingPower = player.1.skills.throwingPower;
                                throwingAccuracy = player.1.skills.throwingAccuracy;
                                catching = player.1.skills.catching;
                                defense = player.1.skills.defense;
                                speed = player.1.skills.speed;
                            };
                            matchStats = {
                                battingStats = {
                                    atBats = player.1.matchStats.battingStats.atBats;
                                    hits = player.1.matchStats.battingStats.hits;
                                    runs = player.1.matchStats.battingStats.runs;
                                    strikeouts = player.1.matchStats.battingStats.strikeouts;
                                    homeRuns = player.1.matchStats.battingStats.homeRuns;
                                };
                                catchingStats = {
                                    successfulCatches = player.1.matchStats.catchingStats.successfulCatches;
                                    missedCatches = player.1.matchStats.catchingStats.missedCatches;
                                    throws = player.1.matchStats.catchingStats.throws;
                                    throwOuts = player.1.matchStats.catchingStats.throwOuts;

                                };
                                pitchingStats = {
                                    pitches = player.1.matchStats.pitchingStats.pitches;
                                    strikes = player.1.matchStats.pitchingStats.strikes;
                                    hits = player.1.matchStats.pitchingStats.hits;
                                    runs = player.1.matchStats.pitchingStats.runs;
                                    strikeouts = player.1.matchStats.pitchingStats.strikeouts;
                                    homeRuns = player.1.matchStats.pitchingStats.homeRuns;
                                };
                                injuries = player.1.matchStats.injuries;
                            };
                        };
                    },
                )
            );

            let bases = {
                atBat = state.bases.atBat;
                firstBase = state.bases.firstBase;
                secondBase = state.bases.secondBase;
                thirdBase = state.bases.thirdBase;
            };
            let log : StadiumTypes.MatchLog = fromMutableLog(state.log);
            {
                team1 = mapMutableTeam(state.team1);
                team2 = mapMutableTeam(state.team2);
                log = log;
                currentSeed = prng.getCurrentSeed();
                offenseTeamId = state.offenseTeamId;
                aura = state.aura;
                players = players;
                bases = bases;
                outs = state.outs;
                strikes = state.strikes;
            };
        };

        private func buildCompletedMatch(reason : MatchEndReason) : StadiumTypes.CompletedTickResult {
            let (winner, matchEndReason) : (Team.TeamIdOrTie, StadiumTypes.MatchEndReason) = switch (reason) {
                case (#noMoreRounds) {
                    let winner = if (state.team1.score > state.team2.score) {
                        #team1;
                    } else if (state.team1.score == state.team2.score) {
                        #tie;
                    } else {
                        #team2;
                    };
                    (winner, #noMoreRounds);
                };
                case (#stateBroken(e)) (#tie, #error(debug_show (e))); // TODO error format
            };
            state.addEvent(#matchEnd({ reason = matchEndReason }));
            let log : StadiumTypes.MatchLog = fromMutableLog(state.log);

            let playerStats = buildPlayerStats();

            {
                match = {
                    team1 = mapMutableTeam(state.team1);
                    team2 = mapMutableTeam(state.team2);
                    aura = state.aura;
                    log = log;
                    winner = winner;
                    playerStats = playerStats;
                };
                matchStats = playerStats;
            };
        };

        private func fromMutableLog(log : MutableState.MutableMatchLog) : StadiumTypes.MatchLog {
            {
                rounds = log.rounds.vals()
                |> Iter.map(_, fromMutableRoundLog)
                |> Iter.toArray(_);
            };
        };

        private func fromMutableRoundLog(log : MutableState.MutableRoundLog) : StadiumTypes.RoundLog {
            {
                turns = log.turns.vals()
                |> Iter.map(_, fromMutableTurns)
                |> Iter.toArray(_);
            };
        };

        private func fromMutableTurns(log : MutableState.MutableTurnLog) : StadiumTypes.TurnLog {
            {
                events = Buffer.toArray(log.events);
            };
        };

        private func buildPlayerStats() : [Player.PlayerMatchStatsWithId] {
            state.players.vals()
            |> Iter.map(
                _,
                func(player : MutableState.MutablePlayerStateWithId) : Player.PlayerMatchStatsWithId {
                    {
                        playerId = player.id;
                        battingStats = {
                            atBats = player.matchStats.battingStats.atBats;
                            hits = player.matchStats.battingStats.hits;
                            runs = player.matchStats.battingStats.runs;
                            strikeouts = player.matchStats.battingStats.strikeouts;
                            homeRuns = player.matchStats.battingStats.homeRuns;
                        };
                        catchingStats = {
                            successfulCatches = player.matchStats.catchingStats.successfulCatches;
                            missedCatches = player.matchStats.catchingStats.missedCatches;
                            throws = player.matchStats.catchingStats.throws;
                            throwOuts = player.matchStats.catchingStats.throwOuts;
                        };
                        pitchingStats = {
                            pitches = player.matchStats.pitchingStats.pitches;
                            strikes = player.matchStats.pitchingStats.strikes;
                            hits = player.matchStats.pitchingStats.hits;
                            runs = player.matchStats.pitchingStats.runs;
                            strikeouts = player.matchStats.pitchingStats.strikeouts;
                            homeRuns = player.matchStats.pitchingStats.homeRuns;
                        };
                        injuries = player.matchStats.injuries;
                    };
                },
            )
            |> Iter.toArray(_);
        };

        private func getNextBatter() : PlayerId {

            let playerBuffer = state.players.entries()
            // Only players on offense and not on base
            |> Iter.filter(
                _,
                func(p : (PlayerId, MutableState.MutablePlayerState)) : Bool {
                    p.1.teamId == state.offenseTeamId and state.getOffensivePositionOfPlayer(p.0) == null;
                },
            )
            |> Iter.map(_, func(p : (PlayerId, MutableState.MutablePlayerState)) : PlayerId = p.0)
            |> Buffer.fromIter<PlayerId>(_);

            if (playerBuffer.size() <= 0) {
                Debug.trap("No players available to bat for team: " # debug_show (state.offenseTeamId));
            };

            prng.nextBufferElement(playerBuffer);
        };

        private func roll(
            type_ : { #d10 },
            playerId : Player.PlayerId,
            skill : Skill.Skill,
            hook : ?Hook.Hook<Hook.SkillTestContext>,
        ) : Hook.SkillTestResult {
            let (min, max) = switch (type_) {
                case (#d10) (0, 10);
            };
            var roll = prng.nextNat(min, max);
            let crit = roll == max;
            if (crit) {
                // Reroll for crit value, no double crit
                roll := prng.nextNat(min, max);
            };
            let defensiveTeam = state.getDefenseTeamState();
            let playerState = state.getPlayerState(defensiveTeam.positions.pitcher);
            let playerSkills : MutableState.MutablePlayerSkills = switch (playerState.condition) {
                case (#ok) playerState.skills;
                case (#injured(_)) {
                    // TODO different values for different injuries
                    {
                        var battingPower = playerState.skills.battingPower - 1;
                        var battingAccuracy = playerState.skills.battingAccuracy - 1;
                        var throwingPower = playerState.skills.throwingPower - 1;
                        var throwingAccuracy = playerState.skills.throwingAccuracy - 1;
                        var catching = playerState.skills.catching - 1;
                        var defense = playerState.skills.defense - 1;
                        var speed = playerState.skills.speed - 1;
                    };
                };
                case (#dead) {
                    // TODO 'placeholder construct' skills
                    {
                        var battingPower = 0;
                        var battingAccuracy = 0;
                        var throwingPower = 0;
                        var throwingAccuracy = 0;
                        var catching = 0;
                        var defense = 0;
                        var speed = 0;
                    };
                };
            };
            let modifier = MutableState.getPlayerSkill(playerSkills, skill);
            let modifiedRoll = roll + modifier;
            let postHookValue = switch (hook) {
                case (null) { { value = modifiedRoll; crit = crit } };
                case (?h) {
                    let result = h({
                        prng = prng;
                        state = state;
                        context = {
                            result = { value = modifiedRoll; crit = crit };
                            playerId = playerId;
                            skill = skill;
                        };
                    });
                    result.updatedContext.result;
                };
            };
            postHookValue;
        };

        private func getNetRoll(leftRoll : Hook.SkillTestResult, rightRoll : Hook.SkillTestResult) : Int {
            switch ((leftRoll.crit, rightRoll.crit)) {
                case ((false, false) or (true, true)) {
                    // If both crit or normal, find the delta
                    leftRoll.value - rightRoll.value;
                };
                case ((true, false)) {
                    // Left crit trumps right value
                    leftRoll.value;
                };
                case ((false, true)) {
                    // Right crit trumps left value
                    rightRoll.value;
                };
            };
        };

        private func updateStats(playerId : PlayerId, update : (MutableState.MutablePlayerMatchStats) -> ()) {
            let playerState = state.getPlayerState(playerId);
            update(playerState.matchStats);
        };

        private func pitch() : SimulationResult {
            let defensiveTeam = state.getDefenseTeamState();
            let pitchRoll = roll(
                #d10,
                defensiveTeam.positions.pitcher,
                // TODO what about throwing power?
                #throwingAccuracy,
                ?compiledHooks.onPitch,
            );
            updateStats(
                defensiveTeam.positions.pitcher,
                func(stats : MutableState.MutablePlayerMatchStats) {
                    stats.pitchingStats.pitches += 1;
                },
            );
            state.addEvent(#pitch({ pitcherId = defensiveTeam.positions.pitcher; roll = pitchRoll }));
            swing(pitchRoll);
        };

        private func swing(pitchRoll : Hook.SkillTestResult) : SimulationResult {
            let swingRoll = roll(
                #d10,
                state.bases.atBat,
                #battingAccuracy,
                ?compiledHooks.onSwing,
            );
            let netRoll = getNetRoll(pitchRoll, swingRoll);
            let swingOutcome = if (netRoll == 0) {
                #foul;
            } else if (netRoll > 0) {
                let hitLocation = getHitLocation();
                #hit(hitLocation);
            } else {
                #strike;
            };
            state.addEvent(
                #swing({
                    playerId = state.bases.atBat;
                    roll = swingRoll;
                    pitchRoll = pitchRoll;
                    outcome = swingOutcome;
                })
            );
            switch (swingOutcome) {
                case (#foul) {
                    #inProgress; // TODO?
                };
                case (#hit(location)) {
                    let position = switch (location) {
                        case (#stands) return homeRun();
                        case (#firstBase) #firstBase;
                        case (#secondBase) #secondBase;
                        case (#thirdBase) #thirdBase;
                        case (#shortStop) #shortStop;
                        case (#pitcher) #pitcher;
                        case (#leftField) #leftField;
                        case (#centerField) #centerField;
                        case (#rightField) #rightField;
                    };
                    catchBall(position);
                };
                case (#strike) {
                    strike();
                };
            };
        };

        private func getHitLocation() : StadiumTypes.HitLocation {
            let hitPowerRoll = roll(
                #d10,
                state.bases.atBat,
                #battingPower,
                ?compiledHooks.onHit,
            );
            let defensiveTeam = state.getDefenseTeamState();
            let pitchPowerRoll = roll(
                #d10,
                defensiveTeam.positions.pitcher,
                #throwingPower,
                null,
            );
            let netRoll = getNetRoll(pitchPowerRoll, hitPowerRoll);
            let hitLocation = if (netRoll < 0) {
                // bases
                switch (prng.nextInt(0, 4)) {
                    case (0) #firstBase;
                    case (1) #secondBase;
                    case (2) #thirdBase;
                    case (3) #shortStop;
                    case (4) #pitcher;
                    case (_) Prelude.unreachable();
                };
            } else if (netRoll < 8) {
                // outfield
                switch (prng.nextInt(0, 2)) {
                    case (0) #leftField;
                    case (1) #centerField;
                    case (2) #rightField;
                    case (_) Prelude.unreachable();
                };
            } else {
                // homerun
                #stands;
            };
        };

        private func catchBall(position : FieldPosition.FieldPosition) : SimulationResult {
            let catchingPlayerId = state.getPlayerAtDefensivePosition(position);
            let catchingPlayerState = state.getPlayerState(catchingPlayerId);
            let catchRoll = roll(
                #d10,
                catchingPlayerId,
                #catching,
                ?compiledHooks.onCatch,
            );
            let ballRoll = { crit = false; value = 7 }; // TODO how to handle difficulty?
            let netCatchRoll = getNetRoll(catchRoll, ballRoll);
            if (netCatchRoll <= 0) {

                updateStats(
                    catchingPlayerId,
                    func(stats : MutableState.MutablePlayerMatchStats) {
                        stats.catchingStats.missedCatches += 1;
                    },
                );
                run(position);
            } else {
                let teamId = state.getDefenseTeamId();
                let catchingPlayer = state.getPlayerState(catchingPlayerId);

                updateStats(
                    catchingPlayerId,
                    func(stats : MutableState.MutablePlayerMatchStats) {
                        stats.catchingStats.successfulCatches += 1;
                    },
                );
                state.addEvent(
                    #catch_({
                        playerId = catchingPlayerId;
                        roll = catchRoll;
                        difficulty = ballRoll;
                    })
                );
                // Ball caught, batter is out
                out(state.bases.atBat, #ballCaught);
            };
        };

        private func run(positionWithBall : FieldPosition.FieldPosition) : SimulationResult {
            // Pick a runner on base to try to hit out
            let targetToHit = switch (state.bases.thirdBase) {
                case (null) {
                    // If no one is on third base, pick from 2nd, 1st, or batter
                    let targets = Buffer.Buffer<Player.PlayerId>(3);
                    targets.add(state.bases.atBat);
                    switch (state.bases.firstBase) {
                        case (null) ();
                        case (?firstBaseRunner) targets.add(firstBaseRunner);
                    };
                    switch (state.bases.secondBase) {
                        case (null) ();
                        case (?secondBaseRunner) targets.add(secondBaseRunner);
                    };
                    if (targets.size() <= 1) {
                        // Only one option, no need to roll
                        targets.get(0);
                    } else {
                        // Roll to pick a target
                        let chanceRoll = prng.nextNat(0, targets.size() - 1);
                        targets.get(chanceRoll);
                    };
                };
                case (?thirdBaseRunner) {
                    // If someone is on third base, running home, try to get them out
                    thirdBaseRunner;
                };
            };
            let runRoll = roll(
                #d10,
                targetToHit,
                #speed,
                null, // TODO Hook here
            );
            hitTargetWithBall(targetToHit, runRoll, positionWithBall);
        };

        private func hitTargetWithBall(
            target : Player.PlayerId,
            targetRunRoll : Hook.SkillTestResult,
            positionWithBall : FieldPosition.FieldPosition,
        ) : SimulationResult {
            let playerIdWithBall = state.getPlayerAtDefensivePosition(positionWithBall);
            let pickUpRoll = roll(
                #d10,
                playerIdWithBall,
                #speed,
                null, // TODO Hook here
            );
            let canPickUpInTime = getNetRoll(pickUpRoll, targetRunRoll) >= 0;

            if (canPickUpInTime) {
                let throwRoll = roll(
                    #d10,
                    playerIdWithBall,
                    #throwingAccuracy,
                    null, // TODO Hook here
                );

                updateStats(
                    playerIdWithBall,
                    func(stats : MutableState.MutablePlayerMatchStats) {
                        stats.catchingStats.throws += 1;
                    },
                );
                let netThrowRoll = getNetRoll(throwRoll, targetRunRoll);
                if (netThrowRoll >= 0) {
                    // Runner is hit by the ball
                    updateStats(
                        playerIdWithBall,
                        func(stats : MutableState.MutablePlayerMatchStats) {
                            stats.catchingStats.throwOuts += 1;
                        },
                    );
                    state.addEvent(
                        #throw_({
                            to = target;
                            from = playerIdWithBall;
                        })
                    );

                    let defenseRoll = roll(
                        #d10,
                        target,
                        #defense,
                        null, // TODO Hook here
                    );
                    let damageRoll = getNetRoll({ crit = false; value = netThrowRoll }, defenseRoll);
                    if (damageRoll > 10) {
                        let newInjury = switch (damageRoll) {
                            case (6) #twistedAnkle;
                            case (7) #brokenLeg;
                            case (8) #brokenArm;
                            case (_) #concussion;
                        };
                        injurePlayer({
                            playerId = target;
                            injury = newInjury;
                        });
                        updateStats(
                            target,
                            func(stats : MutableState.MutablePlayerMatchStats) {
                                stats.injuries += 1;
                            },
                        );
                    };
                    // out will handle removing the player from base
                    switch (out(target, #hitByBall)) {
                        case (#endMatch(m)) return #endMatch(m);
                        case (#inProgress) ();
                    };
                };
            } else {
                updateStats(
                    state.bases.atBat,
                    func(stats : MutableState.MutablePlayerMatchStats) {
                        stats.battingStats.hits += 1;
                    },
                );
                let defenseTeam = state.getDefenseTeamState();
                updateStats(
                    defenseTeam.positions.pitcher,
                    func(stats : MutableState.MutablePlayerMatchStats) {
                        stats.pitchingStats.hits += 1;
                    },
                );
            };

            // Shift the rest of the runners by one base
            single();
        };

        private func single() : SimulationResult {
            // Shift everyone by one base
            // 3rd -> home
            let thirdBaseRun = moveBaseToBase({
                from = #thirdBase;
                to = #homeBase;
            });
            let #inProgress = thirdBaseRun else return thirdBaseRun; // Short circuit if end match

            // 2nd -> 3rd
            let secondBaseRun = moveBaseToBase({
                from = #secondBase;
                to = #thirdBase;
            });
            let #inProgress = secondBaseRun else return secondBaseRun; // Short circuit if end match

            // 1st -> 2nd
            let firstBaseRun = moveBaseToBase({
                from = #firstBase;
                to = #secondBase;
            });
            let #inProgress = firstBaseRun else return firstBaseRun; // Short circuit if end match

            // batter -> 1st
            moveBaseToBase({
                from = #homeBase;
                to = #firstBase;
            });
        };

        private func homeRun() : SimulationResult {
            updateStats(
                state.bases.atBat,
                func(stats : MutableState.MutablePlayerMatchStats) {
                    stats.battingStats.homeRuns += 1;
                },
            );

            let defenseTeam = state.getDefenseTeamState();
            updateStats(
                defenseTeam.positions.pitcher,
                func(stats : MutableState.MutablePlayerMatchStats) {
                    stats.pitchingStats.homeRuns += 1;
                },
            );
            // Home run
            // 3rd -> home
            let thirdBaseRun = moveBaseToBase({
                from = #thirdBase;
                to = #homeBase;
            });
            let #inProgress = thirdBaseRun else return thirdBaseRun;

            // 2nd -> Home
            let secondBaseRun = moveBaseToBase({
                from = #secondBase;
                to = #homeBase;
            });
            let #inProgress = secondBaseRun else return secondBaseRun;

            // 1st -> Home
            let firstBaseRun = moveBaseToBase({
                from = #firstBase;
                to = #homeBase;
            });
            let #inProgress = firstBaseRun else return firstBaseRun;

            // Batter -> Home
            moveBaseToBase({
                from = #homeBase;
                to = #firstBase;
            });
        };

        private func strike() : SimulationResult {
            let defenseTeam = state.getDefenseTeamState();
            updateStats(
                defenseTeam.positions.pitcher,
                func(stats : MutableState.MutablePlayerMatchStats) {
                    stats.pitchingStats.strikes += 1;
                },
            );
            state.strikes += 1;
            if (state.strikes >= 3) {
                out(state.bases.atBat, #strikeout);
            } else {
                #inProgress;
            };
        };

        private func out(playerId : Nat32, reason : StadiumTypes.OutReason) : SimulationResult {
            state.strikes := 0;
            state.outs += 1;
            let outPlayer = state.getPlayerState(playerId);
            state.addEvent(
                #out({
                    playerId = playerId;
                    reason = reason;
                })
            );
            switch (reason) {
                case (#hitByBall) {};
                case (#ballCaught) {};
                case (#strikeout) {
                    updateStats(
                        playerId,
                        func(stats : MutableState.MutablePlayerMatchStats) {
                            stats.battingStats.strikeouts += 1;
                        },
                    );
                    let defenseTeam = state.getDefenseTeamState();
                    updateStats(
                        defenseTeam.positions.pitcher,
                        func(stats : MutableState.MutablePlayerMatchStats) {
                            stats.pitchingStats.strikeouts += 1;
                        },
                    );
                };
            };
            if (state.outs >= 3) {
                return endRound();
            };
            removePlayerFromBase(playerId);
        };

        private func moveBaseToBase({
            from : Base.Base;
            to : Base.Base;
        }) : SimulationResult {
            let ?player = state.getPlayerAtBase(from) else return #inProgress; // no player to move, skip

            state.addEvent(
                #safeAtBase({
                    playerId = player.id;
                    base = #firstBase;
                })
            );
            switch (to) {
                case (#firstBase) state.bases.firstBase := ?player.id;
                case (#secondBase) state.bases.secondBase := ?player.id;
                case (#thirdBase) state.bases.thirdBase := ?player.id;
                case (#homeBase) {
                    score({ teamId = state.offenseTeamId; amount = 1 });
                    let ?scoringPlayer = state.getPlayerAtBase(from) else Debug.trap("Expected player at base: " # debug_show (from));
                    updateStats(
                        scoringPlayer.id,
                        func(stats : MutableState.MutablePlayerMatchStats) {
                            stats.battingStats.runs += 1;
                        },
                    );

                    let defenseTeam = state.getDefenseTeamState();
                    updateStats(
                        defenseTeam.positions.pitcher,
                        func(stats : MutableState.MutablePlayerMatchStats) {
                            stats.pitchingStats.runs += 1;
                        },
                    );
                };
            };
            clearBase(from);
        };

        private func endRound() : SimulationResult {
            state.strikes := 0;
            state.outs := 0;

            ignore compiledHooks.roundEnd({
                prng = prng;
                state = state;
                context = ();
            });
            state.endRound();
            if (state.log.rounds.size() >= 18) {
                ignore compiledHooks.matchEnd({
                    prng = prng;
                    state = state;
                    context = ();
                });
                // End match if no more rounds
                return #endMatch(#noMoreRounds);
            };
            let (newOffenseTeamId, newDefenseTeamId) = switch (state.offenseTeamId) {
                case (#team1) (#team2, #team1);
                case (#team2) (#team1, #team2);
            };
            state.offenseTeamId := newOffenseTeamId;

            let atBat = getNextBatter();

            state.bases := {
                var atBat = atBat;
                var firstBase = null;
                var secondBase = null;
                var thirdBase = null;
            };
            state.addEvent(
                #teamSwap({
                    offenseTeamId = newOffenseTeamId;
                    atBatPlayerId = atBat;
                })
            );
            updateStats(
                atBat,
                func(stats : MutableState.MutablePlayerMatchStats) {
                    stats.battingStats.atBats += 1;
                },
            );

            ignore compiledHooks.roundStart({
                prng = prng;
                state = state;
                context = ();
            });
            #inProgress;
        };

        private func blessOrCursePlayer(playerId : PlayerId) {
            if (prng.nextCoin()) {
                cursePlayer(playerId, null);
            } else {
                blessPlayer(playerId, null);
            };
        };

        private func injurePlayer({ playerId : Nat32; injury : Player.Injury }) {
            let playerState = state.getPlayerState(playerId);
            playerState.condition := #injured(injury);
            let injuryText = switch (injury) {
                case (#twistedAnkle) "Twisted ankle";
                case (#brokenLeg) "Broken leg";
                case (#brokenArm) "Broken arm";
                case (#concussion) "Concussion";
            };
            state.addEvent(
                #injury({
                    playerId = playerId;
                    injury = injury;
                })
            );
        };

        private func cursePlayer(playerId : Nat32, curseOrRandom : ?Curse.Curse) {
            let playerState = state.getPlayerState(playerId);
            let curse = switch (curseOrRandom) {
                case (null) {
                    let curseRoll = prng.nextNat(0, 10);
                    switch (curseRoll) {
                        case (0) #skill(#battingPower);
                        case (1) #skill(#battingAccuracy);
                        case (2) #skill(#throwingPower);
                        case (3) #skill(#throwingAccuracy);
                        case (4) #skill(#catching);
                        case (5) #skill(#defense);
                        case (6) #skill(#speed);
                        case (7) #injury(#twistedAnkle);
                        case (8) #injury(#brokenLeg);
                        case (9) #injury(#brokenArm);
                        case (10) #injury(#concussion);
                        case (_) Prelude.unreachable();
                    };
                };
                case (?c) c;
            };
            state.addEvent(
                #curse({
                    playerId = playerId;
                    curse = curse;
                })
            );
            switch (curse) {
                case (#skill(s)) {
                    MutableState.modifyPlayerSkill(playerState.skills, s, -1); // TODO value
                };
                case (#injury(i)) {
                    injurePlayer({
                        playerId = playerId;
                        injury = i;
                    });
                };
            };
        };

        private func blessPlayer(playerId : Nat32, blessingOrRandom : ?Blessing.Blessing) {
            let playerState = state.getPlayerState(playerId);
            let blessing = switch (blessingOrRandom) {
                case (null) {
                    let blessingRoll = prng.nextNat(0, 6);
                    switch (blessingRoll) {
                        case (0) #skill(#battingPower);
                        case (1) #skill(#battingAccuracy);
                        case (2) #skill(#throwingPower);
                        case (3) #skill(#throwingAccuracy);
                        case (4) #skill(#catching);
                        case (5) #skill(#defense);
                        case (6) #skill(#speed);
                        case (_) Prelude.unreachable();
                    };
                };
                case (?c) c;
            };
            state.addEvent(
                #blessing({
                    playerId = playerId;
                    blessing = blessing;
                })
            );
            switch (blessing) {
                case (#skill(s)) {
                    MutableState.modifyPlayerSkill(playerState.skills, s, 1); // TODO value
                };
            };
        };

        private func score({ teamId : Team.TeamId; amount : Int }) {
            let team = state.getTeamState(teamId);
            team.score += amount;
            state.addEvent(#score({ teamId = teamId; amount = amount }));
        };

        private func removePlayerFromBase(playerId : PlayerId) : SimulationResult {
            let ?position = state.getOffensivePositionOfPlayer(playerId) else return #endMatch(#stateBroken(#playerExpectedOnField({ id = playerId; onOffense = false; description = "Player not on base, cannot remove from field" })));
            clearBase(position);
        };

        private func clearBase(base : Base.Base) : SimulationResult {
            switch (base) {
                case (#firstBase) state.bases.firstBase := null;
                case (#secondBase) state.bases.secondBase := null;
                case (#thirdBase) state.bases.thirdBase := null;
                case (#homeBase) {
                    let nextBatterId = getNextBatter();

                    updateStats(
                        nextBatterId,
                        func(stats : MutableState.MutablePlayerMatchStats) {
                            stats.battingStats.atBats += 1;
                        },
                    );
                    state.bases.atBat := nextBatterId;
                    state.addEvent(#newBatter({ playerId = nextBatterId }));
                };
            };
            #inProgress;
        };

    };
};
