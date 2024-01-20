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
    type LogEntry = StadiumTypes.LogEntry;
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

    public func initState(
        aura : MatchAura.MatchAura,
        team1 : TeamInitData,
        team2 : TeamInitData,
        team1StartOffense : Bool,
        prng : Prng,
    ) : StadiumTypes.InProgressMatch {
        let log = Buffer.Buffer<LogEntry>(10);
        logTeamOffering(team1, log);
        logTeamOffering(team2, log);
        logMatchAura(aura, log);
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
            log = Buffer.toArray(log);
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

    private func logTeamOffering(team : TeamInitData, eventLog : Buffer.Buffer<LogEntry>) {
        let offeringMetaData = Offering.getMetaData(team.offering);
        eventLog.add({
            message = "Team " # team.name # " Offering: " # offeringMetaData.description;
            isImportant = true;
        });
    };

    private func logMatchAura(aura : MatchAura.MatchAura, eventLog : Buffer.Buffer<LogEntry>) {
        let auraMetaData = MatchAura.getMetaData(aura);
        eventLog.add({
            message = "Match Aura: " # auraMetaData.description;
            isImportant = true;
        });
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

        let state : MutableState.MutableMatchState = MutableState.toMutableState(initialState);

        public func tick() : TickResult {
            if (state.round == 0) {
                ignore compiledHooks.matchStart({
                    prng = prng;
                    state = state;
                    context = ();
                });
                state.round := 1;
            };
            ignore compiledHooks.roundStart({
                prng = prng;
                state = state;
                context = ();
            });

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
            ignore compiledHooks.roundEnd({
                prng = prng;
                state = state;
                context = ();
            });
            buildTickResult(result);
        };

        private func getPlayerAtPosition(catchLocation : FieldPosition.FieldPosition) : PlayerId {
            let defensiveTeam = getDefenseTeamState();
            switch (catchLocation) {
                case (#firstBase) defensiveTeam.positions.firstBase;
                case (#secondBase) defensiveTeam.positions.secondBase;
                case (#thirdBase) defensiveTeam.positions.thirdBase;
                case (#shortStop) defensiveTeam.positions.shortStop;
                case (#pitcher) defensiveTeam.positions.pitcher;
                case (#leftField) defensiveTeam.positions.leftField;
                case (#centerField) defensiveTeam.positions.centerField;
                case (#rightField) defensiveTeam.positions.rightField;
            };
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
                positions = team.positions;
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
                            position = player.1.position;
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
            let log : [LogEntry] = Buffer.toArray(state.log);
            {
                team1 = mapMutableTeam(state.team1);
                team2 = mapMutableTeam(state.team2);
                log = log;
                currentSeed = prng.getCurrentSeed();
                offenseTeamId = state.offenseTeamId;
                aura = state.aura;
                players = players;
                bases = bases;
                round = state.round;
                outs = state.outs;
                strikes = state.strikes;
            };
        };

        private func buildCompletedMatch(reason : MatchEndReason) : Season.CompletedMatchWithoutPredictions {
            let (winner, message, error) : (Team.TeamIdOrTie, Text, ?Text) = switch (reason) {
                case (#noMoreRounds) {
                    let winner = if (state.team1.score > state.team2.score) {
                        #team1;
                    } else if (state.team1.score == state.team2.score) {
                        #tie;
                    } else {
                        #team2;
                    };
                    (winner, "Match ended due to no more rounds", null);
                };
                case (#stateBroken(e)) {
                    let error = debug_show (e); // TODO
                    (
                        #tie,
                        "Match ended due to the game being in a broken state: " # debug_show (e),
                        ?error,
                    );
                };
            };
            state.log.add({
                message = message;
                isImportant = true;
            });
            switch (winner) {
                case (#tie) state.log.add({
                    message = "The match ended in a tie!";
                    isImportant = true;
                });
                case (#team1) state.log.add({
                    message = "Team " # getTeamState(#team1).name # " wins!";
                    isImportant = true;
                });
                case (#team2) state.log.add({
                    message = "Team " # getTeamState(#team2).name # " wins!";
                    isImportant = true;
                });
            };
            let log : [LogEntry] = Buffer.toArray(state.log);

            {
                team1 = mapMutableTeam(state.team1);
                team2 = mapMutableTeam(state.team2);
                aura = state.aura;
                log = log;
                winner = winner;
                error = error;
            };
        };

        private func getNextBatter() : PlayerId {

            let playerBuffer = state.players.entries()
            // Only good condition players
            |> Iter.filter(
                _,
                func(p : (PlayerId, MutableState.MutablePlayerState)) : Bool {
                    p.1.teamId == state.offenseTeamId and getBaseOfPlayer(p.0) == null;
                },
            )
            |> Iter.map(_, func(p : (PlayerId, MutableState.MutablePlayerState)) : PlayerId = p.0)
            |> Buffer.fromIter<PlayerId>(_);

            prng.nextBufferElement(playerBuffer);
        };

        private func getPlayerState(playerId : PlayerId) : {
            #ok : MutableState.MutablePlayerState;
            #playerNotFound : PlayerId;
        } {
            let ?player = state.players.get(playerId) else return #playerNotFound(playerId);
            #ok(player);
        };

        private func getDefensePositionOfPlayer(playerId : PlayerId) : ?FieldPosition.FieldPosition {
            let defensiveTeam = getDefenseTeamState();
            if (defensiveTeam.positions.firstBase == playerId) {
                return ? #firstBase;
            };
            if (defensiveTeam.positions.secondBase == playerId) {
                return ? #secondBase;
            };
            if (defensiveTeam.positions.thirdBase == playerId) {
                return ? #thirdBase;
            };
            if (defensiveTeam.positions.shortStop == playerId) {
                return ? #shortStop;
            };
            if (defensiveTeam.positions.pitcher == playerId) {
                return ? #pitcher;
            };
            if (defensiveTeam.positions.leftField == playerId) {
                return ? #leftField;
            };
            if (defensiveTeam.positions.centerField == playerId) {
                return ? #centerField;
            };
            if (defensiveTeam.positions.rightField == playerId) {
                return ? #rightField;
            };
            null;
        };

        private func getBaseOfPlayer(playerId : PlayerId) : ?Base.Base {
            if (state.bases.firstBase == ?playerId) {
                return ? #firstBase;
            };
            if (state.bases.secondBase == ?playerId) {
                return ? #secondBase;
            };
            if (state.bases.thirdBase == ?playerId) {
                return ? #thirdBase;
            };
            if (state.bases.atBat == playerId) {
                return ? #homeBase;
            };
            null;
        };

        private func getPlayerAtBase(base : Base.Base) : {
            #ok : ?MutableState.MutablePlayerState;
            #playerNotFound : PlayerId;
        } {
            let playerId = switch (base) {
                case (#firstBase) state.bases.firstBase;
                case (#secondBase) state.bases.secondBase;
                case (#thirdBase) state.bases.thirdBase;
                case (#homeBase) ?state.bases.atBat;
            };
            switch (playerId) {
                case (null) #ok(null);
                case (?pId) switch (getPlayerState(pId)) {
                    case (#ok(p)) #ok(?p);
                    case (#playerNotFound(e)) #playerNotFound(e);
                };
            };
        };

        private func roll(
            type_ : { #d10 },
            playerId : Player.PlayerId,
            skill : Skill.Skill,
            hook : ?Hook.Hook<Hook.SkillTestContext>,
        ) : {
            #ok : Hook.SkillTestResult;
            #playerNotFound : PlayerId;
        } {
            let (min, max) = switch (type_) {
                case (#d10)(0, 10);
            };
            var roll = prng.nextNat(min, max);
            let crit = roll == max;
            if (crit) {
                // Reroll for crit value, no double crit
                roll := prng.nextNat(min, max);
            };
            let defensiveTeam = getDefenseTeamState();
            let playerState = switch (getPlayerState(defensiveTeam.positions.pitcher)) {
                case (#ok(p)) p;
                case (#playerNotFound(e)) return #playerNotFound(e);
            };
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
            #ok(postHookValue);
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
            let defensiveTeam = getDefenseTeamState();
            let pitchRollResult = roll(
                #d10,
                defensiveTeam.positions.pitcher,
                // TODO what about throwing power?
                #throwingAccuracy,
                ?compiledHooks.onPitch,
            );
            switch (pitchRollResult) {
                case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
                case (#ok(pitchRoll)) {
                    state.log.add({
                        message = "Pitch";
                        isImportant = false;
                    });
                    swing(pitchRoll);
                };
            };

        };

        private func swing(pitchRoll : Hook.SkillTestResult) : SimulationResult {
            let swingRollResult = roll(
                #d10,
                state.bases.atBat,
                #battingAccuracy,
                ?compiledHooks.onSwing,
            );
            switch (swingRollResult) {
                case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
                case (#ok(swingRoll)) {
                    let netRoll = getNetRoll(pitchRoll, swingRoll);
                    if (netRoll == 0) {
                        foul();
                    } else if (netRoll > 0) {
                        hit(Int.abs(netRoll));
                    } else {
                        strike();
                    };
                };
            };
        };

        private func foul() : SimulationResult {
            state.log.add({
                message = "Foul ball";
                isImportant = true;
            });
            #inProgress;
        };

        private func hit(hitDelta : Nat) : SimulationResult {
            state.log.add({
                message = "Its a hit!";
                isImportant = true;
            });
            let hitPowerRollResult = roll(
                #d10,
                state.bases.atBat,
                #battingPower,
                ?compiledHooks.onHit,
            );
            switch (hitPowerRollResult) {
                case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
                case (#ok(hitPowerRoll)) {
                    let defensiveTeam = getDefenseTeamState();
                    let pitchPowerRollResult = roll(
                        #d10,
                        defensiveTeam.positions.pitcher,
                        #throwingPower,
                        null,
                    );

                    switch (pitchPowerRollResult) {
                        case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
                        case (#ok(pitchPowerRoll)) {
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
                                state.log.add({
                                    message = "Homerun!";
                                    isImportant = true;
                                });
                                // hit it out of the park
                                return batterRun({
                                    fromBase = #homeBase;
                                    ballLocation = null;
                                });
                            };
                        };
                    };
                };
            };
        };

        private func tryCatchHit(location : FieldPosition.FieldPosition) : SimulationResult {
            let catchingPlayerId = getPlayerAtPosition(location);
            let catchingPlayerState = switch (getPlayerState(catchingPlayerId)) {
                case (#ok(p)) p;
                case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
            };
            let catchRollResult = roll(
                #d10,
                catchingPlayerId,
                #catching,
                ?compiledHooks.onCatch,
            );
            let catchRoll = switch (catchRollResult) {
                case (#ok(catchRoll)) catchRoll;
                case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
            };
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
                let teamId = getDefenseTeamId();
                let catchingPlayer = switch (getPlayerState(catchingPlayerId)) {
                    case (#ok(p)) p;
                    case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
                };
                state.log.add({
                    message = catchingPlayer.name # " caught the ball " # locationText # "!";
                    isImportant = true;
                });
                // Ball caught, batter is out
                out(state.bases.atBat);
            };
        };

        private func batterRun({
            ballLocation : ?FieldPosition.FieldPosition;
        }) : SimulationResult {
            let battingPlayerState = switch (getPlayerState(state.bases.atBat)) {
                case (#ok(p)) p;
                case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
            };

            let runRoll : Int = prng.nextNat(0, 10) + battingPlayerState.skills.speed;
            let runPlayerToBase = func(playerId : ?PlayerId, fromBase : Base.Base, toBase : Base.Base) : SimulationResult {
                switch (playerId) {
                    case (null) {
                        #inProgress;
                    };
                    case (?pId) {
                        playerMovedBases({ playerId = pId; fromBase; toBase });
                    };
                };
            };
            switch (ballLocation) {
                case (null) {
                    // Home run
                    let thirdBaseRun = runPlayerToBase(state.bases.secondBase, #thirdBase, #homeBase);
                    let #inProgress = thirdBaseRun else return thirdBaseRun;

                    let secondBaseRun = runPlayerToBase(state.bases.firstBase, #secondBase, #homeBase);
                    let #inProgress = secondBaseRun else return secondBaseRun;

                    let firstBaseRun = runPlayerToBase(state.bases.firstBase, #firstBase, #homeBase);
                    let #inProgress = firstBaseRun else return firstBaseRun;

                    runPlayerToBase(?state.bases.atBat, #homeBase, #homeBase);
                };
                case (?l) {
                    // TODO the other bases should be able to get out, but they just run free right now

                    let thirdBaseRun = runPlayerToBase(state.bases.secondBase, #thirdBase, #homeBase);
                    let #inProgress = thirdBaseRun else return thirdBaseRun;

                    let secondBaseRun = runPlayerToBase(state.bases.firstBase, #secondBase, #thirdBase);
                    let #inProgress = secondBaseRun else return secondBaseRun;

                    let firstBaseRun = runPlayerToBase(state.bases.firstBase, #firstBase, #secondBase);
                    let #inProgress = firstBaseRun else return firstBaseRun;

                    let playerIdWithBall = getPlayerAtPosition(l);
                    let playerStateWithBall = switch (getPlayerState(playerIdWithBall)) {
                        case (#ok(p)) p;
                        case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
                    };
                    let canPickUpInTime = prng.nextInt(0, 10) + playerStateWithBall.skills.speed;
                    if (canPickUpInTime <= 0) {
                        return #inProgress;
                    };
                    // TODO against dodge/speed skill of runner
                    let throwRoll = prng.nextInt(-10, 10) + playerStateWithBall.skills.throwingAccuracy;
                    if (throwRoll <= 0) {
                        state.log.add({
                            message = "SAFE!";
                            isImportant = true;
                        });
                        playerMovedBases({
                            playerId = state.bases.atBat;
                            fromBase = #homeBase;
                            toBase = #firstBase;
                        });
                    } else {
                        let catchingPlayer = switch (getPlayerState(playerIdWithBall)) {
                            case (#ok(p)) p;
                            case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
                        };
                        let battingPlayer = switch (getPlayerState(state.bases.atBat)) {
                            case (#ok(p)) p;
                            case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
                        };
                        state.log.add({
                            message = "Player " # catchingPlayer.name # " hit " # battingPlayer.name # "!";
                            isImportant = true;
                        });
                        let battingPlayerState = switch (getPlayerState(state.bases.atBat)) {
                            case (#ok(p)) p;
                            case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
                        };
                        let defenseRoll = prng.nextInt(-10, 10) + battingPlayerState.skills.defense;
                        let damageRoll = throwRoll - defenseRoll;
                        if (damageRoll > 5) {
                            let newInjury = switch (damageRoll) {
                                case (6) #twistedAnkle;
                                case (7) #brokenLeg;
                                case (8) #brokenArm;
                                case (_) #concussion;
                            };
                            switch (injurePlayer({ playerId = state.bases.atBat; injury = newInjury })) {
                                case (#endMatch(m)) return #endMatch(m);
                                case (#inProgress) {};
                            };
                        };
                        switch (out(state.bases.atBat)) {
                            case (#endMatch(m)) #endMatch(m);
                            case (#inProgress) #inProgress;
                        };

                    };

                };
            };

        };

        private func strike() : SimulationResult {
            state.strikes += 1;
            state.log.add({
                message = "Strike " # Nat.toText(state.strikes);
                isImportant = false;
            });
            if (state.strikes >= 3) {
                out(state.bases.atBat);
            } else {
                #inProgress;
            };
        };

        private func out(playerId : Nat32) : SimulationResult {
            state.strikes := 0;
            state.outs += 1;
            let outPlayer = switch (getPlayerState(playerId)) {
                case (#ok(p)) p;
                case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
            };
            state.log.add({
                message = "Player " # outPlayer.name # " is out";
                isImportant = true;
            });
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
            switch (toBase) {
                case (#firstBase) state.bases.firstBase := ?playerId;
                case (#secondBase) state.bases.secondBase := ?playerId;
                case (#thirdBase) state.bases.thirdBase := ?playerId;
                // TODO should this be legal?
                case (#homeBase) {
                    score({ teamId = state.offenseTeamId; amount = 1 });
                };
            };
            clearBase(fromBase);
        };

        private func endRound() : SimulationResult {
            state.strikes := 0;
            state.outs := 0;
            state.round += 1;
            state.log.add({
                message = "Round is over";
                isImportant = true;
            });
            if (state.round > 9) {
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
            var newPositionText = "Team " # getTeamState(newDefenseTeamId).name # " is now on the offensive.";
            state.log.add({
                message = newPositionText;
                isImportant = false;
            });
            #inProgress;
        };

        private func blessOrCursePlayer(playerId : PlayerId) : SimulationResult {
            if (prng.nextCoin()) {
                cursePlayer(playerId, null);
            } else {
                blessPlayer(playerId, null);
            };
        };

        private func injurePlayer({ playerId : Nat32; injury : Player.Injury }) : SimulationResult {
            let playerState = switch (getPlayerState(playerId)) {
                case (#ok(p)) p;
                case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
            };
            playerState.condition := #injured(injury);
            let injuryText = switch (injury) {
                case (#twistedAnkle) "Twisted ankle";
                case (#brokenLeg) "Broken leg";
                case (#brokenArm) "Broken arm";
                case (#concussion) "Concussion";
            };
            let player = switch (getPlayerState(playerId)) {
                case (#ok(p)) p;
                case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
            };
            state.log.add({
                message = "Player " # player.name # " is injured: " # injuryText;
                isImportant = true;
            });
            #inProgress;
        };

        private func cursePlayer(playerId : Nat32, curseOrRandom : ?Curse.Curse) : SimulationResult {
            let playerState = switch (getPlayerState(playerId)) {
                case (#ok(p)) p;
                case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
            };
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
            let (curseText, result) = switch (curse) {
                case (#skill(s)) {
                    MutableState.modifyPlayerSkill(playerState.skills, s, -1); // TODO value
                    ("Decreased skill: " # debug_show (s), #inProgress);
                };
                case (#injury(i)) {
                    let result = injurePlayer({
                        playerId = playerId;
                        injury = i;
                    });
                    ("Injury: " # debug_show (i), result);
                };
            };
            let player = switch (getPlayerState(playerId)) {
                case (#ok(p)) p;
                case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
            };
            state.log.add({
                message = "Player " # player.name # " is cursed with : " # curseText;
                isImportant = true;
            });
            result;
        };

        private func blessPlayer(playerId : Nat32, blessingOrRandom : ?Blessing.Blessing) : SimulationResult {
            let playerState = switch (getPlayerState(playerId)) {
                case (#ok(p)) p;
                case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
            };
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
            let blessingText = switch (blessing) {
                case (#skill(s)) {
                    MutableState.modifyPlayerSkill(playerState.skills, s, 1); // TODO value
                    "Increased skill: " # debug_show (s);
                };
            };
            let player = switch (getPlayerState(playerId)) {
                case (#ok(p)) p;
                case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
            };
            state.log.add({
                message = "Player " # player.name # " is blessed with : " # blessingText;
                isImportant = true;
            });
            #inProgress;
        };

        private func score({ teamId : Team.TeamId; amount : Int }) {
            let team = getTeamState(teamId);
            team.score += amount;
            state.log.add({
                message = "Team " # getTeamState(teamId).name # " scored " # Int.toText(amount) # " points!";
                isImportant = true;
            });
        };

        private func removePlayerFromBase(playerId : PlayerId) : SimulationResult {
            let ?position = getBaseOfPlayer(playerId) else return #endMatch(#stateBroken(#playerExpectedOnField({ id = playerId; onOffense = false; description = "Player not on base, cannot remove from field" })));
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
                    let nextBatter = switch (getPlayerState(nextBatterId)) {
                        case (#ok(p)) p;
                        case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
                    };
                    state.log.add({
                        message = "Player " # nextBatter.name # " is up to bat";
                        isImportant = true;
                    });
                };
            };
            #inProgress;
        };

        private func getOffenseTeamState() : MutableState.MutableTeamState {
            switch (state.offenseTeamId) {
                case (#team1) state.team1;
                case (#team2) state.team2;
            };
        };

        private func getDefenseTeamState() : MutableState.MutableTeamState {
            switch (state.offenseTeamId) {
                case (#team1) state.team2;
                case (#team2) state.team1;
            };
        };

        private func getDefenseTeamId() : Team.TeamId {
            switch (state.offenseTeamId) {
                case (#team1) #team2;
                case (#team2) #team1;
            };
        };

        private func getTeamState(teamId : Team.TeamId) : MutableState.MutableTeamState {
            switch (teamId) {
                case (#team1) state.team1;
                case (#team2) state.team2;
            };
        };

    };
};
