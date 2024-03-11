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
import Array "mo:base/Array";
import Text "mo:base/Text";
import Error "mo:base/Error";
import Random "mo:base/Random";
import ScheduleBuilder "ScheduleBuilder";
import PseudoRandomX "mo:random/PseudoRandomX";
import PlayerTypes "../players/Types";
import StadiumTypes "../stadium/Types";
import ScenarioUtil "ScenarioUtil";
import Util "../Util";
import MatchAura "../models/MatchAura";
import IterTools "mo:itertools/Iter";
import TeamTypes "../team/Types";
import PlayersActor "canister:players";
import Player "../models/Player";
import FieldPosition "../models/FieldPosition";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Data = {
        seasonStatus : Season.SeasonStatus;
        teamStandings : ?[Types.TeamStandingInfo]; // First team to last team
    };
    public type StartSeasonResult = {
        #ok;
        #alreadyStarted;
        #noStadiumsExist;
        #noTeams;
        #oddNumberOfTeams;
        #scenarioCountMismatch : {
            expected : Nat;
            actual : Nat;
        };
        #invalidScenario : {
            id : Text;
            errors : [Text];
        };
    };

    public class SeasonState(data : Data) {
        public var seasonStatus : Season.SeasonStatus = data.seasonStatus;

        // First team to last team
        public var teamStandings : ?Buffer.Buffer<Types.TeamStandingInfo> = switch (data.teamStandings) {
            case (null) null;
            case (?standings) ?Buffer.fromArray(standings);
        };

        public func toStableData() : Data {
            {
                seasonStatus = seasonStatus;
                teamStandings = switch (teamStandings) {
                    case (null) null;
                    case (?standings) ?Buffer.toArray(standings);
                };
            };
        };

        public func startSeason(
            prng : Prng,
            stadiumId : Principal,
            request : Types.StartSeasonRequest,
            teams : [Team.TeamWithId],
            players : [PlayerTypes.PlayerWithId],
        ) : StartSeasonResult {
            switch (seasonStatus) {
                case (#notStarted) {};
                case (#starting) return #alreadyStarted;
                case (#inProgress(_)) return #alreadyStarted;
                case (#completed(completedSeason)) {
                    // TODO archive completed season?
                };
            };
            for (scenario in Iter.fromArray(request.scenarios)) {
                switch (ScenarioUtil.validateScenario(scenario, [])) {
                    case (#ok) ();
                    case (#invalid(errors)) return #invalidScenario({
                        id = scenario.id;
                        errors = errors;
                    });
                };
            };

            teamStandings := null;
            seasonStatus := #starting;

            let teamIdsBuffer = teams
            |> Iter.fromArray(_)
            |> Iter.map(_, func(t : Team.TeamWithId) : Principal = t.id)
            |> Buffer.fromIter<Principal>(_);

            prng.shuffleBuffer(teamIdsBuffer); // Randomize the team order

            let timeBetweenMatchGroups = #minutes(2);
            // let timeBetweenMatchGroups = #days(1); // TODO revert
            let buildResult = ScheduleBuilder.build(
                request.startTime,
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
            if (request.scenarios.size() != schedule.matchGroups.size()) {
                // TODO this feels frail
                return #scenarioCountMismatch({
                    expected = schedule.matchGroups.size();
                    actual = request.scenarios.size();
                });
            };

            let teamsMap = teams
            |> Iter.fromArray(_)
            |> Iter.map<Team.TeamWithId, (Principal, Team.TeamWithId)>(
                _,
                func(t : Team.TeamWithId) : (Principal, Team.TeamWithId) = (t.id, t),
            )
            |> HashMap.fromIter<Principal, Team.TeamWithId>(_, teams.size(), Principal.equal, Principal.hash);
            var scenarioIndex = 0;
            // Save full schedule, then try to start the first match groups
            let notScheduledMatchGroups = schedule.matchGroups
            |> Iter.fromArray(_)
            |> Iter.map(
                _,
                func(mg : ScheduleBuilder.MatchGroup) : Season.InProgressSeasonMatchGroupVariant = #notScheduled({
                    time = mg.time;
                    scenarioId = request.scenarios[scenarioIndex].id;
                    matches = mg.matches
                    |> Iter.fromArray(_)
                    |> Iter.map(
                        _,
                        func(m : ScheduleBuilder.Match) : Season.NotScheduledMatch = {
                            team1 = getMatchTeamInfo(m.team1, teamsMap);
                            team2 = getMatchTeamInfo(m.team2, teamsMap);
                        },
                    )
                    |> Iter.toArray(_);
                }),
            )
            |> Iter.toArray(_);

            let inProgressSeason = {
                matchGroups = notScheduledMatchGroups;
            };

            teamStandings := null; // No standings yet
            seasonStatus := #inProgress(inProgressSeason);
            // Get first match group to open
            let #notScheduled(firstMatchGroup) = notScheduledMatchGroups[0] else Prelude.unreachable();

            scheduleMatchGroup(
                0,
                stadiumId,
                firstMatchGroup,
                inProgressSeason,
                teamsMap,
                players,
                prng,
            );
            #ok;
        };

        private func scheduleMatchGroup(
            matchGroupId : Nat,
            stadiumId : Principal,
            matchGroup : Season.NotScheduledMatchGroup,
            inProgressSeason : Season.InProgressSeason,
            teamsMap : HashMap.HashMap<Principal, Team.TeamWithId>,
            allPlayers : [PlayerTypes.PlayerWithId],
            prng : Prng,
        ) : () {
            let timeDiff = matchGroup.time - Time.now();
            Debug.print("Scheduling match group " # Nat.toText(matchGroupId) # " in " # Int.toText(timeDiff) # " nanoseconds");
            let duration = if (timeDiff <= 0) {
                // Schedule immediately
                #nanoseconds(0);
            } else {
                #nanoseconds(Int.abs(timeDiff));
            };
            let timerId = Timer.setTimer(
                duration,
                func() : async () {
                    let result = try {
                        let prng = PseudoRandomX.fromBlob(await Random.blob());
                        await startMatchGroup(matchGroupId, stadiumId, prng, teamsMap);
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

            let compileTeamInfo = func(teamAssignment : Season.TeamAssignment) : Season.TeamInfo {
                switch (teamAssignment) {
                    case (#predetermined(teamInfo)) teamInfo;
                    case (#seasonStandingIndex(standingIndex)) {
                        // get team based on current season standing
                        let ?standings = teamStandings else Debug.trap("Season standings not found. Match Group Id: " # Nat.toText(matchGroupId));

                        let ?teamWithStanding = standings.getOpt(standingIndex) else Debug.trap("Standing not found. Standings: " # debug_show (Buffer.toArray(standings)) # " Standing index: " # Nat.toText(standingIndex));

                        let ?team = teamsMap.get(teamWithStanding.id) else Debug.trap("Team not found. Team Id: " # Principal.toText(teamWithStanding.id));

                        team;
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
                            match.team1;
                        } else {
                            match.team2;
                        };
                    };
                };
            };

            let scheduledMatchGroup : Season.ScheduledMatchGroup = {
                time = matchGroup.time;
                timerId = timerId;
                scenarioId = matchGroup.scenarioId;
                matches = matchGroup.matches
                |> Iter.fromArray(_)
                |> Iter.map(
                    _,
                    func(m : Season.NotScheduledMatch) : Season.ScheduledMatch {
                        let team1 = compileTeamInfo(m.team1);
                        let team2 = compileTeamInfo(m.team2);

                        {
                            team1 = team1;
                            team2 = team2;
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
            let matchCount = scheduledMatchGroup.matches.size();

        };

        private func startMatchGroup(
            matchGroupId : Nat,
            stadiumId : Principal,
            prng : Prng,
            teams : HashMap.HashMap<Principal, Team.TeamWithId>,
        ) : async Types.StartMatchGroupResult {
            let allPlayers = await PlayersActor.getAllPlayers();
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

            let teamDataMap = HashMap.HashMap<Principal, StadiumTypes.StartMatchTeam and { option : Nat }>(0, Principal.equal, Principal.hash);
            for (team in teams.vals()) {
                let teamActor = actor (Principal.toText(team.id)) : TeamTypes.TeamActor;
                let options : TeamTypes.ScenarioVoteResult = try {
                    // Get match options from the team itself
                    let result : TeamTypes.GetWinningScenarioOptionResult = await teamActor.getWinningScenarioOption({
                        scenarioId = scheduledMatchGroup.scenarioId;
                    });
                    let option = switch (result) {
                        case (#ok(o)) o;
                        case (#noVotes) {
                            // If no votes, pick a random choice
                            let option : Nat = 0; // TODO
                            option;
                        };
                        case (#scenarioNotFound) return Debug.trap("Scenario not found: " # scheduledMatchGroup.scenarioId);
                        case (#notAuthorized) return Debug.trap("League is not authorized to get match options from team: " # Principal.toText(team.id));
                    };
                    {
                        option = option;
                    };
                } catch (err : Error.Error) {
                    return Debug.trap("Failed to get team '" # Principal.toText(team.id) # "': " # Error.message(err));
                };
                let teamData = buildTeamInitData(team, allPlayers, prng);
                teamDataMap.put(
                    team.id,
                    {
                        teamData with option = options.option;
                    },
                );
            };

            let scenarioTeamData = teamDataMap.vals()
            |> Iter.map(
                _,
                func(t : StadiumTypes.StartMatchTeam and { option : Nat }) : ScenarioUtil.Team = {
                    t with
                    positions = {
                        firstBase = t.positions.firstBase.id;
                        secondBase = t.positions.secondBase.id;
                        thirdBase = t.positions.thirdBase.id;
                        shortStop = t.positions.shortStop.id;
                        leftField = t.positions.leftField.id;
                        centerField = t.positions.centerField.id;
                        rightField = t.positions.rightField.id;
                        pitcher = t.positions.pitcher.id;
                    };
                },
            )
            |> Iter.toArray(_);

            for (match in Iter.fromArray(scheduledMatchGroup.matches)) {
                let ?team1Data = teamDataMap.get(match.team1.id) else Debug.trap("Team data not found: " # Principal.toText(match.team1.id));
                let ?team2Data = teamDataMap.get(match.team2.id) else Debug.trap("Team data not found: " # Principal.toText(match.team2.id));
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
            let stadiumActor = actor (Principal.toText(stadiumId)) : StadiumTypes.StadiumActor;
            try {
                switch (await stadiumActor.startMatchGroup(startMatchGroupRequest)) {
                    case (#ok) ();
                    case (#noMatchesSpecified) Debug.trap("No matches specified for match group " # Nat.toText(matchGroupId));
                };
            } catch (err) {
                Debug.trap("Failed to start match group in stadium: " # Error.message(err));
            };
            // TODO this should better handled in case of failure to start the match
            let inProgressMatches = scheduledMatchGroup.matches
            |> Iter.fromArray(_)
            |> IterTools.zip(_, Iter.fromArray(startMatchGroupRequest.matches))
            |> IterTools.mapEntries(
                _,
                func(matchId : Nat, match : (Season.ScheduledMatch, StadiumTypes.StartMatchRequest)) : Season.InProgressMatch {
                    let mapTeam = func(
                        team : Season.TeamInfo,
                        teamData : StadiumTypes.StartMatchTeam,
                    ) : Season.InProgressTeam {
                        {
                            id = team.id;
                            name = team.name;
                            logoUrl = team.logoUrl;
                            positions = {
                                firstBase = teamData.positions.firstBase.id;
                                secondBase = teamData.positions.secondBase.id;
                                thirdBase = teamData.positions.thirdBase.id;
                                shortStop = teamData.positions.shortStop.id;
                                leftField = teamData.positions.leftField.id;
                                centerField = teamData.positions.centerField.id;
                                rightField = teamData.positions.rightField.id;
                                pitcher = teamData.positions.pitcher.id;
                            };
                        };
                    };
                    {
                        team1 = mapTeam(match.0.team1, match.1.team1);
                        team2 = mapTeam(match.0.team2, match.1.team2);
                        aura = match.0.aura.aura;
                    };
                },
            )
            |> Iter.toArray(_);

            let ?newMatchGroups = Util.arrayUpdateElementSafe<Season.InProgressSeasonMatchGroupVariant>(
                season.matchGroups,
                matchGroupId,
                #inProgress({
                    time = scheduledMatchGroup.time;
                    stadiumId = stadiumId;
                    scenarioId = scheduledMatchGroup.scenarioId;
                    matches = inProgressMatches;
                }),
            ) else return #matchGroupNotFound;
            seasonStatus := #inProgress({
                season with
                matchGroups = newMatchGroups;
            });

            #ok;
        };
    };

    private func buildTeamInitData(
        team : Season.ScheduledTeamInfo,
        allPlayers : [PlayerTypes.PlayerWithId],
        prng : Prng,
    ) : StadiumTypes.StartMatchTeam {

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

        let getPosition = func(position : FieldPosition.FieldPosition) : Player.PlayerWithId {
            let playerOrNull = teamPlayers
            |> Iter.fromArray(_)
            |> IterTools.find(_, func(p : Player.PlayerWithId) : Bool = p.position == position);
            switch (playerOrNull) {
                case (null) Debug.trap("Team " # Principal.toText(team.id) # " is missing a player in position: " # debug_show (position)); // TODO
                case (?player) player;
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
    private func getMatchTeamInfo(team : ScheduleBuilder.Team, teamMap : HashMap.HashMap<Principal, Team.TeamWithId>) : Season.TeamAssignment {
        switch (team) {
            case (#id(teamId)) {
                let ?team = teamMap.get(teamId) else Debug.trap("Team not found: " # Principal.toText(teamId));
                #predetermined(team);
            };
            case (#seasonStandingIndex(standingIndex)) #seasonStandingIndex(standingIndex);
            case (#winnerOfMatch(matchId)) #winnerOfMatch(matchId);
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
