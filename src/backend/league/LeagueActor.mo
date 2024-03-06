import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Prelude "mo:base/Prelude";
import Cycles "mo:base/ExperimentalCycles";
import IterTools "mo:itertools/Iter";
import Hash "mo:base/Hash";
import Player "../models/Player";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Nat "mo:base/Nat";
import StadiumTypes "../stadium/Types";
import Time "mo:base/Time";
import Nat64 "mo:base/Nat64";
import Int "mo:base/Int";
import Buffer "mo:base/Buffer";
import Random "mo:base/Random";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Blob "mo:base/Blob";
import Order "mo:base/Order";
import Timer "mo:base/Timer";
import TrieSet "mo:base/TrieSet";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import PseudoRandomX "mo:random/PseudoRandomX";
import Types "../league/Types";
import Util "../Util";
import ScheduleBuilder "ScheduleBuilder";
import PlayersActor "canister:players";
import UsersActor "canister:users";
import Team "../models/Team";
import TeamTypes "../team/Types";
import Season "../models/Season";
import MatchAura "../models/MatchAura";
import TeamFactoryActor "canister:teamFactory";
import StadiumFactoryActor "canister:stadiumFactory";
import PlayerTypes "../players/Types";
import FieldPosition "../models/FieldPosition";
import UserTypes "../users/Types";
import Scenario "../models/Scenario";
import ScenarioUtil "ScenarioUtil";
import Trait "../models/Trait";

actor LeagueActor {
    type TeamWithId = Team.TeamWithId;
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    stable var admins : TrieSet.Set<Principal> = TrieSet.empty();
    stable var teams : Trie.Trie<Principal, Team.Team> = Trie.empty();
    stable var seasonStatus : Season.SeasonStatus = #notStarted;
    stable var teamStandings : ?[Types.TeamStandingInfo] = null; // First team to last team
    // MatchGroupId => Match Array of UserId => TeamId votes
    stable var predictions : Trie.Trie<Nat, [Trie.Trie<Principal, Team.TeamId>]> = Trie.empty();
    stable var stadiumIdOrNull : ?Principal = null;
    stable var teamFactoryInitialized = false;
    stable var stadiumFactoryInitialized = false;

    public query func getTeams() : async [TeamWithId] {
        getTeamsArray();
    };

    // TODO REMOVE ALL DELETING METHODS
    public shared func clearTeams() : async () {
        teams := Trie.empty();
    };

    public query func getSeasonStatus() : async Season.SeasonStatus {
        seasonStatus;
    };

    public query func getTeamStandings() : async Types.GetTeamStandingsResult {
        switch (teamStandings) {
            case (?standings) return #ok(standings);
            case (null) return #notFound;
        };
    };

    public shared query ({ caller }) func getAdmins() : async [Principal] {
        TrieSet.toArray(admins);
    };

    public shared ({ caller }) func setUserIsAdmin(id : Principal, isAdmin : Bool) : async Types.SetUserIsAdminResult {
        if (Principal.isAnonymous(id)) {
            Debug.trap("Anonymous user is not a valid user");
        };

        // Check to make sure only admins can update other users
        // BUT if there are no admins, skip the check
        if (Trie.size(admins) > 0) {
            let callerIsAdmin = isAdminId(caller);
            if (not callerIsAdmin) {
                return #notAuthorized;
            };
        };
        let newAdmins = if (isAdmin) {
            TrieSet.put(admins, id, Principal.hash(id), Principal.equal);
        } else {
            TrieSet.delete(admins, id, Principal.hash(id), Principal.equal);
        };
        admins := newAdmins;
        #ok;
    };

    public shared ({ caller }) func startSeason(request : Types.StartSeasonRequest) : async Types.StartSeasonResult {
        if (not isAdminId(caller)) {
            return #notAuthorized;
        };
        Debug.print("Starting season");
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
        predictions := Trie.empty();
        seasonStatus := #starting;

        let seedBlob = try {
            await Random.blob();
        } catch (err) {
            seasonStatus := #notStarted;
            return #seedGenerationError(Error.message(err));
        };
        let prng = PseudoRandomX.fromBlob(seedBlob);

        let teamIdsBuffer = teams
        |> Trie.iter(_)
        |> Iter.map(_, func(k : (Principal, Team.Team)) : Principal = k.0)
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
        var scenarioIndex = 0;
        // Save full schedule, then try to start the first match groups
        let notScheduledMatchGroups = schedule.matchGroups
        |> Iter.fromArray(_)
        |> Iter.map(
            _,
            func(mg : ScheduleBuilder.MatchGroup) : Season.InProgressSeasonMatchGroupVariant = #notScheduled({
                time = mg.time;
                scenario = request.scenarios[scenarioIndex];
                matches = mg.matches
                |> Iter.fromArray(_)
                |> Iter.map(
                    _,
                    func(m : ScheduleBuilder.Match) : Season.NotScheduledMatch = {
                        team1 = getMatchTeamInfo(m.team1);
                        team2 = getMatchTeamInfo(m.team2);
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

        let allTeams = getTeamsArray();
        let allPlayers = await PlayersActor.getAllPlayers();

        scheduleMatchGroup(
            0,
            firstMatchGroup,
            inProgressSeason,
            allTeams,
            allPlayers,
            prng,
        );

        #ok;
    };

    public shared ({ caller }) func createTeam(request : Types.CreateTeamRequest) : async Types.CreateTeamResult {
        if (not isAdminId(caller)) {
            return #notAuthorized;
        };
        let nameAlreadyTaken = Trie.some(
            teams,
            func(k : Principal, v : Team.Team) : Bool = v.name == request.name,
        );
        if (nameAlreadyTaken) {
            return #nameTaken;
        };
        if (not teamFactoryInitialized) {
            let #ok = await TeamFactoryActor.setLeague(Principal.fromActor(LeagueActor)) else Debug.trap("Failed to set league on team factory");
            teamFactoryInitialized := true;
        };
        let createTeamResult = try {
            await TeamFactoryActor.createTeamActor(request);
        } catch (err) {
            return #teamFactoryCallError(Error.message(err));
        };
        let teamInfo = switch (createTeamResult) {
            case (#ok(teamInfo)) teamInfo;
        };
        let team : Team.Team = {
            name = request.name;
            logoUrl = request.logoUrl;
            motto = request.motto;
            description = request.description;
            entropy = 0; // TODO
            energy = 0;
            color = request.color;
        };
        let teamKey = buildPrincipalKey(teamInfo.id);
        let (newTeams, _) = Trie.put(teams, teamKey, Principal.equal, team);
        teams := newTeams;

        let populateResult = try {
            await PlayersActor.populateTeamRoster(teamInfo.id);
        } catch (err) {
            return #populateTeamRosterCallError(Error.message(err));
        };
        switch (populateResult) {
            case (#ok(_)) {};
            case (#notAuthorized) {
                Debug.print("Error populating team roster: League is not authorized to populate team roster for team: " # Principal.toText(teamInfo.id));
            };
            case (#noMorePlayers) {
                Debug.print("Error populating team roster: No more players available");
            };
        };
        return #ok(teamInfo.id);
    };

    public shared ({ caller }) func predictMatchOutcome(request : Types.PredictMatchOutcomeRequest) : async Types.PredictMatchOutcomeResult {
        if (Principal.isAnonymous(caller)) {
            return #identityRequired;
        };
        let ?currentMatchGroupId = getCurrentMatchGroupId() else return #predictionsClosed;
        let predictionKey = {
            key = currentMatchGroupId;
            hash = hashNatAsNat32(currentMatchGroupId);
        };
        let ?matchGroupPredictions : ?[Trie.Trie<Principal, Team.TeamId>] = Trie.get(predictions, predictionKey, Nat.equal) else return #predictionsClosed;
        let ?matchPredictions = Util.arrayGetSafe(matchGroupPredictions, Nat32.toNat(request.matchId)) else return #matchNotFound;
        let userKey = buildPrincipalKey(caller);
        let newMatchPredictions : Trie.Trie<Principal, Team.TeamId> = switch (request.winner) {
            case (null) {
                let (newMatchPredictions, _) = Trie.remove(matchPredictions, userKey, Principal.equal);
                newMatchPredictions;
            };
            case (?winningTeamId) {
                let (newMatchPredictions, _) = Trie.put(matchPredictions, userKey, Principal.equal, winningTeamId);
                newMatchPredictions;
            };
        };
        let newMatchGroupPredictions : [Trie.Trie<Principal, Team.TeamId>] = Util.arrayUpdateElement(matchGroupPredictions, Nat32.toNat(request.matchId), newMatchPredictions);
        let (newPredictions, _) = Trie.put(predictions, predictionKey, Nat.equal, newMatchGroupPredictions);
        predictions := newPredictions;
        #ok;
    };

    public shared query ({ caller }) func getUpcomingMatchPredictions() : async Types.UpcomingMatchPredictionsResult {
        let ?currentMatchGroupId = getCurrentMatchGroupId() else return #noUpcomingMatches;
        let predictionKey = {
            key = currentMatchGroupId;
            hash = hashNatAsNat32(currentMatchGroupId);
        };
        let ?matchGroupPredictions = Trie.get(predictions, predictionKey, Nat.equal) else return #noUpcomingMatches; // TODO error type?
        let predictionSummaryBuffer = Buffer.Buffer<Types.UpcomingMatchPrediction>(matchGroupPredictions.size());

        for (matchPredictions in Iter.fromArray(matchGroupPredictions)) {
            let matchPredictionSummary = {
                var team1 = 0;
                var team2 = 0;
                var yourVote : ?Team.TeamId = null;
            };
            for ((userId, userPrediction) in Trie.iter(matchPredictions)) {
                switch (userPrediction) {
                    case (#team1) matchPredictionSummary.team1 += 1;
                    case (#team2) matchPredictionSummary.team2 += 1;
                };
                if (userId == caller) {
                    matchPredictionSummary.yourVote := ?userPrediction;
                };
            };
            predictionSummaryBuffer.add({
                team1 = matchPredictionSummary.team1;
                team2 = matchPredictionSummary.team2;
                yourVote = matchPredictionSummary.yourVote;
            });
        };

        #ok(Buffer.toArray(predictionSummaryBuffer));
    };

    public shared ({ caller }) func updateLeagueCanisters() : async Types.UpdateLeagueCanistersResult {
        if (not isAdminId(caller)) {
            return #notAuthorized;
        };
        await TeamFactoryActor.updateCanisters();
        await StadiumFactoryActor.updateCanisters();
        #ok;
    };

    public shared ({ caller }) func processEffectOutcomes(effectOutcomes : [Scenario.EffectOutcome]) : async Types.ProcessEffectOutcomesResult {
        if (not isAdminId(caller)) {
            return #notAuthorized;
        };
        let #inProgress(season) = seasonStatus else return #seasonNotInProgress;
        var updatedSeason = season;

        let playerOutcomes = Buffer.Buffer<Scenario.PlayerEffectOutcome>(effectOutcomes.size());
        for (effectOutcome in Iter.fromArray(effectOutcomes)) {
            switch (effectOutcome) {
                case (#injury(injuryEffect)) playerOutcomes.add(#injury(injuryEffect));
                case (#entropy(entropyEffect)) {
                    updateTeamEntropy(entropyEffect.teamId, entropyEffect.delta);
                };
                case (#energy(e)) {
                    updateTeamEnergy(e.teamId, e.delta);
                };
                case (#skill(s)) {
                    playerOutcomes.add(#skill(s));
                };
            };
        };
        // TODO handle failure
        if (playerOutcomes.size() > 0) {
            let result = try {
                await PlayersActor.applyEffects(Buffer.toArray(playerOutcomes));
            } catch (err) {
                return Debug.trap("Failed to apply traits: " # Error.message(err));
            };
            switch (result) {
                case (#ok) ();
            };
        };
        #ok;
    };

    public shared ({ caller }) func startMatchGroup(matchGroupId : Nat) : async Types.StartMatchGroupResult {
        // TODO
        // if (not isAdminId(caller)) {
        //     return #notAuthorized;
        // };
        let #inProgress(season) = seasonStatus else return #matchGroupNotFound;
        let stadiumId = switch (await* getOrCreateStadium()) {
            case (#ok(id)) id;
            case (#stadiumCreationError(error)) return Debug.trap("Failed to create stadium: " # error);
        };

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

        let allPlayers = await PlayersActor.getAllPlayers();
        let matchStartRequestBuffer = Buffer.Buffer<StadiumTypes.StartMatchRequest>(scheduledMatchGroup.matches.size());

        let prng = PseudoRandomX.fromBlob(await Random.blob());

        let teamDataMap = HashMap.HashMap<Principal, StadiumTypes.StartMatchTeam and { option : Nat }>(0, Principal.equal, Principal.hash);
        for ((teamId, team) in Trie.iter(teams)) {
            let teamActor = actor (Principal.toText(teamId)) : TeamTypes.TeamActor;
            let options : TeamTypes.ScenarioVoteResult = try {
                // Get match options from the team itself
                let result : TeamTypes.GetWinningScenarioOptionResult = await teamActor.getWinningScenarioOption({
                    scenarioId = scheduledMatchGroup.scenario.id;
                });
                let option = switch (result) {
                    case (#ok(o)) o;
                    case (#noVotes) {
                        // If no votes, pick a random choice
                        let option : Nat = 0; // TODO
                        option;
                    };
                    case (#scenarioNotFound) return Debug.trap("Scenario not found: " # scheduledMatchGroup.scenario.id);
                    case (#notAuthorized) return Debug.trap("League is not authorized to get match options from team: " # Principal.toText(teamId));
                };
                {
                    option = option;
                };
            } catch (err : Error.Error) {
                return Debug.trap("Failed to get team '" # Principal.toText(teamId) # "': " # Error.message(err));
            };
            let teamData = buildTeamInitData({ team with id = teamId }, allPlayers, prng);
            teamDataMap.put(
                teamId,
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
        let resolvedScenario = ScenarioUtil.resolveScenario(
            prng,
            scheduledMatchGroup.scenario,
            scenarioTeamData,
        );

        // TODO handle failure
        try {
            let result = await processEffectOutcomes(resolvedScenario.effectOutcomes);
            switch (result) {
                case (#ok) ();
                case (#notAuthorized) Debug.trap("League is not authorized to process effect outcomes");
                case (#seasonNotInProgress) Debug.trap("Season is not in progress");
            };
        } catch (err) {
            Debug.print("Failed to process effect outcomes: " # Error.message(err));
        };

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
                scenario = resolvedScenario;
                matches = inProgressMatches;
            }),
        ) else return #matchGroupNotFound;
        seasonStatus := #inProgress({
            season with
            matchGroups = newMatchGroups;
        });

        #ok;

    };

    public shared ({ caller }) func onMatchGroupComplete(
        request : Types.OnMatchGroupCompleteRequest
    ) : async Types.OnMatchGroupCompleteResult {
        if (not isStadium(caller)) {
            return #notAuthorized;
        };
        Debug.print("On Match group complete called for: " # Nat.toText(request.id));
        let #inProgress(season) = seasonStatus else return #seasonNotOpen;
        let ?stadiumId = stadiumIdOrNull else return #notAuthorized;
        if (caller != stadiumId) {
            return #notAuthorized;
        };

        let seed = try {
            await Random.blob();
        } catch (err) {
            return #seedGenerationError(Error.message(err));
        };
        let prng = PseudoRandomX.fromSeed(Blob.hash(seed));

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
            scenario = inProgressMatchGroup.scenario;
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

        let updatedTeamStandings : [Types.TeamStandingInfo] = calculateTeamStandings(Buffer.toArray(completedMatchGroups));

        await* awardUserPoints(request.id, request.matches);

        let updatedSeason = {
            season with
            matchGroups = newMatchGroups;
        };
        teamStandings := ?updatedTeamStandings;
        seasonStatus := #inProgress(updatedSeason);
        try {
            await PlayersActor.addMatchStats(request.id, request.playerStats);
        } catch (err) {
            Debug.print("Failed to award user points: " # Error.message(err));
        };

        // Get next match group to schedule
        let nextMatchGroupId = request.id + 1;
        let ?nextMatchGroup = Util.arrayGetSafe<Season.InProgressSeasonMatchGroupVariant>(
            updatedSeason.matchGroups,
            nextMatchGroupId,
        ) else {
            // Season is over because cant find more match groups
            try {
                ignore await closeSeason(); // TODO how to not await this?
            } catch (err) {
                Debug.print("Failed to close season: " # Error.message(err));
            };
            return #ok;
        };
        switch (nextMatchGroup) {
            case (#notScheduled(matchGroup)) {
                // Schedule next match group
                let allTeams = getTeamsArray();
                // TODO how to reschedule if it fails?
                let allPlayers = await PlayersActor.getAllPlayers();
                scheduleMatchGroup(
                    nextMatchGroupId,
                    matchGroup,
                    updatedSeason,
                    allTeams,
                    allPlayers,
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

    public shared ({ caller }) func closeSeason() : async Types.CloseSeasonResult {
        if (not isAdminId(caller)) {
            return #notAuthorized;
        };
        if (seasonStatus == #starting) {
            // TODO how to handle this?
            seasonStatus := #notStarted;
            return #ok;
        };
        let #inProgress(inProgressSeason) = seasonStatus else return #seasonNotOpen;
        let completedMatchGroups = switch (buildCompletedMatchGroups(inProgressSeason)) {
            case (#ok(completedMatchGroups)) completedMatchGroups;
            case (#matchGroupsNotComplete(currentMatchGroupId)) {
                // TODO put in bad state vs delete
                seasonStatus := #notStarted;
                switch (currentMatchGroupId) {
                    case (null) ();
                    case (?currentMatchGroupId) {
                        // Cancel live match
                        let stadiumId = switch (await* getOrCreateStadium()) {
                            case (#ok(id)) id;
                            case (#stadiumCreationError(error)) return Debug.trap("Failed to create stadium: " # error);
                        };
                        let stadiumActor = actor (Principal.toText(stadiumId)) : StadiumTypes.StadiumActor;
                        switch (await stadiumActor.cancelMatchGroup({ id = currentMatchGroupId })) {
                            case (#ok or #matchGroupNotFound) ();
                        };
                    };
                };
                await* onSeasonCompleteInternal();
                return #ok;
            };
        };
        let finalTeamStandings = calculateTeamStandings(completedMatchGroups);
        let completedTeams = Trie.toArray(
            teams,
            func(k : Principal, v : Team.Team) : Season.CompletedSeasonTeam {
                let ?standingIndex = finalTeamStandings
                |> Iter.fromArray(_)
                |> IterTools.findIndex(_, func(s : Types.TeamStandingInfo) : Bool = s.id == k) else Debug.trap("Team not found in standings: " # Principal.toText(k));
                let standingInfo = finalTeamStandings[standingIndex];

                {
                    id = k;
                    name = v.name;
                    logoUrl = v.logoUrl;
                    wins = standingInfo.wins;
                    losses = standingInfo.losses;
                    totalScore = standingInfo.totalScore;
                };
            },
        );
        let finalMatch = completedMatchGroups[completedMatchGroups.size() - 1].matches[0];
        let (champion, runnerUp) = switch (finalMatch.winner) {
            case (#team1) (finalMatch.team1, finalMatch.team2);
            case (#team2) (finalMatch.team2, finalMatch.team1);
            case (#tie) {
                // Break tie by their win/loss ratio
                let getTeamStanding = func(teamId : Principal) : Nat {
                    let ?teamStanding = IterTools.findIndex(Iter.fromArray(finalTeamStandings), func(s : Types.TeamStandingInfo) : Bool = s.id == teamId) else Debug.trap("Team not found in standings: " # Principal.toText(teamId));
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
        seasonStatus := #completed({
            championTeamId = champion.id;
            runnerUpTeamId = runnerUp.id;
            teams = completedTeams;
            matchGroups = completedMatchGroups;
        });
        await* onSeasonCompleteInternal();
        #ok;
    };

    private func onSeasonCompleteInternal() : async* () {
        for ((teamId, _) in Trie.iter(teams)) {
            let teamActor = actor (Principal.toText(teamId)) : TeamTypes.TeamActor;
            try {
                switch (await teamActor.onSeasonComplete()) {
                    case (#ok) ();
                    case (#notAuthorized) Debug.print("Error: League is not authorized to notify team of season completion");
                };
            } catch (err) {
                Debug.print("Failed to notify team of season completion: " # Error.message(err));
            };
        };
    };

    private func getCurrentMatchGroupId() : ?Nat {
        // Get current match group by finding the next scheduled one
        switch (seasonStatus) {
            case (#inProgress(inProgressSeason)) {
                for (i in Iter.range(0, inProgressSeason.matchGroups.size())) {
                    let matchGroup = inProgressSeason.matchGroups[i];
                    switch (matchGroup) {
                        // Find first scheduled match group
                        case (#scheduled(_)) return ?i;
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

    private func updateTeamEnergy(teamId : Principal, delta : Int) : () {
        let ?team = Trie.get(teams, buildPrincipalKey(teamId), Principal.equal) else Debug.trap("Team not found: " # Principal.toText(teamId));
        let newTeam : Team.Team = {
            team with
            energy = team.energy + delta;
        };
        let (newTeams, _) = Trie.put(teams, buildPrincipalKey(teamId), Principal.equal, newTeam);
        teams := newTeams;
    };

    private func updateTeamEntropy(teamId : Principal, delta : Int) : () {
        let ?team = Trie.get(teams, buildPrincipalKey(teamId), Principal.equal) else Debug.trap("Team not found: " # Principal.toText(teamId));
        let newEntropyInt : Int = team.entropy + delta;
        let newEntropyNat : Nat = if (newEntropyInt <= 0) {
            // Entropy cant be negative
            0;
        } else {
            Int.abs(newEntropyInt);
        };
        let newTeam : Team.Team = {
            team with
            entropy = newEntropyNat;
        };
        let (newTeams, _) = Trie.put(teams, buildPrincipalKey(teamId), Principal.equal, newTeam);
        teams := newTeams;
    };

    private func getTeamsArray() : [TeamWithId] {
        teams
        |> Trie.toArray(
            _,
            func(k : Principal, v : Team.Team) : TeamWithId = {
                v with
                id = k;
            },
        );
    };

    private func awardUserPoints(
        matchGroupId : Nat,
        completedMatches : [Season.CompletedMatch],
    ) : async* () {
        // Award users points for their predictions
        let key = {
            key = matchGroupId;
            hash = hashNatAsNat32(matchGroupId);
        };
        let ?matchGroupPredictions = Trie.get(predictions, key, Nat.equal) else Debug.trap("Match group predictions not found: " # Nat.toText(matchGroupId));
        let awards = Buffer.Buffer<UserTypes.AwardPointsRequest>(0);
        var i = 0;
        for (match in Iter.fromArray(completedMatches)) {
            let matchPredictions = matchGroupPredictions[i];
            i += 1;
            for ((userId, teamId) in Trie.iter(matchPredictions)) {
                if (teamId == match.winner) {
                    // Award points
                    awards.add({
                        userId = userId;
                        points = 10; // TODO amount?
                    });
                };
            };
        };

        let error : ?Text = try {
            switch (await UsersActor.awardPoints(Buffer.toArray(awards))) {
                case (#ok) null;
                case (#notAuthorized) ?"League is not authorized to award user points";
            };
        } catch (err) {
            // TODO how to handle this?
            ?Error.message(err);
        };
        switch (error) {
            case (null) ();
            case (?error) Debug.print("Failed to award user points: " # error);
        };
    };

    private func getMatchTeamInfo(team : ScheduleBuilder.Team) : Season.TeamAssignment {
        switch (team) {
            case (#id(teamId)) #predetermined(getTeamInfo(teamId));
            case (#seasonStandingIndex(standingIndex)) #seasonStandingIndex(standingIndex);
            case (#winnerOfMatch(matchId)) #winnerOfMatch(matchId);
        };
    };

    private func getTeamInfo(teamId : Principal) : Season.TeamInfo {
        let ?team = Trie.get(teams, buildPrincipalKey(teamId), Principal.equal) else Debug.trap("Team not found: " # Principal.toText(teamId));
        {
            id = teamId;
            name = team.name;
            logoUrl = team.logoUrl;
        };
    };

    private func isAdminId(id : Principal) : Bool {
        if (id == Principal.fromActor(LeagueActor)) {
            // League is admin
            return true;
        };
        TrieSet.mem(admins, id, Principal.hash(id), Principal.equal);
    };

    private func isStadium(id : Principal) : Bool {
        let ?stadiumId = stadiumIdOrNull else return false;
        id == stadiumId;
    };

    private func scheduleMatchGroup(
        matchGroupId : Nat,
        matchGroup : Season.NotScheduledMatchGroup,
        inProgressSeason : Season.InProgressSeason,
        allTeams : [Team.TeamWithId],
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
                    await startMatchGroup(matchGroupId);
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

                    let ?teamWithStanding = Util.arrayGetSafe<Types.TeamStandingInfo>(
                        standings,
                        standingIndex,
                    ) else Debug.trap("Standing not found. Standings: " # debug_show (standings) # " Standing index: " # Nat.toText(standingIndex));

                    getTeamInfo(teamWithStanding.id);
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
            scenario = matchGroup.scenario;
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

        // Open match group predictions for scheduled match group
        let predictionKey = {
            key = matchGroupId;
            hash = hashNatAsNat32(matchGroupId);
        };
        let matchGroupPredictions = Array.tabulate(matchCount, func(_ : Nat) : Trie.Trie<Principal, Team.TeamId> = Trie.empty());
        let (newPredictions, oldMatchGroupPredictions) = Trie.put(predictions, predictionKey, Nat.equal, matchGroupPredictions);
        if (oldMatchGroupPredictions != null) {
            Debug.trap("Match group predictions already open for match group " # Nat.toText(matchGroupId) # ". Old predictions: " # debug_show (oldMatchGroupPredictions));
        };
        predictions := newPredictions;
    };

    private func hashNatAsNat32(matchGroupId : Nat) : Nat32 {
        Nat32.fromNat(matchGroupId);
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

    private func getOrCreateStadium() : async* {
        #ok : Principal;
        #stadiumCreationError : Text;
    } {
        switch (stadiumIdOrNull) {
            case (null) ();
            case (?id) return #ok(id);
        };

        if (not stadiumFactoryInitialized) {
            let #ok = await StadiumFactoryActor.setLeague(Principal.fromActor(LeagueActor)) else Debug.trap("Failed to set league on stadium factory");
            stadiumFactoryInitialized := true;
        };
        let createStadiumResult = try {
            await StadiumFactoryActor.createStadiumActor();
        } catch (err) {
            return #stadiumCreationError(Error.message(err));
        };
        switch (createStadiumResult) {
            case (#ok(id)) {
                stadiumIdOrNull := ?id;
                #ok(id);
            };
            case (#stadiumCreationError(error)) return #stadiumCreationError(error);
        };
    };

    private func buildCompletedMatchGroups(
        season : Season.InProgressSeason
    ) : { #ok : [Season.CompletedMatchGroup]; #matchGroupsNotComplete : ?Nat } {
        let completedMatchGroups = Buffer.Buffer<Season.CompletedMatchGroup>(season.matchGroups.size());
        var matchGroupId = 0;
        for (matchGroup in Iter.fromArray(season.matchGroups)) {
            let completedMatchGroup = switch (matchGroup) {
                case (#completed(completedMatchGroup)) completedMatchGroup;
                case (#notScheduled(notScheduledMatchGroup)) return #matchGroupsNotComplete(null);
                case (#scheduled(scheduledMatchGroup)) return #matchGroupsNotComplete(null);
                case (#inProgress(inProgressMatchGroup)) return #matchGroupsNotComplete(?matchGroupId);
            };
            matchGroupId += 1;
            completedMatchGroups.add(completedMatchGroup);
        };
        #ok(Buffer.toArray(completedMatchGroups));
    };

    private func calculateTeamStandings(
        matchGroups : [Season.CompletedMatchGroup]
    ) : [Types.TeamStandingInfo] {
        var teamScores = Trie.empty<Principal, Types.TeamStandingInfo>();
        let updateTeamScore = func(
            teamId : Principal,
            score : Int,
            state : { #win; #loss; #tie },
        ) : () {

            let teamKey = {
                key = teamId;
                hash = Principal.hash(teamId);
            };
            let currentScore = switch (Trie.get(teamScores, teamKey, Principal.equal)) {
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
            let (newTeamScores, _) = Trie.put<Principal, Types.TeamStandingInfo>(
                teamScores,
                teamKey,
                Principal.equal,
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
            func((k, v) : (Principal, Types.TeamStandingInfo)) : Types.TeamStandingInfo = v,
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
        |> Iter.toArray(_);
    };

    private func buildPrincipalKey(id : Principal) : {
        key : Principal;
        hash : Hash.Hash;
    } {
        { key = id; hash = Principal.hash(id) };
    };

    private func arrayToIdTrie<T>(items : [T], getId : (T) -> Nat32) : Trie.Trie<Nat32, T> {
        var trie = Trie.empty<Nat32, T>();
        for (item in Iter.fromArray(items)) {
            let id = getId(item);
            let key = {
                key = id;
                hash = id;
            };
            let (newTrie, _) = Trie.put(trie, key, Nat32.equal, item);
            trie := newTrie;
        };
        trie;
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
