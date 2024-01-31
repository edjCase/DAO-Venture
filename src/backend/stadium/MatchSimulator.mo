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
import Offering "../models/Offering";
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

module {

    type PlayerId = Player.PlayerId;
    type MatchAura = MatchAura.MatchAura;
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type TickResult = {
        #inProgress : StadiumTypes.InProgressMatch;
        #completed : Season.CompletedMatchWithoutPredictions;
    };

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
        offering : Offering.Offering;
        positions : {
            firstBase : Player.TeamPlayerWithId;
            secondBase : Player.TeamPlayerWithId;
            thirdBase : Player.TeamPlayerWithId;
            shortStop : Player.TeamPlayerWithId;
            pitcher : Player.TeamPlayerWithId;
            leftField : Player.TeamPlayerWithId;
            centerField : Player.TeamPlayerWithId;
            rightField : Player.TeamPlayerWithId;
        };
    };

    public type MutablePlayerMatchStats = {
        offenseStats : {
            var atBats : Nat;
            var hits : Nat;
            var runs : Nat;
            var runsBattedIn : Nat;
            var strikeouts : Nat;
        };
        defenseStats : {
            var catches : Nat;
            var missedCatches : Nat;
            var outs : Nat;
            var assists : Nat;
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

        let mapPlayer = func(player : Player.TeamPlayerWithId) : StadiumTypes.PlayerStateWithId = {
            id = player.id;
            name = player.name;
            teamId = teamId;
            condition = #ok;
            skills = player.skills;
            position = player.position;
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
            offering = team.offering;
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

    private func buildPlayerState(player : Player.TeamPlayerWithId, teamId : Team.TeamId) : StadiumTypes.PlayerStateWithId {
        {
            id = player.id;
            name = player.name;
            teamId = teamId;
            condition = #ok;
            skills = player.skills;
            position = player.position;
        };
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

    public func tick(match : StadiumTypes.InProgressMatch, random : Prng) : TickResult {
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

        public func tick() : TickResult {
            state.startTurn();
            if (state.log.rounds.size() < 1) {
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

        private func buildTickResult(result : SimulationResult) : TickResult {

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
                offering = team.offering;
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
                                piety = player.1.skills.piety;
                                speed = player.1.skills.speed;
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
            let log : Season.MatchLog = fromMutableLog(state.log);
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

        private func buildCompletedMatch(reason : MatchEndReason) : Season.CompletedMatchWithoutPredictions {
            let (winner, matchEndReason) : (Team.TeamIdOrTie, Season.MatchEndReason) = switch (reason) {
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
                case (#stateBroken(e))(#tie, #error(debug_show (e))); // TODO error format
            };
            state.addEvent(#matchEnd({ reason = matchEndReason }));
            let log : Season.MatchLog = fromMutableLog(state.log);

            let playerStats = buildPlayerStats();

            {
                team1 = mapMutableTeam(state.team1);
                team2 = mapMutableTeam(state.team2);
                aura = state.aura;
                log = log;
                winner = winner;
                playerStats = playerStats;
            };
        };

        private func fromMutableLog(log : MutableState.MutableMatchLog) : Season.MatchLog {
            {
                rounds = log.rounds.vals()
                |> Iter.map(_, fromMutableRoundLog)
                |> Iter.toArray(_);
            };
        };

        private func fromMutableRoundLog(log : MutableState.MutableRoundLog) : Season.RoundLog {
            {
                turns = log.turns.vals()
                |> Iter.map(_, fromMutableTurns)
                |> Iter.toArray(_);
            };
        };

        private func fromMutableTurns(log : MutableState.MutableTurnLog) : Season.TurnLog {
            {
                events = Buffer.toArray(log.events);
            };
        };

        private func buildPlayerStats() : [Season.PlayerMatchStats] {
            let playerStats : TrieMap.TrieMap<Player.PlayerId, MutablePlayerMatchStats> = state.players.vals()
            |> Iter.map<MutableState.MutablePlayerStateWithId, (Player.PlayerId, MutablePlayerMatchStats)>(
                _,
                func(player : MutableState.MutablePlayerStateWithId) : (Player.PlayerId, MutablePlayerMatchStats) {
                    let stats : MutablePlayerMatchStats = {
                        offenseStats = {
                            var atBats = 0;
                            var hits = 0;
                            var runs = 0;
                            var runsBattedIn = 0;
                            var strikeouts = 0;
                        };
                        defenseStats = {
                            var catches = 0;
                            var missedCatches = 0;
                            var outs = 0;
                            var assists = 0;
                        };
                    };
                    (player.id, stats);
                },
            )
            |> TrieMap.fromEntries<Player.PlayerId, MutablePlayerMatchStats>(_, Nat32.equal, func(i : Nat32) : Nat32 = i);

            playerStats.entries()
            |> Iter.map(
                _,
                func(e : (Player.PlayerId, MutablePlayerMatchStats)) : Season.PlayerMatchStats {
                    {
                        playerId = e.0;
                        offenseStats = {
                            atBats = e.1.offenseStats.atBats;
                            hits = e.1.offenseStats.hits;
                            runs = e.1.offenseStats.runs;
                            runsBattedIn = e.1.offenseStats.runsBattedIn;
                            strikeouts = e.1.offenseStats.strikeouts;
                        };
                        defenseStats = {
                            catches = e.1.defenseStats.catches;
                            missedCatches = e.1.defenseStats.missedCatches;
                            outs = e.1.defenseStats.outs;
                            assists = e.1.defenseStats.assists;
                        };
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
                case (#d10)(0, 10);
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
                        var piety = playerState.skills.piety - 1;
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
                        var piety = 0;
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

        private func pitch() : SimulationResult {
            let defensiveTeam = state.getDefenseTeamState();
            let pitchRoll = roll(
                #d10,
                defensiveTeam.positions.pitcher,
                // TODO what about throwing power?
                #throwingAccuracy,
                ?compiledHooks.onPitch,
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
                #hit;
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
                case (#hit) {
                    hit(Int.abs(netRoll));
                };
                case (#strike) {
                    strike();
                };
            };
        };

        private func hit(hitDelta : Nat) : SimulationResult {
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
            if (netRoll < 0) {
                // bases
                let location = switch (prng.nextInt(0, 4)) {
                    case (0) #firstBase;
                    case (1) #secondBase;
                    case (2) #thirdBase;
                    case (3) #shortStop;
                    case (4) #pitcher;
                    case (_) Prelude.unreachable();
                };
                tryCatchHit(location);
            } else if (netRoll < 10) {
                // outfield
                let location = switch (prng.nextInt(0, 2)) {
                    case (0) #leftField;
                    case (1) #centerField;
                    case (2) #rightField;
                    case (_) Prelude.unreachable();
                };
                tryCatchHit(location);
            } else {
                // homerun
                // TODO
                // state.addEvent({
                //     message = "Homerun!";
                //     isImportant = true;
                // });
                // hit it out of the park
                return batterRun({
                    fromBase = #homeBase;
                    ballLocation = null;
                });
            };
        };

        private func tryCatchHit(location : FieldPosition.FieldPosition) : SimulationResult {
            let catchingPlayerId = state.getPlayerAtDefensivePosition(location);
            let catchingPlayerState = state.getPlayerState(catchingPlayerId);
            let catchRoll = roll(
                #d10,
                catchingPlayerId,
                #catching,
                ?compiledHooks.onCatch,
            );
            let ballRoll = { crit = false; value = 5 }; // TODO how to handle difficulty?
            let netCatchRoll = getNetRoll(ballRoll, catchRoll);
            if (netCatchRoll <= 0) {
                batterRun({
                    fromBase = #homeBase;
                    ballLocation = ?location;
                });
            } else {
                let locationText = switch (location) {
                    case (#firstBase) "at first base";
                    case (#secondBase) "at second base";
                    case (#thirdBase) "at third base";
                    case (#shortStop) "at short stop";
                    case (#pitcher) "at the pitching mound";
                    case (#leftField) "in left field";
                    case (#centerField) "in center field";
                    case (#rightField) "in right field";
                };
                let teamId = state.getDefenseTeamId();
                let catchingPlayer = state.getPlayerState(catchingPlayerId);
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

        private func batterRun({
            ballLocation : ?FieldPosition.FieldPosition;
        }) : SimulationResult {
            // Pick a runner on base to try to hit out
            let targetToHit = switch (state.bases.thirdBase) {
                case (null) {
                    // If no one is on third base, pick from 2nd, 1st, or batter
                    let targets = Buffer.Buffer<Player.PlayerId>(3);
                    targets.add(state.bases.atBat);
                    switch (state.bases.firstBase) {
                        case (null)();
                        case (?firstBaseRunner) targets.add(firstBaseRunner);
                    };
                    switch (state.bases.secondBase) {
                        case (null)();
                        case (?secondBaseRunner) targets.add(secondBaseRunner);
                    };
                    if (targets.size() == 1) {
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
            switch (ballLocation) {
                case (null) {
                    // Home run
                    // 3rd -> home
                    let thirdBaseRun = runPlayerOrNot(state.bases.secondBase, #thirdBase, #homeBase);
                    let #inProgress = thirdBaseRun else return thirdBaseRun;

                    // 2nd -> Home
                    let secondBaseRun = runPlayerOrNot(state.bases.firstBase, #secondBase, #homeBase);
                    let #inProgress = secondBaseRun else return secondBaseRun;

                    // 1st -> Home
                    let firstBaseRun = runPlayerOrNot(state.bases.firstBase, #firstBase, #homeBase);
                    let #inProgress = firstBaseRun else return firstBaseRun;

                    // Batter -> Home
                    playerMovedBases({
                        playerId = state.bases.atBat;
                        fromBase = #homeBase;
                        toBase = #firstBase;
                    });
                };
                case (?l) {

                    let playerIdWithBall = state.getPlayerAtDefensivePosition(l);
                    let pickUpRoll = roll(
                        #d10,
                        playerIdWithBall,
                        #speed,
                        null, // TODO Hook here
                    );
                    let canPickUpInTime = getNetRoll(pickUpRoll, runRoll) >= 0;

                    if (canPickUpInTime) {
                        let throwRoll = roll(
                            #d10,
                            playerIdWithBall,
                            #throwingAccuracy,
                            null, // TODO Hook here
                        );
                        let netThrowRoll = getNetRoll(throwRoll, runRoll);
                        if (netThrowRoll >= 0) {
                            // Runner is hit by the ball
                            state.addEvent(
                                #hitByBall({
                                    playerId = targetToHit;
                                    throwingPlayerId = playerIdWithBall;
                                })
                            );

                            let defenseRoll = roll(
                                #d10,
                                targetToHit,
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
                                    playerId = targetToHit;
                                    injury = newInjury;
                                });
                            };
                            // out will handle removing the player from base
                            switch (out(targetToHit, #hitByBall)) {
                                case (#endMatch(m)) return #endMatch(m);
                                case (#inProgress)();
                            };
                        };
                    };

                    // Shift everyone by one base
                    // 3rd -> home
                    let thirdBaseRun = runPlayerOrNot(state.bases.thirdBase, #thirdBase, #homeBase);
                    let #inProgress = thirdBaseRun else return thirdBaseRun;

                    // 2nd -> 3rd
                    let secondBaseRun = runPlayerOrNot(state.bases.secondBase, #secondBase, #thirdBase);
                    let #inProgress = secondBaseRun else return secondBaseRun;

                    // 1st -> 2nd
                    let firstBaseRun = runPlayerOrNot(state.bases.firstBase, #firstBase, #secondBase);
                    let #inProgress = firstBaseRun else return firstBaseRun;

                    // batter -> 1st
                    playerMovedBases({
                        playerId = state.bases.atBat;
                        fromBase = #homeBase;
                        toBase = #firstBase;
                    });

                };
            };

        };

        private func runPlayerOrNot(playerId : ?PlayerId, fromBase : Base.Base, toBase : Base.Base) : SimulationResult {
            switch (playerId) {
                case (null) {
                    #inProgress;
                };
                case (?pId) {
                    playerMovedBases({ playerId = pId; fromBase; toBase });
                };
            };
        };

        private func strike() : SimulationResult {
            state.strikes += 1;
            if (state.strikes >= 3) {
                out(state.bases.atBat, #strikeout);
            } else {
                #inProgress;
            };
        };

        private func out(playerId : Nat32, reason : Season.OutReason) : SimulationResult {
            state.strikes := 0;
            state.outs += 1;
            let outPlayer = state.getPlayerState(playerId);
            state.addEvent(
                #out({
                    playerId = playerId;
                    reason = reason;
                })
            );
            if (state.outs >= 3) {
                return endRound();
            };
            removePlayerFromBase(playerId);
        };

        private func playerMovedBases({
            fromBase : Base.Base;
            toBase : Base.Base;
            playerId : PlayerId;
        }) : SimulationResult {

            state.addEvent(
                #safeAtBase({
                    playerId = state.bases.atBat;
                    base = #firstBase;
                })
            );
            switch (toBase) {
                case (#firstBase) state.bases.firstBase := ?playerId;
                case (#secondBase) state.bases.secondBase := ?playerId;
                case (#thirdBase) state.bases.thirdBase := ?playerId;
                case (#homeBase) {
                    score({ teamId = state.offenseTeamId; amount = 1 });
                };
            };
            clearBase(fromBase);
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
                case (#team1)(#team2, #team1);
                case (#team2)(#team1, #team2);
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
                #newRound({
                    offenseTeamId = newOffenseTeamId;
                    atBatPlayerId = atBat;
                })
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
                    let curseRoll = prng.nextNat(0, 11);
                    switch (curseRoll) {
                        case (0) #skill(#battingPower);
                        case (1) #skill(#battingAccuracy);
                        case (2) #skill(#throwingPower);
                        case (3) #skill(#throwingAccuracy);
                        case (4) #skill(#catching);
                        case (5) #skill(#defense);
                        case (6) #skill(#piety);
                        case (7) #skill(#speed);
                        case (8) #injury(#twistedAnkle);
                        case (9) #injury(#brokenLeg);
                        case (10) #injury(#brokenArm);
                        case (11) #injury(#concussion);
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
                    let blessingRoll = prng.nextNat(0, 7);
                    switch (blessingRoll) {
                        case (0) #skill(#battingPower);
                        case (1) #skill(#battingAccuracy);
                        case (2) #skill(#throwingPower);
                        case (3) #skill(#throwingAccuracy);
                        case (4) #skill(#catching);
                        case (5) #skill(#defense);
                        case (6) #skill(#piety);
                        case (7) #skill(#speed);
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
                    state.bases.atBat := nextBatterId;
                    state.addEvent(#newBatter({ playerId = nextBatterId }));
                };
            };
            #inProgress;
        };

    };
};
