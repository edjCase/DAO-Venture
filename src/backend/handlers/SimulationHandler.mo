import Result "mo:base/Result";
import Timer "mo:base/Timer";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Player "../models/Player";
import MatchAura "../models/MatchAura";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Season "../models/Season";
import Team "../models/Team";
import MatchSimulator "../MatchSimulator";
import LiveState "../models/LiveState";
import IterTools "mo:itertools/Iter";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type StartMatchGroupRequest = {
        id : Nat;
        matches : [StartMatchRequest];
    };
    public type StartMatchTeam = {
        id : Nat;
        name : Text;
        logoUrl : Text;
        color : (Nat8, Nat8, Nat8);
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
        #completed : {
            matches : [Season.CompletedMatch];
            playerStats : [Player.PlayerMatchStatsWithId];
        };
        #inProgress;
    };

    public type CompletedMatchResult = {
        match : Season.CompletedMatch;
        matchStats : [Player.PlayerMatchStatsWithId];
    };

    public type StableData = {
        matchGroups : [LiveState.LiveMatchGroupState];
    };

    type MutableLiveMatchGroupState = {
        id : Nat;
        var matches : [LiveState.LiveMatchStateWithStatus];
        var tickTimerId : Timer.TimerId;
        var currentSeed : Nat32;
    };

    public type OnMatchGroupCompleteData = {
        matches : [Season.CompletedMatch];
        playerStats : [Player.PlayerMatchStatsWithId];
    };

    public class Handler<system>(
        stableData : StableData,
        onMatchGroupComplete : (OnMatchGroupCompleteData) -> (),
    ) {
        let matchGroupStates : HashMap.HashMap<Nat, MutableLiveMatchGroupState> = toMatchGroupStateMap(stableData.matchGroups);

        public func toStableData() : StableData {
            {
                matchGroups = matchGroupStates.vals()
                |> Iter.map<MutableLiveMatchGroupState, LiveState.LiveMatchGroupState>(
                    _,
                    func(matchGroup : MutableLiveMatchGroupState) : LiveState.LiveMatchGroupState {
                        fromMutableMatchGroupState(matchGroup);
                    },
                )
                |> Iter.toArray(_);
            };
        };

        public func getLiveMatchGroupState(id : Nat) : Result.Result<LiveState.LiveMatchGroupState, { #matchGroupNotFound }> {
            let ?matchGroupState = matchGroupStates.get(id) else return #err(#matchGroupNotFound);
            #ok(fromMutableMatchGroupState(matchGroupState));
        };

        public func startMatchGroup<system>(
            prng : Prng,
            id : Nat,
            matches : [StartMatchRequest],
        ) : Result.Result<(), { #noMatchesSpecified }> {
            let tickTimerId = startTickTimer<system>(id);

            let tickResults = Buffer.Buffer<LiveState.LiveMatchStateWithStatus>(matches.size());
            label f for ((matchId, match) in IterTools.enumerate(Iter.fromArray(matches))) {

                let team1IsOffense = prng.nextCoin();
                let initState = MatchSimulator.initState(
                    match.aura,
                    match.team1,
                    match.team2,
                    team1IsOffense,
                    prng,
                );
                tickResults.add({
                    initState with
                    status = #inProgress;
                });
            };
            if (tickResults.size() == 0) {
                return #err(#noMatchesSpecified);
            };

            let matchGroup : MutableLiveMatchGroupState = {
                id = id;
                var matches = Buffer.toArray(tickResults);
                var tickTimerId = tickTimerId;
                var currentSeed = prng.getCurrentSeed();
            };
            matchGroupStates.put(id, matchGroup);
            #ok;
        };

        public func cancelMatchGroup(
            matchGroupId : Nat
        ) : Result.Result<(), CancelMatchGroupError> {
            switch (matchGroupStates.remove(matchGroupId)) {
                case (null) return #err(#matchGroupNotFound);
                case (?matchGroup) {
                    Timer.cancelTimer(matchGroup.tickTimerId);
                    #ok;
                };
            };
        };

        public func tickMatchGroup(
            matchGroupId : Nat
        ) : Result.Result<MatchGroupTickResult, { #matchGroupNotFound }> {

            let ?matchGroup = matchGroupStates.get(matchGroupId) else return #err(#matchGroupNotFound);
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

                    // Stuck in a bad state. Can retry by a manual tick call
                    #ok(#completed({ matches = completedMatches; playerStats }));
                };
                case (#inProgress(newMatches)) {

                    matchGroup.matches := newMatches;
                    matchGroup.currentSeed := prng.getCurrentSeed();

                    #ok(#inProgress);
                };
            };
        };

        public func finishMatchGroup(matchGroupId : Nat) : Result.Result<(), { #matchGroupNotFound }> {

            label l loop {
                switch (tickMatchGroup(matchGroupId)) {
                    case (#ok(#completed(_))) break l;
                    case (#ok(#inProgress(_))) {
                        // Continue ticking
                    };
                    case (#err(err)) return #err(err);
                };
            };
            #ok;
        };

        private func resetTickTimer<system>(matchGroupId : Nat) : () {
            let ?matchGroup = matchGroupStates.get(matchGroupId) else return;
            Timer.cancelTimer(matchGroup.tickTimerId);
            let newTickTimerId = startTickTimer<system>(matchGroupId);
            matchGroup.tickTimerId := newTickTimerId;
        };

        private func startTickTimer<system>(matchGroupId : Nat) : Timer.TimerId {
            Timer.setTimer<system>(
                #seconds(5),
                func() : async () {
                    switch (tickMatchGroup(matchGroupId)) {
                        case (#err(err)) {
                            Debug.print("Failed to tick match group: " # Nat.toText(matchGroupId) # ", Error: " # debug_show (err) # ". Canceling tick timer. Reset with `resetTickTimer` method");
                        };
                        case (#ok(#inProgress)) {
                            // If not complete, trigger again in 5 seconds
                            resetTickTimer<system>(matchGroupId);
                        };
                        case (#ok(#completed(c))) {
                            Debug.print("Match group complete: " # Nat.toText(matchGroupId));
                            // Remove match group if successfully passed info to the league
                            ignore matchGroupStates.remove(matchGroupId);
                            onMatchGroupComplete(c);
                        };
                    };
                },
            );
        };

        private func tickMatches(
            prng : Prng,
            tickResults : [LiveState.LiveMatchStateWithStatus],
        ) : {
            #completed : [CompletedMatchResult];
            #inProgress : [LiveState.LiveMatchStateWithStatus];
        } {
            let completedMatches = Buffer.Buffer<(LiveState.LiveMatchState, LiveState.LiveMatchStatusCompleted)>(tickResults.size());
            let updatedTickResults = Buffer.Buffer<LiveState.LiveMatchStateWithStatus>(tickResults.size());
            for (tickResult in Iter.fromArray(tickResults)) {
                let updatedTickResult = switch (tickResult.status) {
                    // Don't tick if completed
                    case (#completed(c)) {
                        completedMatches.add((tickResult, c));
                        tickResult;
                    };
                    // Tick if still in progress
                    case (#inProgress) MatchSimulator.tick(tickResult, prng);
                };
                updatedTickResults.add(updatedTickResult);
            };
            if (updatedTickResults.size() == completedMatches.size()) {
                // If all matches are complete, then complete the group
                let completedCompiledMatches = completedMatches.vals()
                |> Iter.map(
                    _,
                    func((match, status) : (LiveState.LiveMatchState, LiveState.LiveMatchStatusCompleted)) : CompletedMatchResult {
                        compileCompletedMatch(match, status);
                    },
                )
                |> Iter.toArray(_);
                #completed(completedCompiledMatches);
            } else {
                #inProgress(Buffer.toArray(updatedTickResults));
            };
        };

        private func compileCompletedMatch(match : LiveState.LiveMatchState, status : LiveState.LiveMatchStatusCompleted) : CompletedMatchResult {
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

        private func buildPlayerStats(match : LiveState.LiveMatchState) : [Player.PlayerMatchStatsWithId] {
            match.players.vals()
            |> Iter.map(
                _,
                func(player : LiveState.LivePlayerState) : Player.PlayerMatchStatsWithId {
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

        // Restart the timers for any match groups that were in progress
        for (matchGroupId in matchGroupStates.keys()) {
            resetTickTimer<system>(matchGroupId);
        };

    };

    private func toMutableMatchGroupState(matchGroup : LiveState.LiveMatchGroupState) : MutableLiveMatchGroupState {
        {
            id = matchGroup.id;
            var matches = matchGroup.matches;
            var tickTimerId = matchGroup.tickTimerId;
            var currentSeed = matchGroup.currentSeed;
        };
    };

    private func fromMutableMatchGroupState(matchGroup : MutableLiveMatchGroupState) : LiveState.LiveMatchGroupState {
        {
            id = matchGroup.id;
            matches = matchGroup.matches;
            tickTimerId = matchGroup.tickTimerId;
            currentSeed = matchGroup.currentSeed;
        };
    };

    private func toMatchGroupStateMap(matchGroups : [LiveState.LiveMatchGroupState]) : HashMap.HashMap<Nat, MutableLiveMatchGroupState> {
        matchGroups.vals()
        |> Iter.map<LiveState.LiveMatchGroupState, (Nat, MutableLiveMatchGroupState)>(
            _,
            func(matchGroup : LiveState.LiveMatchGroupState) : (Nat, MutableLiveMatchGroupState) {
                (matchGroup.id, toMutableMatchGroupState(matchGroup));
            },
        )
        |> HashMap.fromIter<Nat, MutableLiveMatchGroupState>(_, matchGroups.size(), Nat.equal, Nat32.fromNat);
    };
};
