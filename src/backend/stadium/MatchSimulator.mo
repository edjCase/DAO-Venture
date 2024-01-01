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

module {

    type PlayerId = Player.PlayerId;
    type LogEntry = StadiumTypes.LogEntry;
    type MatchAura = MatchAura.MatchAura;
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type TickResult = {
        #inProgress : StadiumTypes.InProgressMatch;
        #completed : StadiumTypes.CompletedMatch;
    };

    type SimulationResult = {
        #endMatch : MatchEndReason;
        #inProgress;
    };

    type MatchEndReason = {
        #noMoreRounds;
        #outOfPlayers : Team.TeamIdOrBoth;
        #stateBroken : StadiumTypes.BrokenStateError;
    };

    public type TeamInitData = {
        id : Principal;
        name : Text;
        logoUrl : Text;
        offering : Offering.Offering;
        championId : PlayerId;
        players : [Player.PlayerWithId];
    };

    public func initState(
        aura : MatchAura.MatchAura,
        team1 : TeamInitData,
        team2 : TeamInitData,
        team1StartOffense : Bool,
        prng : Prng,
    ) : {
        #ok : StadiumTypes.InProgressMatch;
        #notEnoughPlayers : Team.TeamIdOrBoth;
    } {
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
        let ?offense = buildStartingOffense(offensePlayers, prng) else return #notEnoughPlayers(#team1);
        let ?defense = buildStartingDefense(defensePlayers, prng) else return #notEnoughPlayers(#team2);

        let players = Buffer.merge(
            team1Players,
            team2Players,
            func(
                p1 : StadiumTypes.PlayerStateWithId,
                p2 : StadiumTypes.PlayerStateWithId,
            ) : Order.Order = Nat32.compare(p1.id, p2.id),
        );
        #ok({
            offenseTeamId = if (team1StartOffense) #team1 else #team2;
            team1 = team1State;
            team2 = team2State;
            aura = aura;
            log = Buffer.toArray(log);
            players = Buffer.toArray(players);
            batter = null;
            field = {
                offense = offense;
                defense = defense;
            };
            round = 0;
            outs = 0;
            strikes = 0;
        });
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

        var playerStates = team.players
        |> Iter.fromArray(_)
        |> Iter.map(
            _,
            func(player : Player.PlayerWithId) : StadiumTypes.PlayerStateWithId = {
                id = player.id;
                name = player.name;
                teamId = teamId;
                condition = #ok;
                skills = player.skills;
                position = player.position;
            },
        )
        |> Buffer.fromIter<StadiumTypes.PlayerStateWithId>(_);

        var score = 0;
        let teamState : StadiumTypes.TeamState = {
            id = team.id;
            name = team.name;
            logoUrl = team.logoUrl;
            score = score;
            offering = team.offering;
            championId = team.championId;
        };
        (teamState, playerStates);
    };

    private func buildPlayerState(player : Player.PlayerWithId, teamId : Team.TeamId) : StadiumTypes.PlayerStateWithId {
        {
            id = player.id;
            name = player.name;
            teamId = teamId;
            condition = #ok;
            skills = player.skills;
            position = player.position;
        };
    };

    private func buildStartingOffense(players : Buffer.Buffer<StadiumTypes.PlayerStateWithId>, prng : Prng) : ?StadiumTypes.OffenseFieldState {
        if (players.size() < 1) {
            return null;
        };
        let randomIndex = prng.nextNat(0, players.size() - 1);
        let atBatPlayer = players.get(randomIndex);
        ?{
            atBat = atBatPlayer.id;
            firstBase = null;
            secondBase = null;
            thirdBase = null;
        };
    };

    private func buildStartingDefense(players : Buffer.Buffer<StadiumTypes.PlayerStateWithId>, prng : Prng) : ?StadiumTypes.DefenseFieldState {
        let getRandomPlayer = func(position : FieldPosition.FieldPosition) : ?PlayerId {
            let playersWithPosition = Buffer.mapFilter<StadiumTypes.PlayerStateWithId, StadiumTypes.PlayerStateWithId>(
                players,
                func(p : StadiumTypes.PlayerStateWithId) : ?StadiumTypes.PlayerStateWithId {
                    if (p.position != position) null else ?p;
                },
            );
            if (playersWithPosition.size() < 1) {
                return null;
            };
            let index = prng.nextNat(0, playersWithPosition.size() - 1);
            ?playersWithPosition.get(index).id;
        };

        do ? {
            {
                firstBase = getRandomPlayer(#firstBase)!;
                secondBase = getRandomPlayer(#secondBase)!;
                thirdBase = getRandomPlayer(#thirdBase)!;
                shortStop = getRandomPlayer(#shortStop)!;
                pitcher = getRandomPlayer(#pitcher)!;
                leftField = getRandomPlayer(#leftField)!;
                centerField = getRandomPlayer(#centerField)!;
                rightField = getRandomPlayer(#rightField)!;
            };
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
            switch (catchLocation) {
                case (#firstBase) state.field.defense.firstBase;
                case (#secondBase) state.field.defense.secondBase;
                case (#thirdBase) state.field.defense.thirdBase;
                case (#shortStop) state.field.defense.shortStop;
                case (#pitcher) state.field.defense.pitcher;
                case (#leftField) state.field.defense.leftField;
                case (#centerField) state.field.defense.centerField;
                case (#rightField) state.field.defense.rightField;
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
                championId = team.championId;
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

            let field = {
                offense = {
                    atBat = state.field.offense.atBat;
                    firstBase = state.field.offense.firstBase;
                    secondBase = state.field.offense.secondBase;
                    thirdBase = state.field.offense.thirdBase;
                };
                defense = {
                    firstBase = state.field.defense.firstBase;
                    secondBase = state.field.defense.secondBase;
                    thirdBase = state.field.defense.thirdBase;
                    shortStop = state.field.defense.shortStop;
                    pitcher = state.field.defense.pitcher;
                    leftField = state.field.defense.leftField;
                    centerField = state.field.defense.centerField;
                    rightField = state.field.defense.rightField;
                };
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
                field = field;
                round = state.round;
                outs = state.outs;
                strikes = state.strikes;
            };
        };

        private func buildCompletedMatch(reason : MatchEndReason) : StadiumTypes.CompletedMatch {
            let (winner, message) = switch (reason) {
                case (#noMoreRounds) {
                    let winner = if (state.team1.score > state.team2.score) {
                        #team1;
                    } else if (state.team1.score == state.team2.score) {
                        #tie;
                    } else {
                        #team2;
                    };
                    (winner, "Match ended due to no more rounds");
                };
                case (#outOfPlayers(teamId)) {
                    switch (teamId) {
                        case (#bothTeams) {
                            (#tie, "Match ended due to both teams running out of players");
                        };
                        case (#team1) {
                            (#team1, "Match ended due to team '" # getTeamState(#team1).name # "' running out of players");
                        };
                        case (#team2) {
                            (#team2, "Match ended due to team '" # getTeamState(#team2).name # "' running out of players");
                        };
                    };
                };
                case (#stateBroken(e)) {
                    (#tie, "Match ended due to the game being in a broken state: " # debug_show (e));
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
            let result : StadiumTypes.CompletedMatchResult = switch (reason) {
                case (#noMoreRounds or #outOfPlayers(_)) {
                    #played({
                        team1 = {
                            score = state.team1.score;
                            offering = state.team1.offering;
                            championId = state.team1.championId;
                        };
                        team2 = {
                            score = state.team2.score;
                            offering = state.team2.offering;
                            championId = state.team2.championId;
                        };
                        winner = winner;
                    });
                };
                case (#stateBroken(error)) #stateBroken(error);
            };
            {
                team1 = mapMutableTeam(state.team1);
                team2 = mapMutableTeam(state.team2);
                log = log;
                result = result;
            };
        };

        private func getRandomAvailablePlayer(teamId : ?Team.TeamId, position : ?FieldPosition.FieldPosition, notOnField : Bool) : ?PlayerId {
            // get random player
            let availablePlayers = getAvailablePlayers(teamId, position, notOnField);
            if (availablePlayers.size() < 1) {
                return null;
            };
            let randomIndex = prng.nextNat(0, availablePlayers.size() - 1);
            ?availablePlayers.get(randomIndex);

        };

        private func getAvailablePlayers(
            teamId : ?Team.TeamId,
            position : ?FieldPosition.FieldPosition,
            notOnField : Bool,
        ) : Buffer.Buffer<PlayerId> {

            var playersIter : Iter.Iter<(PlayerId, MutableState.MutablePlayerState)> = state.players.entries()
            // Only good condition players
            |> Iter.filter(_, func(p : (PlayerId, MutableState.MutablePlayerState)) : Bool = p.1.condition == #ok);
            if (notOnField) {
                // Only players not on the field
                playersIter := Iter.filter(
                    playersIter,
                    func(p : (PlayerId, MutableState.MutablePlayerState)) : Bool {
                        getDefensePositionOfPlayer(p.0) == null and getBaseOfPlayer(p.0) == null;
                    },
                );
            };

            switch (teamId) {
                case (null) {};
                case (?t) {
                    // Only players on the specified team
                    playersIter := Iter.filter(playersIter, func(p : (PlayerId, MutableState.MutablePlayerState)) : Bool = p.1.teamId == t);
                };
            };
            switch (position) {
                case (null) {};
                case (?po) {
                    // Only players assigned to a certain position
                    playersIter := Iter.filter(playersIter, func(p : (PlayerId, MutableState.MutablePlayerState)) : Bool = p.1.position == po);
                };
            };
            playersIter
            |> Iter.map(_, func(p : (PlayerId, MutableState.MutablePlayerState)) : PlayerId = p.0)
            |> Buffer.fromIter(_);
        };

        private func getPlayerState(playerId : PlayerId) : {
            #ok : MutableState.MutablePlayerState;
            #playerNotFound : StadiumTypes.PlayerNotFoundError;
        } {
            let ?player = state.players.get(playerId) else return #playerNotFound({
                id = playerId;
                teamId = null;
            });
            #ok(player);
        };

        private func getDefensePositionOfPlayer(playerId : PlayerId) : ?FieldPosition.FieldPosition {
            if (state.field.defense.firstBase == playerId) {
                return ? #firstBase;
            };
            if (state.field.defense.secondBase == playerId) {
                return ? #secondBase;
            };
            if (state.field.defense.thirdBase == playerId) {
                return ? #thirdBase;
            };
            if (state.field.defense.shortStop == playerId) {
                return ? #shortStop;
            };
            if (state.field.defense.pitcher == playerId) {
                return ? #pitcher;
            };
            if (state.field.defense.leftField == playerId) {
                return ? #leftField;
            };
            if (state.field.defense.centerField == playerId) {
                return ? #centerField;
            };
            if (state.field.defense.rightField == playerId) {
                return ? #rightField;
            };
            null;
        };

        private func getBaseOfPlayer(playerId : PlayerId) : ?Base.Base {
            if (state.field.offense.firstBase == ?playerId) {
                return ? #firstBase;
            };
            if (state.field.offense.secondBase == ?playerId) {
                return ? #secondBase;
            };
            if (state.field.offense.thirdBase == ?playerId) {
                return ? #thirdBase;
            };
            if (state.field.offense.atBat == playerId) {
                return ? #homeBase;
            };
            null;
        };

        private func getPlayerAtBase(base : Base.Base) : {
            #ok : ?MutableState.MutablePlayerState;
            #playerNotFound : StadiumTypes.PlayerNotFoundError;
        } {
            let playerId = switch (base) {
                case (#firstBase) state.field.offense.firstBase;
                case (#secondBase) state.field.offense.secondBase;
                case (#thirdBase) state.field.offense.thirdBase;
                case (#homeBase) ?state.field.offense.atBat;
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
            #playerNotFound : StadiumTypes.PlayerNotFoundError;
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
            let pitcherState = switch (getPlayerState(state.field.defense.pitcher)) {
                case (#ok(p)) p;
                case (#playerNotFound(e)) return #playerNotFound(e);
            };
            let modifier = MutableState.getPlayerSkill(pitcherState.skills, skill);
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
            let pitchRollResult = roll(
                #d10,
                state.field.defense.pitcher,
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
                state.field.offense.atBat,
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
                state.field.offense.atBat,
                #battingPower,
                ?compiledHooks.onHit,
            );
            switch (hitPowerRollResult) {
                case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
                case (#ok(hitPowerRoll)) {
                    let pitchPowerRollResult = roll(
                        #d10,
                        state.field.defense.pitcher,
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
                out(state.field.offense.atBat);
            };
        };

        private func batterRun({
            ballLocation : ?FieldPosition.FieldPosition;
        }) : SimulationResult {
            let battingPlayerState = switch (getPlayerState(state.field.offense.atBat)) {
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
                    let thirdBaseRun = runPlayerToBase(state.field.offense.secondBase, #thirdBase, #homeBase);
                    let #inProgress = thirdBaseRun else return thirdBaseRun;

                    let secondBaseRun = runPlayerToBase(state.field.offense.firstBase, #secondBase, #homeBase);
                    let #inProgress = secondBaseRun else return secondBaseRun;

                    let firstBaseRun = runPlayerToBase(state.field.offense.firstBase, #firstBase, #homeBase);
                    let #inProgress = firstBaseRun else return firstBaseRun;

                    runPlayerToBase(?state.field.offense.atBat, #homeBase, #homeBase);
                };
                case (?l) {
                    // TODO the other bases should be able to get out, but they just run free right now

                    let thirdBaseRun = runPlayerToBase(state.field.offense.secondBase, #thirdBase, #homeBase);
                    let #inProgress = thirdBaseRun else return thirdBaseRun;

                    let secondBaseRun = runPlayerToBase(state.field.offense.firstBase, #secondBase, #thirdBase);
                    let #inProgress = secondBaseRun else return secondBaseRun;

                    let firstBaseRun = runPlayerToBase(state.field.offense.firstBase, #firstBase, #secondBase);
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
                            playerId = state.field.offense.atBat;
                            fromBase = #homeBase;
                            toBase = #firstBase;
                        });
                    } else {
                        let catchingPlayer = switch (getPlayerState(playerIdWithBall)) {
                            case (#ok(p)) p;
                            case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
                        };
                        let battingPlayer = switch (getPlayerState(state.field.offense.atBat)) {
                            case (#ok(p)) p;
                            case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
                        };
                        state.log.add({
                            message = "Player " # catchingPlayer.name # " hit " # battingPlayer.name # "!";
                            isImportant = true;
                        });
                        let battingPlayerState = switch (getPlayerState(state.field.offense.atBat)) {
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
                            switch (injurePlayer({ playerId = state.field.offense.atBat; injury = newInjury })) {
                                case (#endMatch(m)) return #endMatch(m);
                                case (#inProgress) {};
                            };
                        };
                        switch (out(state.field.offense.atBat)) {
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
                out(state.field.offense.atBat);
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
                case (#firstBase) state.field.offense.firstBase := ?playerId;
                case (#secondBase) state.field.offense.secondBase := ?playerId;
                case (#thirdBase) state.field.offense.thirdBase := ?playerId;
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
            let newDefense = buildNewDefense(newDefenseTeamId);
            let newOffense = buildNewOffense(newOffenseTeamId);
            switch ((newDefense, newOffense)) {
                case (null, null) return #endMatch(#outOfPlayers(#bothTeams));
                case (?d, null) return #endMatch(#outOfPlayers(newOffenseTeamId));
                case (null, ?o) return #endMatch(#outOfPlayers(newDefenseTeamId));
                case (?d, ?o) {
                    state.field.defense := d;
                    state.field.offense := o;
                };
            };
            let newState = [
                ("1st Base", state.field.defense.firstBase),
                ("2nd Base", state.field.defense.secondBase),
                ("3rd Base", state.field.defense.thirdBase),
                ("Short Stop", state.field.defense.shortStop),
                ("Pitcher", state.field.defense.pitcher),
                ("Left Field", state.field.defense.leftField),
                ("Center Field", state.field.defense.centerField),
                ("Right Field", state.field.defense.rightField),
            ];
            var newPositionText = "Team " # getTeamState(newDefenseTeamId).name # " is now on the field.\nNew positions -";
            for ((name, playerId) in Iter.fromArray(newState)) {
                let player = switch (getPlayerState(playerId)) {
                    case (#ok(p)) p;
                    case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
                };
                newPositionText := newPositionText # "\n" # name # ": " # player.name;
            };
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
            if (getDefensePositionOfPlayer(playerId) != null) {
                // Swap if on field, base swap handled by batterRun
                substitutePlayer({ playerId = playerId });
            } else {
                #inProgress;
            };
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

        private func substitutePlayer({ playerId : Nat32 }) : SimulationResult {
            let playerOutState = switch (getPlayerState(playerId)) {
                case (#ok(p)) p;
                case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
            };
            let team = switch (playerOutState.teamId) {
                case (#team1) state.team1;
                case (#team2) state.team2;
            };
            let ?fieldPosition = getDefensePositionOfPlayer(playerId) else return #endMatch(#stateBroken(#playerExpectedOnField({ id = playerId; onOffense = true; description = "Player not on field, cannot substitute" })));

            var availablePlayers = getAvailablePlayers(?playerOutState.teamId, ?fieldPosition, true);
            if (availablePlayers.size() < 1) {
                return #endMatch(#outOfPlayers(playerOutState.teamId));
            };
            // Get random from available players
            let randomIndex = prng.nextNat(0, availablePlayers.size() - 1);
            let subPlayerId = availablePlayers.get(randomIndex);
            let subPlayer = switch (getPlayerState(subPlayerId)) {
                case (#ok(p)) p;
                case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
            };
            let playerOut = switch (getPlayerState(playerId)) {
                case (#ok(p)) p;
                case (#playerNotFound(e)) return #endMatch(#stateBroken(#playerNotFound(e)));
            };
            state.log.add({
                message = "Player " # playerOut.name # " is being substituted by " # subPlayer.name;
                isImportant = true;
            });
            switch (fieldPosition) {
                case (#firstBase) state.field.defense.firstBase := subPlayerId;
                case (#secondBase) state.field.defense.secondBase := subPlayerId;
                case (#thirdBase) state.field.defense.thirdBase := subPlayerId;
                case (#shortStop) state.field.defense.shortStop := subPlayerId;
                case (#pitcher) state.field.defense.pitcher := subPlayerId;
                case (#leftField) state.field.defense.leftField := subPlayerId;
                case (#centerField) state.field.defense.centerField := subPlayerId;
                case (#rightField) state.field.defense.rightField := subPlayerId;
            };
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
                case (#firstBase) state.field.offense.firstBase := null;
                case (#secondBase) state.field.offense.secondBase := null;
                case (#thirdBase) state.field.offense.thirdBase := null;
                case (#homeBase) {
                    let ?nextBatterId = getRandomAvailablePlayer(?state.offenseTeamId, null, true) else {
                        return #endMatch(#outOfPlayers(state.offenseTeamId));
                    };
                    state.field.offense.atBat := nextBatterId;
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

        private func buildNewDefense(teamId : Team.TeamId) : ?MutableState.MutableDefenseFieldState {
            do ? {
                {
                    var pitcher = getRandomAvailablePlayer(?teamId, ? #pitcher, false)!;
                    var firstBase = getRandomAvailablePlayer(?teamId, ? #firstBase, false)!;
                    var secondBase = getRandomAvailablePlayer(?teamId, ? #secondBase, false)!;
                    var thirdBase = getRandomAvailablePlayer(?teamId, ? #thirdBase, false)!;
                    var shortStop = getRandomAvailablePlayer(?teamId, ? #shortStop, false)!;
                    var leftField = getRandomAvailablePlayer(?teamId, ? #leftField, false)!;
                    var centerField = getRandomAvailablePlayer(?teamId, ? #centerField, false)!;
                    var rightField = getRandomAvailablePlayer(?teamId, ? #rightField, false)!;
                };
            };
        };

        private func buildNewOffense(teamId : Team.TeamId) : ?MutableState.MutableOffenseFieldState {

            do ? {
                {
                    var atBat = getRandomAvailablePlayer(?teamId, null, false)!;
                    var firstBase = null;
                    var secondBase = null;
                    var thirdBase = null;
                };
            };
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
