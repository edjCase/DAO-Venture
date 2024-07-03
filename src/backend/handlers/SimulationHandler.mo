import Result "mo:base/Result";
import Timer "mo:base/Timer";
import Player "../models/Player";
import MatchAura "../models/MatchAura";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Season "../models/Season";
import FieldPosition "../models/FieldPosition";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type StartMatchGroupRequest = {
        id : Nat;
        matches : [StartMatchRequest];
    };

    public type Team = {
        id : Nat;
        name : Text;
        logoUrl : Text;
        color : (Nat8, Nat8, Nat8);
    };

    public type StartMatchTeam = Team and {
        positions : {
            firstBase : Player.Player;
            secondBase : Player.Player;
            thirdBase : Player.Player;
            shortStop : Player.Player;
            pitcher : Player.Player;
            leftField : Player.Player;
            centerField : Player.Player;
            rightField : Player.Player;
        };
    };

    public type StartMatchRequest = {
        team1 : StartMatchTeam;
        team2 : StartMatchTeam;
        aura : MatchAura.MatchAura;
    };

    public type CancelMatchGroupError = {
        #matchGroupNotFound;
    };

    public type MatchGroupTickResult = {
        #completed;
        #inProgress;
    };

    public type MatchGroupTickError = {};

    public type RoundLog = {
        turns : [TurnLog];
    };

    public type TurnLog = {
        events : [Event];
    };

    public type HitLocation = FieldPosition.FieldPosition or {
        #stands;
    };

    public type Event = {
        #traitTrigger : {
            id : Trait.Trait;
            playerId : Player.PlayerId;
            description : Text;
        };
        #auraTrigger : {
            id : MatchAura.MatchAura;
            description : Text;
        };
        #pitch : {
            pitcherId : Player.PlayerId;
            roll : {
                value : Int;
                crit : Bool;
            };
        };
        #swing : {
            playerId : Player.PlayerId;
            roll : {
                value : Int;
                crit : Bool;
            };
            pitchRoll : {
                value : Int;
                crit : Bool;
            };
            outcome : {
                #foul;
                #strike;
                #hit : HitLocation;
            };
        };
        #catch_ : {
            playerId : Player.PlayerId;
            roll : {
                value : Int;
                crit : Bool;
            };
            difficulty : {
                value : Int;
                crit : Bool;
            };
        };
        #teamSwap : {
            offenseTeamId : Team.TeamId;
            atBatPlayerId : Player.PlayerId;
        };
        #injury : {
            playerId : Nat32;
        };
        #death : {
            playerId : Nat32;
        };
        #score : {
            teamId : Team.TeamId;
            amount : Int;
        };
        #newBatter : {
            playerId : Player.PlayerId;
        };
        #out : {
            playerId : Player.PlayerId;
            reason : OutReason;
        };
        #matchEnd : {
            reason : MatchEndReason;
        };
        #safeAtBase : {
            playerId : Player.PlayerId;
            base : Base.Base;
        };
        #throw_ : {
            from : Player.PlayerId;
            to : Player.PlayerId;
        };
        #hitByBall : {
            playerId : Player.PlayerId;
        };
    };

    public type MatchEndReason = {
        #noMoreRounds;
        #error : Text;
    };

    public type OutReason = {
        #ballCaught;
        #strikeout;
        #hitByBall;
    };

    public type MatchLog = {
        rounds : [RoundLog];
    };

    public type Match = {
        team1 : TeamState;
        team2 : TeamState;
        offenseTeamId : Team.TeamId;
        aura : MatchAura.MatchAura;
        players : [PlayerStateWithId];
        bases : BaseState;
        log : MatchLog;
        outs : Nat;
        strikes : Nat;
    };

    public type PlayerExpectedOnFieldError = {
        id : Player.PlayerId;
        onOffense : Bool;
        description : Text;
    };

    public type BrokenStateError = {
        #playerNotFound : Player.PlayerId;
        #playerExpectedOnField : PlayerExpectedOnFieldError;
    };

    public type TickResult = {
        match : Match;
        status : MatchStatus;
    };

    public type MatchStatus = {
        #inProgress;
        #completed : MatchStatusCompleted;
    };

    public type MatchStatusCompleted = {
        reason : MatchEndReason;
    };

    public type MatchGroup = {
        matches : [TickResult];
        tickTimerId : Nat;
        currentSeed : Nat32;
    };

    public type MatchGroupWithId = MatchGroup and {
        id : Nat;
    };

    public class Handler() {
        public func startMatchGroup(prng : Prng) {

            let prng = PseudoRandomX.fromBlob(await Random.blob());
            let tickTimerId = startTickTimer<system>(request.id);

            let tickResults = Buffer.Buffer<Types.TickResult>(request.matches.size());
            label f for ((matchId, match) in IterTools.enumerate(Iter.fromArray(request.matches))) {

                let team1IsOffense = prng.nextCoin();
                let initState = MatchSimulator.initState(
                    match.aura,
                    match.team1,
                    match.team2,
                    team1IsOffense,
                    prng,
                );
                tickResults.add({
                    match = initState;
                    status = #inProgress;
                });
            };
            if (tickResults.size() == 0) {
                return #err(#noMatchesSpecified);
            };

            let matchGroup : Types.MatchGroupWithId = {
                id = request.id;
                matches = Buffer.toArray(tickResults);
                tickTimerId = tickTimerId;
                currentSeed = prng.getCurrentSeed();
            };
            addOrUpdateMatchGroup(matchGroup);
        };

        public func cancelMatchGroup(
            matchGroupId : Nat
        ) : Result.Result<(), CancelMatchGroupError> {
            assertLeague(caller);
            let matchGroupKey = buildMatchGroupKey(request.id);
            let (newMatchGroups, matchGroup) = Trie.remove(matchGroups, matchGroupKey, Nat.equal);
            switch (matchGroup) {
                case (null) return #err(#matchGroupNotFound);
                case (?matchGroup) {
                    matchGroups := newMatchGroups;
                    Timer.cancelTimer(matchGroup.tickTimerId);
                    #ok;
                };
            };
        };

        public func tickMatchGroup(matchGroupId : Nat) : Result.Result<MatchGroupTickResult, MatchGroupTickError> {

            let ?matchGroup = getMatchGroupOrNull(id) else return #err(#matchGroupNotFound);
            let prng = PseudoRandomX.LinearCongruentialGenerator(matchGroup.currentSeed);

            switch (tickMatches(prng, matchGroup.matches)) {
                case (#completed(completedTickResults)) {
                    // Cancel tick timer before disposing of match group
                    // NOTE: Should be canceled even if the onMatchGroupComplete fails, so it doesnt
                    // just keep ticking. Can retrigger manually if needed after fixing the
                    // issue

                    let completedMatches = completedTickResults
                    |> Iter.fromArray(_)
                    |> Iter.map(
                        _,
                        func(tickResult : CompletedMatchResult) : Season.CompletedMatch = tickResult.match,
                    )
                    |> Iter.toArray(_);

                    let playerStats = completedTickResults
                    |> Iter.fromArray(_)
                    |> Iter.map(
                        _,
                        func(tickResult : CompletedMatchResult) : Iter.Iter<Player.PlayerMatchStatsWithId> = Iter.fromArray(tickResult.matchStats),
                    )
                    |> IterTools.flatten<Player.PlayerMatchStatsWithId>(_)
                    |> Iter.toArray(_);

                    Timer.cancelTimer(matchGroup.tickTimerId);
                    let leagueActor = actor (Principal.toText(leagueCanisterId)) : LeagueTypes.LeagueActor;
                    let onCompleteRequest : LeagueTypes.OnMatchGroupCompleteRequest = {
                        id = id;
                        matches = completedMatches;
                        playerStats = playerStats;
                    };

                    let prng = try {
                        PseudoRandomX.fromBlob(await Random.blob());
                    } catch (err) {
                        return #err(#seedGenerationError(Error.message(err)));
                    };

                    let result = seasonHandler.onMatchGroupComplete(request, prng);
                    // TODO handle failure
                    awardUserPoints(request.id, request.matches);

                    let errorMessage = switch (result) {
                        case (#ok) {
                            // Remove match group if successfully passed info to the league
                            let matchGroupKey = buildMatchGroupKey(id);
                            let (newMatchGroups, _) = Trie.remove(matchGroups, matchGroupKey, Nat.equal);
                            matchGroups := newMatchGroups;
                            return #ok(#completed);
                        };
                        case (#err(#notAuthorized)) "Failed: Not authorized to complete match group";
                        case (#err(#matchGroupNotFound)) "Failed: Match group not found - " # Nat.toText(id);
                        case (#err(#seedGenerationError(err))) "Failed: Seed generation error - " # err;
                        case (#err(#seasonNotOpen)) "Failed: Season not open";
                        case (#err(#onCompleteCallbackError(err))) "Failed: On complete callback error - " # err;
                        case (#err(#matchGroupNotInProgress)) "Failed: Match group not in progress";
                    };
                    Debug.print("On Match Group Complete Result - " # errorMessage);
                    // Stuck in a bad state. Can retry by a manual tick call
                    #ok(#completed);
                };
                case (#inProgress(newMatches)) {
                    addOrUpdateMatchGroup({
                        matchGroup with
                        id = id;
                        matches = newMatches;
                        currentSeed = prng.getCurrentSeed();
                    });

                    #ok(#inProgress);
                };
            };
        };

        public func finishMatchGroup() {
            let ?matchGroup = getMatchGroupOrNull(id) else Debug.trap("Match group not found");
            var prng = PseudoRandomX.LinearCongruentialGenerator(matchGroup.currentSeed);
            label l loop {
                switch (tickMatches(prng, matchGroup.matches)) {
                    case (#completed(_)) break l;
                    case (#inProgress(newMatches)) {
                        addOrUpdateMatchGroup({
                            matchGroup with
                            id = id;
                            matches = newMatches;
                            currentSeed = prng.getCurrentSeed();
                        });
                        let ?newMG = getMatchGroupOrNull(id) else Debug.trap("Match group not found");
                        matchGroup := newMG;
                        prng := PseudoRandomX.LinearCongruentialGenerator(matchGroup.currentSeed);
                    };
                };
            };
        };

        private func resetTickTimer<system>(matchGroupId : Nat) : () {
            let ?matchGroup = getMatchGroupOrNull(matchGroupId) else return;
            Timer.cancelTimer(matchGroup.tickTimerId);
            let newTickTimerId = startTickTimer<system>(matchGroupId);
            addOrUpdateMatchGroup({
                matchGroup with
                id = matchGroupId;
                tickTimerId = newTickTimerId;
            });
        };

        private func startTickTimer<system>(matchGroupId : Nat) : Timer.TimerId {
            Timer.setTimer<system>(
                #seconds(5),
                func() : async () {
                    switch (simulationHandler.tickMatchGroup(matchGroupId)) {
                        case (#err(err)) {
                            Debug.print("Failed to tick match group: " # Nat.toText(matchGroupId) # ", Error: " # err # ". Canceling tick timer. Reset with `resetTickTimer` method");
                        };
                        case (#ok(isComplete)) {
                            if (not isComplete) {
                                // If not complete, trigger again in 5 seconds
                                resetTickTimerInternal<system>(matchGroupId);
                            } else {
                                Debug.print("Match group complete: " # Nat.toText(matchGroupId));
                            };
                        };
                    };
                },
            );
        };

        private func awardUserPoints(
            matchGroupId : Nat,
            completedMatches : [Season.CompletedMatch],
        ) : () {

            // Award users points for their predictions
            let anyAwards = switch (predictionHandler.getMatchGroup(matchGroupId)) {
                case (null) false;
                case (?matchGroupPredictions) {
                    let awards = Buffer.Buffer<UserTypes.AwardPointsRequest>(0);
                    var i = 0;
                    for (match in Iter.fromArray(completedMatches)) {
                        if (i >= matchGroupPredictions.size()) {
                            Debug.trap("Match group predictions and completed matches do not match in size. Invalid state. Matches: " # debug_show (completedMatches) # " Predictions: " # debug_show (matchGroupPredictions));
                        };
                        let matchPredictions = matchGroupPredictions[i];
                        i += 1;
                        for ((userId, teamId) in Iter.fromArray(matchPredictions)) {
                            if (teamId == match.winner) {
                                // Award points
                                awards.add({
                                    userId = userId;
                                    points = 10; // TODO amount?
                                });
                            };
                        };
                    };
                    if (awards.size() > 0) {
                        let error : ?Text = try {
                            switch (userHandler.awardPoints(Buffer.toArray(awards))) {
                                case (#ok) null;
                                case (#err(#notAuthorized)) ?"League is not authorized to award user points";
                            };
                        } catch (err) {
                            // TODO how to handle this?
                            ?Error.message(err);
                        };
                        switch (error) {
                            case (null) ();
                            case (?error) Debug.print("Failed to award user points: " # error);
                        };
                        true;
                    } else {
                        false;
                    };
                };
            };
            if (not anyAwards) {
                Debug.print("No user points to award, skipping...");
            };
        };

        private func tickMatches(prng : Prng, tickResults : [TickResult]) : {
            #completed : [CompletedMatchResult];
            #inProgress : [TickResult];
        } {
            let completedMatches = Buffer.Buffer<(Types.Match, Types.MatchStatusCompleted)>(tickResults.size());
            let updatedTickResults = Buffer.Buffer<Types.TickResult>(tickResults.size());
            for (tickResult in Iter.fromArray(tickResults)) {
                let updatedTickResult = switch (tickResult.status) {
                    // Don't tick if completed
                    case (#completed(c)) {
                        completedMatches.add((tickResult.match, c));
                        tickResult;
                    };
                    // Tick if still in progress
                    case (#inProgress) MatchSimulator.tick(tickResult.match, prng);
                };
                updatedTickResults.add(updatedTickResult);
            };
            if (updatedTickResults.size() == completedMatches.size()) {
                // If all matches are complete, then complete the group
                let completedCompiledMatches = completedMatches.vals()
                |> Iter.map(
                    _,
                    func((match, status) : (Types.Match, Types.MatchStatusCompleted)) : CompletedMatchResult {
                        compileCompletedMatch(match, status);
                    },
                )
                |> Iter.toArray(_);
                #completed(completedCompiledMatches);
            } else {
                #inProgress(Buffer.toArray(updatedTickResults));
            };
        };

        private func compileCompletedMatch(match : Types.Match, status : Types.MatchStatusCompleted) : CompletedMatchResult {
            let winner : Team.TeamIdOrTie = switch (status.reason) {
                case (#noMoreRounds) {
                    if (match.team1.score > match.team2.score) {
                        #team1;
                    } else if (match.team1.score == match.team2.score) {
                        #tie;
                    } else {
                        #team2;
                    };
                };
                case (#error(e)) #tie;
            };

            let playerStats = buildPlayerStats(match);

            {
                match : Season.CompletedMatch = {
                    team1 = match.team1;
                    team2 = match.team2;
                    aura = match.aura;
                    log = match.log;
                    winner = winner;
                    playerStats = playerStats;
                };
                matchStats = playerStats;
            };
        };

        private func buildPlayerStats(match : Types.Match) : [Player.PlayerMatchStatsWithId] {
            match.players.vals()
            |> Iter.map(
                _,
                func(player : Types.PlayerStateWithId) : Player.PlayerMatchStatsWithId {
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

        private func getMatchGroupOrNull(matchGroupId : Nat) : ?Types.MatchGroup {
            let matchGroupKey = buildMatchGroupKey(matchGroupId);
            Trie.get(matchGroups, matchGroupKey, Nat.equal);
        };

        private func buildMatchGroupKey(matchGroupId : Nat) : {
            key : Nat;
            hash : Nat32;
        } {
            {
                hash = Nat32.fromNat(matchGroupId); // TODO better hash? shouldnt need more than 32 bits
                key = matchGroupId;
            };
        };
    };
};
