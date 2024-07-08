import Season "../models/Season";
import Team "../models/Team";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Trie "mo:base/Trie";
import Prelude "mo:base/Prelude";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Timer "mo:base/Timer";
import Debug "mo:base/Debug";
import Order "mo:base/Order";
import Result "mo:base/Result";
import ScheduleBuilder "../ScheduleBuilder";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Util "../Util";
import Anomoly "../models/Anomoly";
import IterTools "mo:itertools/Iter";
import Player "../models/Player";
import Components "mo:datetime/Components";
import Scenario "../models/Scenario";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type StartMatchGroupError = {
        #notScheduledYet;
        #alreadyStarted;
        #matchErrors : [{
            matchId : Nat;
            error : StartMatchError;
        }];
    };

    public type StartMatchError = {
        #notEnoughPlayers : Team.TeamIdOrBoth;
    };

    public type CloseSeasonError = {
        #seasonNotOpen;
    };

    public type CloseSeasonResult = Result.Result<(), CloseSeasonError>;

    public type OnMatchGroupCompleteResult = Result.Result<(), OnMatchGroupCompleteError>;

    public type OnMatchGroupCompleteError = {
        #seasonNotOpen;
        #matchGroupNotFound;
        #matchGroupNotInProgress;
    };

    public type TeamStandingInfo = {
        id : Nat;
        wins : Nat;
        losses : Nat;
        totalScore : Int;
    };

    public type ReverseEffect = {
        after : {
            #matchGroupId : Nat;
            #season;
        };
        effect : Scenario.ReverseEffect;
    };

    public type StableData = {
        seasonStatus : Season.SeasonStatus;
        reverseEffects : [ReverseEffect];
    };
    public type StartSeasonResult = Result.Result<(), StartSeasonError>;

    public type StartSeasonError = {
        #alreadyStarted;
        #invalidArgs : Text;
    };

    public type AddMatchStatsError = {

    };

    public type CancelMatchGroupError = {
        #matchGroupNotFound;
    };

    public type StartMatchTeam = {
        id : Nat;
        anomolies : [Anomoly.Anomoly];
        positions : StartMatchTeamPositions;
    };

    public type StartMatchTeamPositions = {
        firstBase : Player.Player;
        secondBase : Player.Player;
        thirdBase : Player.Player;
        shortStop : Player.Player;
        pitcher : Player.Player;
        leftField : Player.Player;
        centerField : Player.Player;
        rightField : Player.Player;
    };

    public type StartMatchRequest = {
        team1 : StartMatchTeam;
        team2 : StartMatchTeam;
    };

    public type Events = {
        onSeasonStart : Buffer.Buffer<OnSeasonStartEvent>;
        onMatchGroupSchedule : Buffer.Buffer<OnMatchGroupScheduleEvent>;
        onMatchGroupStart : Buffer.Buffer<OnMatchGroupStartEvent>;
        onMatchGroupComplete : Buffer.Buffer<OnMatchGroupCompleteEvent>;
        onSeasonComplete : Buffer.Buffer<OnSeasonCompleteEvent>;
        onEffectReversal : Buffer.Buffer<OnEffectReversalEvent>;
    };

    public type OnSeasonScheduleEvent = <system>(
        season : Season.InProgressSeason
    ) -> ();
    public type OnSeasonStartEvent = <system>(
        season : Season.InProgressSeason
    ) -> ();
    public type OnMatchGroupScheduleEvent = <system>(
        matchGroupId : Nat,
        matchGroup : Season.ScheduledMatchGroup,
    ) -> ();
    public type OnMatchGroupStartEvent = <system>(
        matchGroupId : Nat,
        season : Season.InProgressSeason,
        matchGroup : Season.InProgressMatchGroup,
        matches : [Season.InProgressMatch],
    ) -> ();
    public type OnMatchGroupCompleteEvent = <system>(
        matchGroupId : Nat,
        matchGroup : Season.CompletedMatchGroup,
    ) -> ();
    public type OnSeasonCompleteEvent = <system>(
        season : Season.CompletedSeason
    ) -> ();
    public type OnEffectReversalEvent = <system>(
        effects : [Scenario.ReverseEffect]
    ) -> ();

    public type EndedSeasonVariant = {
        #incomplete : Season.InProgressSeason;
        #completed : Season.CompletedSeason;
    };

    public class SeasonHandler<system>(
        data : StableData,
        events : Events,
        getTeamData : (Nat) -> Season.InProgressTeam,
    ) {

        public var seasonStatus : Season.SeasonStatus = data.seasonStatus;

        let reverseEffects = Buffer.fromArray<ReverseEffect>(data.reverseEffects);

        public func toStableData() : StableData {
            {
                seasonStatus = seasonStatus;
                reverseEffects = Buffer.toArray(reverseEffects);
            };
        };

        public func startSeason<system>(
            prng : Prng,
            startTime : Time.Time,
            weekDays : [Components.DayOfWeek],
            teamIds : [Nat],
        ) : StartSeasonResult {
            switch (seasonStatus) {
                case (#notStarted) {};
                case (#starting) return #err(#alreadyStarted);
                case (#inProgress(_)) return #err(#alreadyStarted);
                case (#completed(completedSeason)) {
                    // TODO archive completed season?
                };
            };
            seasonStatus := #starting;

            let teamIdsBuffer = Buffer.fromArray<Nat>(teamIds);

            prng.shuffleBuffer(teamIdsBuffer); // Randomize the team order

            let buildResult = ScheduleBuilder.build(
                startTime,
                Buffer.toArray(teamIdsBuffer),
                weekDays,
            );

            let schedule : ScheduleBuilder.SeasonSchedule = switch (buildResult) {
                case (#ok(schedule)) schedule;
                case (#err(#invalidArgs(err))) {
                    seasonStatus := #notStarted;
                    return #err(#invalidArgs(err));
                };
            };

            // Save full schedule, then try to start the first match groups
            let notScheduledMatchGroups = schedule.matchGroups
            |> Iter.fromArray(_)
            |> Iter.map(
                _,
                func(mg : ScheduleBuilder.MatchGroup) : Season.InProgressSeasonMatchGroupVariant = #notScheduled({
                    time = mg.time;
                    matches = mg.matches
                    |> Iter.fromArray(_)
                    |> Iter.map(
                        _,
                        func(m : ScheduleBuilder.Match) : Season.NotScheduledMatch = {
                            team1 = m.team1;
                            team2 = m.team2;
                        },
                    )
                    |> Iter.toArray(_);
                }),
            )
            |> Iter.toArray(_);

            let inProgressSeason = {
                matchGroups = notScheduledMatchGroups;
            };

            seasonStatus := #inProgress(inProgressSeason);

            for (event in events.onSeasonStart.vals()) {
                event<system>(inProgressSeason);
            };

            // Get first match group to open
            let #notScheduled(firstMatchGroup) = notScheduledMatchGroups[0] else Prelude.unreachable();

            scheduleMatchGroup<system>(
                0,
                firstMatchGroup,
                inProgressSeason,
            );
            #ok;
        };

        public func getTeamStandings() : ?[TeamStandingInfo] {
            // Get all completed match groups
            let completedMatchGroups = switch (seasonStatus) {
                case (#notStarted or #starting) return null;
                case (#inProgress(inProgressSeason)) {
                    let completedMatchGroups = Buffer.Buffer<Season.CompletedMatchGroup>(0);
                    label f for (matchGroup in Iter.fromArray(inProgressSeason.matchGroups)) {
                        switch (matchGroup) {
                            case (#completed(completedMatchGroup)) completedMatchGroups.add(completedMatchGroup);
                            case (#notScheduled(_) or #scheduled(_) or #inProgress(_)) continue f;
                        };
                    };
                    Buffer.toArray(completedMatchGroups);
                };
                case (#completed(completedSeason)) {
                    completedSeason.matchGroups;
                };
            };
            ?buildTeamStandingInfo(completedMatchGroups);
        };

        private func buildTeamStandingInfo(
            matchGroups : [Season.CompletedMatchGroup]
        ) : [TeamStandingInfo] {
            var teamScores = Trie.empty<Nat, TeamStandingInfo>();
            let updateTeamScore = func(
                teamId : Nat,
                score : Int,
                state : { #win; #loss; #tie },
            ) : () {

                let teamKey = {
                    key = teamId;
                    hash = Nat32.fromNat(teamId);
                };
                let currentScore = switch (Trie.get(teamScores, teamKey, Nat.equal)) {
                    case (null) {
                        {
                            wins = 0;
                            losses = 0;
                            totalScore = 0;
                        };
                    };
                    case (?score) score;
                };

                let (wins, losses) = switch (state) {
                    case (#win) (currentScore.wins + 1, currentScore.losses);
                    case (#loss) (currentScore.wins, currentScore.losses + 1);
                    case (#tie) (currentScore.wins, currentScore.losses);
                };

                // Update with +1
                let (newTeamScores, _) = Trie.put<Nat, TeamStandingInfo>(
                    teamScores,
                    teamKey,
                    Nat.equal,
                    {
                        id = teamId;
                        wins = wins;
                        losses = losses;
                        totalScore = currentScore.totalScore + score;
                    },
                );
                teamScores := newTeamScores;
            };

            // Populate scores
            label f1 for (matchGroup in Iter.fromArray(matchGroups)) {
                label f2 for (match in Iter.fromArray(matchGroup.matches)) {
                    let (team1State, team2State) = switch (match.winner) {
                        case (#team1) (#win, #loss);
                        case (#team2) (#loss, #win);
                        case (#tie) (#tie, #tie);
                    };
                    updateTeamScore(match.team1.id, match.team1.score, team1State);
                    updateTeamScore(match.team2.id, match.team2.score, team2State);
                };
            };
            teamScores
            |> Trie.iter(_)
            |> Iter.map(
                _,
                func((_, v) : (Nat, TeamStandingInfo)) : TeamStandingInfo = v,
            )
            |> IterTools.sort(
                _,
                func(a : TeamStandingInfo, b : TeamStandingInfo) : Order.Order {
                    if (a.wins > b.wins) {
                        #greater;
                    } else if (a.wins < b.wins) {
                        #less;
                    } else {
                        if (a.losses < b.losses) {
                            #greater;
                        } else if (a.losses > b.losses) {
                            #less;
                        } else {
                            if (a.totalScore > b.totalScore) {
                                #greater;
                            } else if (a.totalScore < b.totalScore) {
                                #less;
                            } else {
                                #equal;
                            };
                        };
                    };
                },
            )
            |> Iter.toArray(_);
        };

        public func getNextScheduledMatchGroup() : ?{
            matchGroupId : Nat;
            matchGroup : Season.ScheduledMatchGroup;
            season : Season.InProgressSeason;
        } {
            // Get current match group by finding the next scheduled one
            switch (seasonStatus) {
                case (#inProgress(inProgressSeason)) {
                    for (i in Iter.range(0, inProgressSeason.matchGroups.size() - 1)) {
                        let matchGroup = inProgressSeason.matchGroups[i];
                        switch (matchGroup) {
                            // Find first scheduled match group
                            case (#scheduled(s)) return ?{
                                matchGroupId = i;
                                matchGroup = s;
                                season = inProgressSeason;
                            };
                            // If we find a match group that is not scheduled, then there are no upcoming match groups
                            case (#notScheduled(_) or #inProgress(_)) return null;
                            // Skip completed match groups
                            case (#completed(_)) ();
                        };
                    };
                    return null;
                };
                case (_) return null;
            };
        };

        public func scheduleReverseEffect(
            matchCount : Nat,
            effect : Scenario.ReverseEffect,
        ) : () {
            if (matchCount == 0) {
                Debug.trap("Match count must be greater than 0");
            };

            let after = switch (getNextScheduledMatchGroup()) {
                case (null) {
                    #season; // No match groups to schedule after
                };
                case (?mg) {
                    let afterMatchGroupId : Nat = mg.matchGroupId + matchCount - 1;
                    #matchGroupId(afterMatchGroupId);
                };
            };
            reverseEffects.add({
                after;
                effect;
            });
        };

        public func getMatchGroup(matchGroupId : Nat) : ?{
            matchGroupId : Nat;
            matchGroup : Season.InProgressSeasonMatchGroupVariant;
            season : {
                #inProgress : Season.InProgressSeason;
                #completed : Season.CompletedSeason;
            };
        } {
            // Get current match group by finding the next scheduled one
            switch (seasonStatus) {
                case (#notStarted or #starting) null;
                case (#inProgress(inProgressSeason)) {
                    if (matchGroupId >= inProgressSeason.matchGroups.size()) {
                        return null;
                    };
                    ?{
                        matchGroupId = matchGroupId;
                        matchGroup = inProgressSeason.matchGroups[matchGroupId];
                        season = #inProgress(inProgressSeason);
                    };
                };
                case (#completed(c)) {
                    if (matchGroupId >= c.matchGroups.size()) {
                        return null;
                    };
                    ?{
                        matchGroupId = matchGroupId;
                        matchGroup = #completed(c.matchGroups[matchGroupId]);
                        season = #completed(c);
                    };
                };
            };
        };

        public func completeMatchGroup<system>(
            matchGroupId : Nat,
            matches : [Season.CompletedMatch],
        ) : OnMatchGroupCompleteResult {

            let #inProgress(season) = seasonStatus else return #err(#seasonNotOpen);
            // Get current match group
            let ?matchGroup = Util.arrayGetSafe<Season.InProgressSeasonMatchGroupVariant>(
                season.matchGroups,
                matchGroupId,
            ) else return #err(#matchGroupNotFound);
            let inProgressMatchGroup = switch (matchGroup) {
                case (#inProgress(matchGroupState)) matchGroupState;
                case (_) return #err(#matchGroupNotInProgress);
            };

            // Update status to completed
            let updatedMatchGroup : Season.CompletedMatchGroup = {
                time = inProgressMatchGroup.time;
                matches = matches;
            };

            let ?newMatchGroups = Util.arrayUpdateElementSafe<Season.InProgressSeasonMatchGroupVariant>(
                season.matchGroups,
                matchGroupId,
                #completed(updatedMatchGroup),
            ) else return #err(#matchGroupNotFound);

            for (event in events.onMatchGroupComplete.vals()) {
                event<system>(matchGroupId, updatedMatchGroup);
            };

            let filterReverseEffects = reverseEffects.vals()
            |> Iter.filter(
                _,
                func(e : ReverseEffect) : Bool {
                    // Only end of match group effects
                    let #matchGroupId(afterMatchGroupId) = e.after else return false;
                    afterMatchGroupId == matchGroupId;
                },
            )
            |> Iter.map(
                _,
                func(e : ReverseEffect) : Scenario.ReverseEffect = e.effect,
            )
            |> Iter.toArray(_);

            for (event in events.onEffectReversal.vals()) {
                // TODO this feels weird to have potentially do multiple events, but it's the only
                // way that I could find to handle the cyclical dependency
                event<system>(filterReverseEffects);
            };

            let completedMatchGroups = Buffer.Buffer<Season.CompletedMatchGroup>(season.matchGroups.size());
            label f for (matchGroup in Iter.fromArray(newMatchGroups)) {
                switch (matchGroup) {
                    case (#completed(completedMatchGroup)) completedMatchGroups.add(completedMatchGroup);
                    case (_) break f; // Break on first incomplete match
                };
            };

            let updatedSeason = {
                season with
                matchGroups = newMatchGroups;
            };
            seasonStatus := #inProgress(updatedSeason);

            // Get next match group to schedule
            let nextMatchGroupId = matchGroupId + 1;
            let ?nextMatchGroup = Util.arrayGetSafe<Season.InProgressSeasonMatchGroupVariant>(
                updatedSeason.matchGroups,
                nextMatchGroupId,
            ) else {
                // Season is over because cant find more match groups
                return close<system>();
            };
            switch (nextMatchGroup) {
                case (#notScheduled(matchGroup)) {
                    // Schedule next match group
                    scheduleMatchGroup<system>(
                        nextMatchGroupId,
                        matchGroup,
                        updatedSeason,
                    );
                };
                case (_) {
                    // TODO
                    // Anything else is a bad state
                    // Print out error, but don't fail the call
                    Debug.print("Unable to schedule next match group " # Nat.toText(nextMatchGroupId) # " because it is not in the correct state: " # debug_show (nextMatchGroup));
                };
            };
            #ok;
        };

        public func close<system>() : CloseSeasonResult {

            if (seasonStatus == #starting) {
                // TODO how to handle this?
                seasonStatus := #notStarted;
                return #ok;
            };
            let #inProgress(inProgressSeason) = seasonStatus else return #err(#seasonNotOpen);
            let completedMatchGroups = switch (buildCompletedMatchGroups(inProgressSeason)) {
                case (#ok(completedMatchGroups)) completedMatchGroups;
                case (#matchGroupsNotComplete(_)) {
                    // TODO put in bad state vs delete
                    seasonStatus := #notStarted;
                    return #ok;
                };
            };
            let finalTeamStandings = buildTeamStandingInfo(completedMatchGroups);

            let finalMatch = completedMatchGroups[completedMatchGroups.size() - 1].matches[0];
            let (champion, runnerUp) = switch (finalMatch.winner) {
                case (#team1) (finalMatch.team1, finalMatch.team2);
                case (#team2) (finalMatch.team2, finalMatch.team1);
                case (#tie) {
                    // Break tie by their win/loss ratio
                    let getTeamStanding = func(teamId : Nat) : Nat {
                        let ?teamStanding = IterTools.findIndex(finalTeamStandings.vals(), func(s : TeamStandingInfo) : Bool = s.id == teamId) else Debug.trap("Team not found in standings: " # Nat.toText(teamId));
                        teamStanding;
                    };
                    let team1Standing = getTeamStanding(finalMatch.team1.id);
                    let team2Standing = getTeamStanding(finalMatch.team2.id);
                    // TODO how to communicate why the team with the higher standing is the champion?
                    if (team1Standing > team2Standing) {
                        (finalMatch.team1, finalMatch.team2);
                    } else {
                        (finalMatch.team2, finalMatch.team1);
                    };
                };
            };

            let completedSeason : Season.CompletedSeason = {
                championTeamId = champion.id;
                runnerUpTeamId = runnerUp.id;
                teams = finalTeamStandings;
                matchGroups = completedMatchGroups;
            };
            seasonStatus := #completed(completedSeason);
            for (event in events.onSeasonComplete.vals()) {
                event<system>(completedSeason);
            };
            let filterReverseEffects = reverseEffects.vals()
            |> Iter.filter(
                _,
                func(e : ReverseEffect) : Bool {
                    // Only end of season effects
                    let #season = e.after else return false;
                    true;
                },
            )
            |> Iter.map(
                _,
                func(e : ReverseEffect) : Scenario.ReverseEffect = e.effect,
            )
            |> Iter.toArray(_);

            for (event in events.onEffectReversal.vals()) {
                // TODO this feels weird to have potentially do multiple events, but it's the only
                // way that I could find to handle the cyclical dependency
                event<system>(filterReverseEffects);
            };
            #ok;
        };

        private func resetTimers<system>() {
            switch (seasonStatus) {
                case (#notStarted or #starting) ();
                case (#inProgress(inProgressSeason)) {
                    for (i in Iter.range(0, inProgressSeason.matchGroups.size() - 1)) {
                        let matchGroup = inProgressSeason.matchGroups[i];
                        switch (matchGroup) {
                            case (#scheduled(scheduledMatchGroup)) {
                                let timerId = scheduledMatchGroup.timerId;
                                Timer.cancelTimer(timerId);
                                let newTimerId = createStartTimer<system>(i, scheduledMatchGroup.time);
                                let ?newMatchGroups = Util.arrayUpdateElementSafe<Season.InProgressSeasonMatchGroupVariant>(
                                    inProgressSeason.matchGroups,
                                    i,
                                    #scheduled({
                                        scheduledMatchGroup with
                                        timerId = newTimerId;
                                    }),
                                ) else Debug.trap("Match group not found: " # Nat.toText(i));
                                seasonStatus := #inProgress({
                                    inProgressSeason with
                                    matchGroups = newMatchGroups;
                                });
                            };
                            case (#notScheduled(_) or #inProgress(_) or #completed(_)) ();
                        };
                    };
                };
                case (#completed(_)) ();
            };
        };

        private func createStartTimer<system>(
            matchGroupId : Nat,
            startTime : Time.Time,
        ) : Timer.TimerId {
            let timeDiff = startTime - Time.now();
            Debug.print("Scheduling match group " # Nat.toText(matchGroupId) # " in " # Int.toText(timeDiff) # " nanoseconds");
            let duration = if (timeDiff <= 0) {
                // Schedule immediately
                #nanoseconds(0);
            } else {
                #nanoseconds(Int.abs(timeDiff));
            };
            Timer.setTimer<system>(
                duration,
                func() : async () {
                    let message = switch (startMatchGroup<system>(matchGroupId)) {
                        case (#ok) "Match group started";
                        case (#err(#matchGroupNotFound)) "Match group not found";
                        case (#err(#notScheduledYet)) "Match group not scheduled yet";
                        case (#err(#alreadyStarted)) "Match group already started";
                        case (#err(#matchErrors(errors))) "Match group errors: " # debug_show (errors);
                    };
                    Debug.print("Match group '" # Nat.toText(matchGroupId) # "' start callback: " # message);
                },
            );
        };

        private func scheduleMatchGroup<system>(
            matchGroupId : Nat,
            matchGroup : Season.NotScheduledMatchGroup,
            inProgressSeason : Season.InProgressSeason,
        ) : () {
            let timerId = createStartTimer<system>(matchGroupId, matchGroup.time);

            let getTeamId = func(teamAssignment : Season.TeamAssignment) : Nat {
                switch (teamAssignment) {
                    case (#predetermined(teamId)) teamId;
                    case (#seasonStandingIndex(standingIndex)) {
                        // get team based on current season standing
                        let ?standings = getTeamStandings() else Debug.trap("Standings not found");

                        let ?teamWithStanding = Util.arrayGetSafe(standings, standingIndex) else Debug.trap("Standing not found. Standings: " # debug_show (standings) # " Standing index: " # Nat.toText(standingIndex));

                        teamWithStanding.id;
                    };
                    case (#winnerOfMatch(matchId)) {
                        let previousMatchGroupId : Nat = matchGroupId - 1;
                        // get winner of match in previous match group
                        let ?previousMatchGroup = Util.arrayGetSafe<Season.InProgressSeasonMatchGroupVariant>(
                            inProgressSeason.matchGroups,
                            previousMatchGroupId,
                        ) else Debug.trap("Previous match group not found, cannot get winner of match. Match Group Id: " # Nat.toText(previousMatchGroupId));
                        let #completed(completedMatchGroup) = previousMatchGroup else Debug.trap("Previous match group not completed, cannot get winner of match. Match Group Id: " # Nat.toText(matchGroupId));
                        let ?match = Util.arrayGetSafe<Season.CompletedMatch>(
                            completedMatchGroup.matches,
                            matchId,
                        ) else Debug.trap("Previous match not found, cannot get winner of match. Match Id: " # Nat.toText(matchId));

                        if (match.winner == #team1) {
                            match.team1.id;
                        } else {
                            match.team2.id;
                        };
                    };
                };
            };

            let scheduledMatchGroup : Season.ScheduledMatchGroup = {
                time = matchGroup.time;
                timerId = timerId;
                matches = matchGroup.matches
                |> Iter.fromArray(_)
                |> Iter.map(
                    _,
                    func(m : Season.NotScheduledMatch) : Season.ScheduledMatch {
                        let team1Id = getTeamId(m.team1);
                        let team2Id = getTeamId(m.team2);

                        {
                            team1 = { id = team1Id };
                            team2 = { id = team2Id };
                        };
                    },
                )
                |> Iter.toArray(_);
            };

            let ?newMatchGroups = Util.arrayUpdateElementSafe<Season.InProgressSeasonMatchGroupVariant>(
                inProgressSeason.matchGroups,
                matchGroupId,
                #scheduled(scheduledMatchGroup),
            ) else return Debug.trap("Match group not found: " # Nat.toText(matchGroupId));

            seasonStatus := #inProgress({
                inProgressSeason with
                matchGroups = newMatchGroups;
            });
            for (event in events.onMatchGroupSchedule.vals()) {
                event<system>(matchGroupId, scheduledMatchGroup);
            };
        };

        private func buildCompletedMatchGroups(
            season : Season.InProgressSeason
        ) : {
            #ok : [Season.CompletedMatchGroup];
            #matchGroupsNotComplete : ?{
                matchGroupId : Nat;
            };
        } {
            let completedMatchGroups = Buffer.Buffer<Season.CompletedMatchGroup>(season.matchGroups.size());
            var matchGroupId = 0;
            for (matchGroup in Iter.fromArray(season.matchGroups)) {
                let completedMatchGroup = switch (matchGroup) {
                    case (#completed(completedMatchGroup)) completedMatchGroup;
                    case (#notScheduled(_)) return #matchGroupsNotComplete(null);
                    case (#scheduled(_)) return #matchGroupsNotComplete(null);
                    case (#inProgress(_)) return #matchGroupsNotComplete(
                        ?{
                            matchGroupId = matchGroupId;
                        }
                    );
                };
                matchGroupId += 1;
                completedMatchGroups.add(completedMatchGroup);
            };
            #ok(Buffer.toArray(completedMatchGroups));
        };

        public func startNextMatchGroup<system>() : Result.Result<(), StartMatchGroupError> {
            let ?nextMatchGroup = getNextScheduledMatchGroup() else return #err(#notScheduledYet);
            switch (startMatchGroup<system>(nextMatchGroup.matchGroupId)) {
                case (#ok) #ok;
                case (#err(#matchGroupNotFound)) Prelude.unreachable();
                case (#err(#notScheduledYet)) #err(#notScheduledYet);
                case (#err(#alreadyStarted)) #err(#alreadyStarted);
                case (#err(#matchErrors(errors))) #err(#matchErrors(errors));
            };
        };

        private func startMatchGroup<system>(
            matchGroupId : Nat
        ) : Result.Result<(), StartMatchGroupError or { #matchGroupNotFound }> {
            let #inProgress(season) = seasonStatus else return #err(#matchGroupNotFound);

            // Get current match group
            let ?matchGroupVariant = Util.arrayGetSafe(
                season.matchGroups,
                matchGroupId,
            ) else return #err(#matchGroupNotFound);

            let scheduledMatchGroup : Season.ScheduledMatchGroup = switch (matchGroupVariant) {
                case (#notScheduled(_)) return #err(#notScheduledYet);
                case (#inProgress(_)) return #err(#alreadyStarted);
                case (#completed(_)) return #err(#alreadyStarted);
                case (#scheduled(d)) d;
            };

            let inProgressMatches = scheduledMatchGroup.matches.vals()
            |> Iter.map(
                _,
                func(m : Season.ScheduledMatch) : Season.InProgressMatch {
                    let team1Data = getTeamData(m.team1.id);
                    let team2Data = getTeamData(m.team2.id);
                    {
                        team1 = team1Data;
                        team2 = team2Data;
                    };
                },
            )
            |> Iter.toArray(_);
            Timer.cancelTimer(scheduledMatchGroup.timerId); // Cancel timer incase the match group was forced early

            let inProgressMatchGroup = {
                time = scheduledMatchGroup.time;
                matches = inProgressMatches;
            };
            let ?newMatchGroups = Util.arrayUpdateElementSafe<Season.InProgressSeasonMatchGroupVariant>(
                season.matchGroups,
                matchGroupId,
                #inProgress(inProgressMatchGroup),
            ) else return #err(#matchGroupNotFound);
            seasonStatus := #inProgress({
                season with
                matchGroups = newMatchGroups;
            });
            for (event in events.onMatchGroupStart.vals()) {
                event<system>(matchGroupId, season, inProgressMatchGroup, inProgressMatches);
            };

            #ok;
        };

        resetTimers<system>();
    };

};
