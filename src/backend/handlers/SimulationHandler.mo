import Result "mo:base/Result";
import Timer "mo:base/Timer";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
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
        #noLiveMatchGroup;
    };

    public type MatchGroupTickResult = {
        #completed;
        #inProgress;
    };

    public type OnMatchGroupCompleteData = {
        matchGroupId : Nat;
        matches : [Season.CompletedMatch];
        playerStats : [Player.PlayerMatchStatsWithId];
    };

    public type CompletedMatchResult = {
        match : Season.CompletedMatch;
        matchStats : [Player.PlayerMatchStatsWithId];
    };

    public type StableData = {
        matchGroupState : ?LiveState.LiveMatchGroupState;
    };

    type MutableLiveMatchGroupState = {
        id : Nat;
        var matches : [LiveState.LiveMatchStateWithStatus];
        var tickTimerId : Timer.TimerId;
        var currentSeed : Nat32;
    };

    public class Handler<system>(
        stableData : StableData,
        onMatchGroupComplete : <system>(OnMatchGroupCompleteData) -> (),
    ) {
        var matchGroupStateOrNull : ?MutableLiveMatchGroupState = switch (stableData.matchGroupState) {
            case (?s) ?toMutableMatchGroupState(s);
            case (null) null;
        };

        public func toStableData() : StableData {
            {
                matchGroupState = switch (matchGroupStateOrNull) {
                    case (?s) ?fromMutableMatchGroupState(s);
                    case (null) null;
                };
            };
        };

        public func getLiveMatchGroupState() : ?LiveState.LiveMatchGroupState {
            let ?matchGroupState = matchGroupStateOrNull else return null;
            ?fromMutableMatchGroupState(matchGroupState);
        };

        public func startMatchGroup<system>(
            prng : Prng,
            id : Nat,
            matches : [StartMatchRequest],
            onMatchGroupComplete : <system>(OnMatchGroupCompleteData) -> (),
        ) : Result.Result<(), { #noMatchesSpecified; #matchGroupInProgress }> {
            Debug.print("Starting match group: " # Nat.toText(id));
            let null = matchGroupStateOrNull else return #err(#matchGroupInProgress);
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

            matchGroupStateOrNull := ?{
                id = id;
                var matches = Buffer.toArray(tickResults);
                var tickTimerId = tickTimerId;
                var currentSeed = prng.getCurrentSeed();
                onMatchGroupComplete = onMatchGroupComplete;
            };
            #ok;
        };

        public func cancelMatchGroup() : Result.Result<(), CancelMatchGroupError> {
            switch (matchGroupStateOrNull) {
                case (null) return #err(#noLiveMatchGroup);
                case (?matchGroup) {
                    Timer.cancelTimer(matchGroup.tickTimerId);
                    // TODO onMatchGroupComplete?
                    matchGroupStateOrNull := null;
                    #ok;
                };
            };
        };

        private func tickMatchGroup<system>() : Result.Result<MatchGroupTickResult, { #noLiveMatchGroup }> {

            let ?matchGroup = matchGroupStateOrNull else return #err(#noLiveMatchGroup);
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

                    onMatchGroupComplete<system>({
                        matchGroupId = matchGroup.id;
                        matches = completedMatches;
                        playerStats;
                    });
                    matchGroupStateOrNull := null;
                    #ok(#completed);
                };
                case (#inProgress(newMatches)) {

                    matchGroup.matches := newMatches;
                    matchGroup.currentSeed := prng.getCurrentSeed();

                    #ok(#inProgress);
                };
            };
        };

        public func finishMatchGroup<system>() : Result.Result<(), { #noLiveMatchGroup }> {

            label l loop {
                switch (tickMatchGroup<system>()) {
                    case (#ok(#completed)) {
                        break l;
                    };
                    case (#ok(#inProgress(_))) {
                        // Continue ticking
                    };
                    case (#err(err)) return #err(err);
                };
            };
            #ok;
        };

        private func resetTickTimer<system>() : () {
            let ?matchGroup = matchGroupStateOrNull else return;
            Timer.cancelTimer(matchGroup.tickTimerId);
            let newTickTimerId = startTickTimer<system>(matchGroup.id);
            matchGroup.tickTimerId := newTickTimerId;
        };

        private func startTickTimer<system>(matchGroupId : Nat) : Timer.TimerId {
            Timer.setTimer<system>(
                #seconds(5),
                func() : async () {
                    switch (tickMatchGroup<system>()) {
                        case (#err(err)) {
                            Debug.print("Failed to tick match group: " # Nat.toText(matchGroupId) # ", Error: " # debug_show (err) # ". Canceling tick timer. Reset with `resetTickTimer` method");
                        };
                        case (#ok(#inProgress)) {
                            // If not complete, trigger again in 5 seconds
                            resetTickTimer<system>();
                        };
                        case (#ok(#completed)) {
                            Debug.print("Match group complete ");
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
        resetTickTimer<system>();
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
};
