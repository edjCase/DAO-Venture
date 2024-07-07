import Season "../models/Season";
import Team "../models/Team";
import HashMap "mo:base/HashMap";
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
import FieldPosition "../models/FieldPosition";
import Components "mo:datetime/Components";

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

    public type StableData = {
        seasonStatus : Season.SeasonStatus;
        teamStandings : ?[TeamStandingInfo]; // First team to last team
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
        anomoly : Anomoly.Anomoly;
    };

    public type Events = {
        onSeasonStart : Buffer.Buffer<OnSeasonStartEvent>;
        onMatchGroupSchedule : Buffer.Buffer<OnMatchGroupScheduleEvent>;
        onMatchGroupStart : Buffer.Buffer<OnMatchGroupStartEvent>;
        onMatchGroupComplete : Buffer.Buffer<OnMatchGroupCompleteEvent>;
        onSeasonComplete : Buffer.Buffer<OnSeasonCompleteEvent>;
    };

    public type OnSeasonScheduleEvent = <system>(season : Season.InProgressSeason) -> ();
    public type OnSeasonStartEvent = <system>(season : Season.InProgressSeason) -> ();
    public type OnMatchGroupScheduleEvent = <system>(matchGroupId : Nat, matchGroup : Season.ScheduledMatchGroup) -> ();
    public type OnMatchGroupStartEvent = <system>(
        matchGroupId : Nat,
        season : Season.InProgressSeason,
        matchGroup : Season.InProgressMatchGroup,
        matches : [Season.InProgressMatch],
    ) -> ();
    public type OnMatchGroupCompleteEvent = <system>(matchGroupId : Nat, matchGroup : Season.CompletedMatchGroup) -> ();
    public type OnSeasonCompleteEvent = <system>(season : Season.CompletedSeason) -> ();

    public type EndedSeasonVariant = {
        #incomplete : Season.InProgressSeason;
        #completed : Season.CompletedSeason;
    };

    public class SeasonHandler<system>(
        data : StableData,
        events : Events,
    ) {

        public var seasonStatus : Season.SeasonStatus = data.seasonStatus;

        // First team to last team
        public var teamStandings : ?Buffer.Buffer<TeamStandingInfo> = switch (data.teamStandings) {
            case (null) null;
            case (?standings) ?Buffer.fromArray(standings);
        };

        public func toStableData() : StableData {
            {
                seasonStatus = seasonStatus;
                teamStandings = switch (teamStandings) {
                    case (null) null;
                    case (?standings) ?Buffer.toArray(standings);
                };
            };
        };

        public func startSeason<system>(
            prng : Prng,
            startTime : Time.Time,
            weekDays : [Components.DayOfWeek],
            teams : [Team.Team],
            players : [Player.Player],
        ) : StartSeasonResult {
            switch (seasonStatus) {
                case (#notStarted) {};
                case (#starting) return #err(#alreadyStarted);
                case (#inProgress(_)) return #err(#alreadyStarted);
                case (#completed(completedSeason)) {
                    // TODO archive completed season?
                };
            };
            teamStandings := null;
            seasonStatus := #starting;

            let teamIdsBuffer = teams
            |> Iter.fromArray(_)
            |> Iter.map(_, func(t : Team.Team) : Nat = t.id)
            |> Buffer.fromIter<Nat>(_);

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

            let teamsWithPositions = teams
            |> Iter.fromArray(_)
            |> Iter.map(
                _,
                func(t : Team.Team) : Season.TeamInfo {
                    buildTeamInitData(t, players);
                },
            )
            |> Iter.toArray(_);

            let inProgressSeason = {
                teams = teamsWithPositions;
                players = players;
                matchGroups = notScheduledMatchGroups;
            };

            teamStandings := null; // No standings yet
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
                prng,
            );
            #ok;
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
            prng : Prng,
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

            let completedMatchGroups = Buffer.Buffer<Season.CompletedMatchGroup>(season.matchGroups.size());
            label f for (matchGroup in Iter.fromArray(newMatchGroups)) {
                switch (matchGroup) {
                    case (#completed(completedMatchGroup)) completedMatchGroups.add(completedMatchGroup);
                    case (_) break f; // Break on first incomplete match
                };
            };

            let updatedTeamStandings : Buffer.Buffer<TeamStandingInfo> = calculateTeamStandings(Buffer.toArray(completedMatchGroups));

            let updatedSeason = {
                season with
                matchGroups = newMatchGroups;
            };
            teamStandings := ?updatedTeamStandings;
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
                        prng,
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
            let finalTeamStandings = calculateTeamStandings(completedMatchGroups);
            let completedTeams = inProgressSeason.teams
            |> Iter.fromArray(_)
            |> Iter.map(
                _,
                func(t : Season.TeamInfo) : Season.CompletedSeasonTeam {
                    let ?standingIndex = finalTeamStandings.vals()
                    |> IterTools.findIndex(_, func(s : TeamStandingInfo) : Bool = s.id == t.id) else Debug.trap("Team not found in standings: " # Nat.toText(t.id));
                    let standingInfo = finalTeamStandings.get(standingIndex);

                    {
                        id = t.id;
                        name = t.name;
                        logoUrl = t.logoUrl;
                        color = t.color;
                        wins = standingInfo.wins;
                        losses = standingInfo.losses;
                        totalScore = standingInfo.totalScore;
                        positions = t.positions;
                    };
                },
            )
            |> Iter.toArray(_);

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

            teamStandings := ?finalTeamStandings;
            let completedSeason = {
                championTeamId = champion.id;
                runnerUpTeamId = runnerUp.id;
                teams = completedTeams;
                matchGroups = completedMatchGroups;
            };
            seasonStatus := #completed(completedSeason);
            for (event in events.onSeasonComplete.vals()) {
                event<system>(completedSeason);
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
            prng : Prng,
        ) : () {
            let timerId = createStartTimer<system>(matchGroupId, matchGroup.time);

            let getTeamId = func(teamAssignment : Season.TeamAssignment) : Nat {
                switch (teamAssignment) {
                    case (#predetermined(teamId)) teamId;
                    case (#seasonStandingIndex(standingIndex)) {
                        // get team based on current season standing
                        let ?standings = teamStandings else Debug.trap("Season standings not found. Match Group Id: " # Nat.toText(matchGroupId));

                        let ?teamWithStanding = standings.getOpt(standingIndex) else Debug.trap("Standing not found. Standings: " # debug_show (Buffer.toArray(standings)) # " Standing index: " # Nat.toText(standingIndex));

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
                            anomoly = getRandomAnomoly(prng);
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

        private func calculateTeamStandings(
            matchGroups : [Season.CompletedMatchGroup]
        ) : Buffer.Buffer<TeamStandingInfo> {
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
            |> Buffer.fromIter(_);
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

            let matchStartRequestBuffer = Buffer.Buffer<StartMatchRequest>(scheduledMatchGroup.matches.size());

            let teamDataMap = HashMap.HashMap<Nat, StartMatchTeam>(0, Nat.equal, Nat32.fromNat);

            let getPlayer = func(playerId : Nat32) : Player.Player {
                let ?player = season.players
                |> Iter.fromArray(_)
                |> IterTools.find(_, func(p : Player.Player) : Bool = p.id == playerId) else Debug.trap("Player not found: " # Nat32.toText(playerId));
                player;
            };
            for (team in season.teams.vals()) {
                let teamData : StartMatchTeam = {
                    team with
                    positions = {
                        pitcher = getPlayer(team.positions.pitcher);
                        firstBase = getPlayer(team.positions.firstBase);
                        secondBase = getPlayer(team.positions.secondBase);
                        thirdBase = getPlayer(team.positions.thirdBase);
                        shortStop = getPlayer(team.positions.shortStop);
                        leftField = getPlayer(team.positions.leftField);
                        centerField = getPlayer(team.positions.centerField);
                        rightField = getPlayer(team.positions.rightField);
                    };
                };
                teamDataMap.put(team.id, teamData);
            };

            for (match in Iter.fromArray(scheduledMatchGroup.matches)) {
                let ?team1Data = teamDataMap.get(match.team1.id) else Debug.trap("Team data not found: " # Nat.toText(match.team1.id));
                let ?team2Data = teamDataMap.get(match.team2.id) else Debug.trap("Team data not found: " # Nat.toText(match.team2.id));
                matchStartRequestBuffer.add({
                    team1 = team1Data;
                    team2 = team2Data;
                    anomoly = match.anomoly.anomoly;
                });
            };
            let matches = Buffer.toArray(matchStartRequestBuffer);
            Timer.cancelTimer(scheduledMatchGroup.timerId); // Cancel timer incase the match group was forced early
            // TODO this should better handled in case of failure to start the match
            let inProgressMatches = matches
            |> Iter.fromArray(_)
            |> IterTools.mapEntries(
                _,
                func(matchId : Nat, match : StartMatchRequest) : Season.InProgressMatch {
                    let mapTeam = func(
                        teamData : StartMatchTeam
                    ) : Season.InProgressTeam {
                        {
                            id = teamData.id;
                        };
                    };
                    {
                        team1 = mapTeam(match.team1);
                        team2 = mapTeam(match.team2);
                        anomoly = match.anomoly;
                    };
                },
            )
            |> Iter.toArray(_);

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

    private func buildTeamInitData(
        team : Team.Team,
        allPlayers : [Player.Player],
    ) : Season.TeamInfo {

        let teamPlayers = allPlayers
        |> Iter.fromArray(_)
        |> Iter.filter(
            _,
            func(p : Player.Player) : Bool = p.teamId == team.id,
        )
        |> Iter.toArray(_);

        let getPosition = func(position : FieldPosition.FieldPosition) : Nat32 {
            let playerOrNull = teamPlayers
            |> Iter.fromArray(_)
            |> IterTools.find(_, func(p : Player.Player) : Bool = p.position == position);
            switch (playerOrNull) {
                case (null) Debug.trap("Team " # Nat.toText(team.id) # " is missing a player in position: " # debug_show (position)); // TODO
                case (?player) player.id;
            };
        };

        let pitcher = getPosition(#pitcher);
        let firstBase = getPosition(#firstBase);
        let secondBase = getPosition(#secondBase);
        let thirdBase = getPosition(#thirdBase);
        let shortStop = getPosition(#shortStop);
        let leftField = getPosition(#leftField);
        let centerField = getPosition(#centerField);
        let rightField = getPosition(#rightField);
        {
            id = team.id;
            name = team.name;
            logoUrl = team.logoUrl;
            color = team.color;
            positions = {
                pitcher = pitcher;
                firstBase = firstBase;
                secondBase = secondBase;
                thirdBase = thirdBase;
                shortStop = shortStop;
                leftField = leftField;
                centerField = centerField;
                rightField = rightField;
            };
        };
    };

    private func getRandomAnomoly(prng : Prng) : Anomoly.AnomolyWithMetaData {
        // TODO
        let anomolys = Buffer.fromArray<Anomoly.Anomoly>([
            #lowGravity,
            #explodingBalls,
            #fastBallsHardHits,
            #moreBlessingsAndCurses,
            #moveBasesIn,
            #doubleOrNothing,
            #windy,
            #rainy,
            #foggy,
            #extraStrike,
        ]);
        prng.shuffleBuffer(anomolys);
        let anomoly = anomolys.get(0);
        {
            Anomoly.getMetaData(anomoly) with
            anomoly = anomoly;
        };
    };

};
