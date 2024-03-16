import Season "../models/Season";
import Types "Types";
import Team "../models/Team";
import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Nat32 "mo:base/Nat32";
import Trie "mo:base/Trie";
import Prelude "mo:base/Prelude";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Timer "mo:base/Timer";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Error "mo:base/Error";
import Order "mo:base/Order";
import ScheduleBuilder "ScheduleBuilder";
import PseudoRandomX "mo:random/PseudoRandomX";
import PlayerTypes "../players/Types";
import StadiumTypes "../stadium/Types";
import Util "../Util";
import MatchAura "../models/MatchAura";
import IterTools "mo:itertools/Iter";
import PlayersActor "canister:players";
import Player "../models/Player";
import FieldPosition "../models/FieldPosition";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type StableData = {
        seasonStatus : Season.SeasonStatus;
        teamStandings : ?[Types.TeamStandingInfo]; // First team to last team
    };
    public type StartSeasonResult = {
        #ok;
        #alreadyStarted;
        #noStadiumsExist;
        #noTeams;
        #oddNumberOfTeams;
    };

    public type EventHandler = {
        onSeasonStart : (Season.InProgressSeason) -> async* ();
        onMatchGroupSchedule : (matchGroupId : Nat, matchGroup : Season.ScheduledMatchGroup) -> async* ();
        onMatchGroupStart : (matchGroupId : Nat, matchGroup : Season.InProgressMatchGroup) -> async* ();
        onMatchGroupComplete : (matchGroupId : Nat, matchGroup : Season.CompletedMatchGroup) -> async* ();
        onSeasonComplete : (Season.CompletedSeason) -> async* ();
    };

    public class SeasonHandler<system>(data : StableData, eventHandler : EventHandler) {
        public var seasonStatus : Season.SeasonStatus = data.seasonStatus;

        // First team to last team
        public var teamStandings : ?Buffer.Buffer<Types.TeamStandingInfo> = switch (data.teamStandings) {
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
            stadiumId : Principal,
            startTime : Time.Time,
            teams : [Team.TeamWithId],
            players : [PlayerTypes.PlayerWithId],
        ) : async* StartSeasonResult {
            switch (seasonStatus) {
                case (#notStarted) {};
                case (#starting) return #alreadyStarted;
                case (#inProgress(_)) return #alreadyStarted;
                case (#completed(completedSeason)) {
                    // TODO archive completed season?
                };
            };
            teamStandings := null;
            seasonStatus := #starting;

            let teamIdsBuffer = teams
            |> Iter.fromArray(_)
            |> Iter.map(_, func(t : Team.TeamWithId) : Nat = t.id)
            |> Buffer.fromIter<Nat>(_);

            prng.shuffleBuffer(teamIdsBuffer); // Randomize the team order

            let timeBetweenMatchGroups = #minutes(2);
            // let timeBetweenMatchGroups = #days(1); // TODO revert
            let buildResult = ScheduleBuilder.build(
                startTime,
                Buffer.toArray(teamIdsBuffer),
                timeBetweenMatchGroups,
            );

            let schedule : ScheduleBuilder.SeasonSchedule = switch (buildResult) {
                case (#ok(schedule)) schedule;
                case (#noTeams) {
                    seasonStatus := #notStarted;
                    return #noTeams;
                };
                case (#oddNumberOfTeams) {
                    seasonStatus := #notStarted;
                    return #oddNumberOfTeams;
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
                func(t : Team.TeamWithId) : Season.TeamInfo {
                    buildTeamInitData(t, players);
                },
            )
            |> Iter.toArray(_);

            let inProgressSeason = {
                teams = teamsWithPositions;
                players = players;
                stadiumId = stadiumId;
                matchGroups = notScheduledMatchGroups;
            };

            teamStandings := null; // No standings yet
            seasonStatus := #inProgress(inProgressSeason);
            await* eventHandler.onSeasonStart(inProgressSeason);
            // Get first match group to open
            let #notScheduled(firstMatchGroup) = notScheduledMatchGroups[0] else Prelude.unreachable();

            await* scheduleMatchGroup<system>(
                0,
                stadiumId,
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
                    for (i in Iter.range(0, inProgressSeason.matchGroups.size())) {
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
                case (#inProgress(inProgressSeason)) ?{
                    matchGroupId = matchGroupId;
                    matchGroup = inProgressSeason.matchGroups[matchGroupId];
                    season = #inProgress(inProgressSeason);
                };
                case (#completed(c)) ?{
                    matchGroupId = matchGroupId;
                    matchGroup = #completed(c.matchGroups[matchGroupId]);
                    season = #completed(c);
                };
            };
        };

        public func onMatchGroupComplete<system>(
            request : Types.OnMatchGroupCompleteRequest,
            prng : Prng,
        ) : async* Types.OnMatchGroupCompleteResult {

            let #inProgress(season) = seasonStatus else return #seasonNotOpen;
            // Get current match group
            let ?matchGroup = Util.arrayGetSafe<Season.InProgressSeasonMatchGroupVariant>(
                season.matchGroups,
                request.id,
            ) else return #matchGroupNotFound;
            let inProgressMatchGroup = switch (matchGroup) {
                case (#inProgress(matchGroupState)) matchGroupState;
                case (_) return #matchGroupNotInProgress;
            };

            // Update status to completed
            let updatedMatchGroup : Season.CompletedMatchGroup = {
                time = inProgressMatchGroup.time;
                matches = request.matches;
            };

            let ?newMatchGroups = Util.arrayUpdateElementSafe<Season.InProgressSeasonMatchGroupVariant>(
                season.matchGroups,
                request.id,
                #completed(updatedMatchGroup),
            ) else return #matchGroupNotFound;

            let completedMatchGroups = Buffer.Buffer<Season.CompletedMatchGroup>(season.matchGroups.size());
            label f for (matchGroup in Iter.fromArray(newMatchGroups)) {
                switch (matchGroup) {
                    case (#completed(completedMatchGroup)) completedMatchGroups.add(completedMatchGroup);
                    case (_) break f; // Break on first incomplete match
                };
            };

            let updatedTeamStandings : Buffer.Buffer<Types.TeamStandingInfo> = calculateTeamStandings(Buffer.toArray(completedMatchGroups));

            let updatedSeason = {
                season with
                matchGroups = newMatchGroups;
            };
            teamStandings := ?updatedTeamStandings;
            seasonStatus := #inProgress(updatedSeason);
            await* eventHandler.onMatchGroupComplete(request.id, updatedMatchGroup);
            try {
                await PlayersActor.addMatchStats(request.id, request.playerStats);
            } catch (err) {
                Debug.print("Failed to award user points: " # Error.message(err) # "\nStats: " # debug_show (request.playerStats));
            };

            // Get next match group to schedule
            let nextMatchGroupId = request.id + 1;
            let ?nextMatchGroup = Util.arrayGetSafe<Season.InProgressSeasonMatchGroupVariant>(
                updatedSeason.matchGroups,
                nextMatchGroupId,
            ) else {
                // Season is over because cant find more match groups
                try {
                    ignore await* close(); // TODO how to not await this?
                } catch (err) {
                    Debug.print("Failed to close season: " # Error.message(err));
                };
                return #ok;
            };
            switch (nextMatchGroup) {
                case (#notScheduled(matchGroup)) {
                    // Schedule next match group
                    await* scheduleMatchGroup<system>(
                        nextMatchGroupId,
                        inProgressMatchGroup.stadiumId,
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

        public func close() : async* Types.CloseSeasonResult {

            if (seasonStatus == #starting) {
                // TODO how to handle this?
                seasonStatus := #notStarted;
                return #ok;
            };
            let #inProgress(inProgressSeason) = seasonStatus else return #seasonNotOpen;
            let completedMatchGroups = switch (buildCompletedMatchGroups(inProgressSeason)) {
                case (#ok(completedMatchGroups)) completedMatchGroups;
                case (#matchGroupsNotComplete(inProgressMatchGroup)) {
                    // TODO put in bad state vs delete
                    seasonStatus := #notStarted;
                    switch (inProgressMatchGroup) {
                        case (null) ();
                        case (?inProgressMatchGroup) {
                            // Cancel live match
                            let stadiumActor = actor (Principal.toText(inProgressMatchGroup.stadiumId)) : StadiumTypes.StadiumActor;
                            switch (await stadiumActor.cancelMatchGroup({ id = inProgressMatchGroup.matchGroupId })) {
                                case (#ok or #matchGroupNotFound) ();
                            };
                        };
                    };
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
                    |> IterTools.findIndex(_, func(s : Types.TeamStandingInfo) : Bool = s.id == t.id) else Debug.trap("Team not found in standings: " # Nat.toText(t.id));
                    let standingInfo = finalTeamStandings.get(standingIndex);

                    {
                        id = t.id;
                        name = t.name;
                        logoUrl = t.logoUrl;
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
                        let ?teamStanding = IterTools.findIndex(finalTeamStandings.vals(), func(s : Types.TeamStandingInfo) : Bool = s.id == teamId) else Debug.trap("Team not found in standings: " # Nat.toText(teamId));
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
            await* eventHandler.onSeasonComplete(completedSeason);
            #ok;
        };

        private func resetTimers<system>() {
            switch (seasonStatus) {
                case (#notStarted or #starting) ();
                case (#inProgress(inProgressSeason)) {
                    for (i in Iter.range(0, inProgressSeason.matchGroups.size())) {
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
                    let result = try {
                        await* startMatchGroup<system>(matchGroupId);
                    } catch (err) {
                        Debug.print("Match group '" # Nat.toText(matchGroupId) # "' start callback failed: " # Error.message(err));
                        return;
                    };
                    let message = switch (result) {
                        case (#ok) "Match group started";
                        case (#matchGroupNotFound) "Match group not found";
                        case (#notAuthorized) "Not authorized";
                        case (#notScheduledYet) "Match group not scheduled yet";
                        case (#alreadyStarted) "Match group already started";
                        case (#matchErrors(errors)) "Match group errors: " # debug_show (errors);
                    };
                    Debug.print("Match group '" # Nat.toText(matchGroupId) # "' start callback: " # message);
                },
            );
        };

        private func scheduleMatchGroup<system>(
            matchGroupId : Nat,
            stadiumId : Principal,
            matchGroup : Season.NotScheduledMatchGroup,
            inProgressSeason : Season.InProgressSeason,
            prng : Prng,
        ) : async* () {
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
                stadiumId = stadiumId;
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
                            aura = getRandomMatchAura(prng);
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
            await* eventHandler.onMatchGroupSchedule(matchGroupId, scheduledMatchGroup);

        };

        private func buildCompletedMatchGroups(
            season : Season.InProgressSeason
        ) : {
            #ok : [Season.CompletedMatchGroup];
            #matchGroupsNotComplete : ?{
                matchGroupId : Nat;
                stadiumId : Principal;
            };
        } {
            let completedMatchGroups = Buffer.Buffer<Season.CompletedMatchGroup>(season.matchGroups.size());
            var matchGroupId = 0;
            for (matchGroup in Iter.fromArray(season.matchGroups)) {
                let completedMatchGroup = switch (matchGroup) {
                    case (#completed(completedMatchGroup)) completedMatchGroup;
                    case (#notScheduled(_)) return #matchGroupsNotComplete(null);
                    case (#scheduled(_)) return #matchGroupsNotComplete(null);
                    case (#inProgress(inProgressMatchGroup)) return #matchGroupsNotComplete(
                        ?{
                            matchGroupId = matchGroupId;
                            stadiumId = inProgressMatchGroup.stadiumId;
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
        ) : Buffer.Buffer<Types.TeamStandingInfo> {
            var teamScores = Trie.empty<Nat, Types.TeamStandingInfo>();
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
                let (newTeamScores, _) = Trie.put<Nat, Types.TeamStandingInfo>(
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
                func((_, v) : (Nat, Types.TeamStandingInfo)) : Types.TeamStandingInfo = v,
            )
            |> IterTools.sort(
                _,
                func(a : Types.TeamStandingInfo, b : Types.TeamStandingInfo) : Order.Order {
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

        public func startMatchGroup(
            matchGroupId : Nat
        ) : async* Types.StartMatchGroupResult {
            let #inProgress(season) = seasonStatus else return #matchGroupNotFound;

            // Get current match group
            let ?matchGroupVariant = Util.arrayGetSafe(
                season.matchGroups,
                matchGroupId,
            ) else return #matchGroupNotFound;

            let scheduledMatchGroup : Season.ScheduledMatchGroup = switch (matchGroupVariant) {
                case (#notScheduled(_)) return #notScheduledYet;
                case (#inProgress(_)) return #alreadyStarted;
                case (#completed(_)) return #alreadyStarted;
                case (#scheduled(d)) d;
            };

            let matchStartRequestBuffer = Buffer.Buffer<StadiumTypes.StartMatchRequest>(scheduledMatchGroup.matches.size());

            let teamDataMap = HashMap.HashMap<Nat, StadiumTypes.StartMatchTeam>(0, Nat.equal, Nat32.fromNat);

            let getPlayer = func(playerId : Nat32) : Player.PlayerWithId {
                let ?player = season.players
                |> Iter.fromArray(_)
                |> IterTools.find(_, func(p : Player.PlayerWithId) : Bool = p.id == playerId) else Debug.trap("Player not found: " # Nat32.toText(playerId));
                player;
            };
            for (team in season.teams.vals()) {
                let teamData : StadiumTypes.StartMatchTeam = {
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
                    aura = match.aura.aura;
                });
            };
            let startMatchGroupRequest : StadiumTypes.StartMatchGroupRequest = {
                id = matchGroupId;
                matches = Buffer.toArray(matchStartRequestBuffer);
            };
            let stadiumActor = actor (Principal.toText(scheduledMatchGroup.stadiumId)) : StadiumTypes.StadiumActor;
            try {
                switch (await stadiumActor.startMatchGroup(startMatchGroupRequest)) {
                    case (#ok) ();
                    case (#noMatchesSpecified) Debug.trap("No matches specified for match group " # Nat.toText(matchGroupId));
                };
            } catch (err) {
                Debug.trap("Failed to start match group in stadium: " # Error.message(err));
            };
            // TODO this should better handled in case of failure to start the match
            let inProgressMatches = startMatchGroupRequest.matches
            |> Iter.fromArray(_)
            |> IterTools.mapEntries(
                _,
                func(matchId : Nat, match : StadiumTypes.StartMatchRequest) : Season.InProgressMatch {
                    let mapTeam = func(
                        teamData : StadiumTypes.StartMatchTeam
                    ) : Season.InProgressTeam {
                        {
                            id = teamData.id;
                        };
                    };
                    {
                        team1 = mapTeam(match.team1);
                        team2 = mapTeam(match.team2);
                        aura = match.aura;
                    };
                },
            )
            |> Iter.toArray(_);

            let inProgressMatchGroup = {
                time = scheduledMatchGroup.time;
                stadiumId = scheduledMatchGroup.stadiumId;
                matches = inProgressMatches;
            };
            let ?newMatchGroups = Util.arrayUpdateElementSafe<Season.InProgressSeasonMatchGroupVariant>(
                season.matchGroups,
                matchGroupId,
                #inProgress(inProgressMatchGroup),
            ) else return #matchGroupNotFound;
            seasonStatus := #inProgress({
                season with
                matchGroups = newMatchGroups;
            });
            await* eventHandler.onMatchGroupStart(matchGroupId, inProgressMatchGroup);

            #ok;
        };

        ignore resetTimers<system>();
    };

    private func buildTeamInitData(
        team : Team.TeamWithId,
        allPlayers : [PlayerTypes.PlayerWithId],
    ) : Season.TeamInfo {

        let teamPlayers = allPlayers
        |> Iter.fromArray(_)
        |> IterTools.mapFilter(
            _,
            func(p : PlayerTypes.PlayerWithId) : ?Player.PlayerWithId {
                if (p.teamId != team.id) {
                    null;
                } else {
                    ?{
                        p with
                        teamId = team.id
                    };
                };
            },
        )
        |> Iter.toArray(_);

        let getPosition = func(position : FieldPosition.FieldPosition) : Nat32 {
            let playerOrNull = teamPlayers
            |> Iter.fromArray(_)
            |> IterTools.find(_, func(p : Player.PlayerWithId) : Bool = p.position == position);
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

    private func getRandomMatchAura(prng : Prng) : MatchAura.MatchAuraWithMetaData {
        // TODO
        let auras = Buffer.fromArray<MatchAura.MatchAura>([
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
        prng.shuffleBuffer(auras);
        let aura = auras.get(0);
        {
            MatchAura.getMetaData(aura) with
            aura = aura;
        };
    };

};
