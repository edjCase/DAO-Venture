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
import Types "Types";
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
import SeasonState "SeasonState";
import PredictionHandler "PredictionHandler";
import ScenarioHandler "ScenarioHandler";

actor LeagueActor {
    type TeamWithId = Team.TeamWithId;
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    stable var stableData = {
        season : SeasonState.Data = {
            seasonStatus = #notStarted;
            teamStandings = null;
            predictions = [];
        };
        predictions : PredictionHandler.Data = {
            matchGroups = [];
        };
        scenarios = {
            scenarios = [];
        };
    };

    stable var admins : TrieSet.Set<Principal> = TrieSet.empty();
    stable var teams : Trie.Trie<Principal, Team.Team> = Trie.empty();
    stable var stadiumIdOrNull : ?Principal = null;
    stable var teamFactoryInitialized = false;
    stable var stadiumFactoryInitialized = false;

    let seasonState = SeasonState.SeasonState(stableData.season);
    let predictionHandler = PredictionHandler.Handler(stableData.predictions);
    let scenarioHandler = ScenarioHandler.Handler(stableData.scenarios);

    system func preupgrade() {
        stableData := {
            season = seasonState.toStableData();
            predictions = predictions.toStableData();
            scenarios = scenarioHandler.toStableData();
        };
    };

    system func postupgrade() {
        season := SeasonState.SeasonState(stableData.season);
        predictions := PredictionHandler.Handler(stableData.scenarioVoting);
        scenarios := ScenarioHandler.Handler(stableData.scenarios);
    };

    public query func getTeams() : async [TeamWithId] {
        getTeamsArray();
    };

    // TODO REMOVE ALL DELETING METHODS
    public shared func clearTeams() : async () {
        teams := Trie.empty();
    };

    public query func getSeasonStatus() : async Season.SeasonStatus {
        seasonState.seasonStatus;
    };

    public query func getTeamStandings() : async Types.GetTeamStandingsResult {
        switch (seasonState.teamStandings) {
            case (?standings) return #ok(Buffer.toArray(standings));
            case (null) return #notFound;
        };
    };

    public query func getScenario(scenarioId : Text) : async Types.GetScenarioResult {
        scenarioHandler.getScenario(scenarioId);
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
        let seedBlob = try {
            await Random.blob();
        } catch (err) {
            return #seedGenerationError(Error.message(err));
        };

        let stadiumId = switch (await* getOrCreateStadium()) {
            case (#ok(id)) id;
            case (#stadiumCreationError(error)) return Debug.trap("Failed to create stadium: " # error);
        };
        let teamsArray = getTeamsArray();

        let allPlayers = await PlayersActor.getAllPlayers();

        let prng = PseudoRandomX.fromBlob(seedBlob);
        seasonState.startSeaon(
            prng,
            stadiumId,
            request,
            teamsArray,
            allPlayers,
        );
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
        let ?currentMatchGroupId = getCurrentMatchGroupId() else return #predictionsClosed;
        predictionHandler.predictMatchOutcome(currentMatchGroupId, request);
    };

    public shared query ({ caller }) func getMatchGroupPredictions(matchGroupId : Nat) : async Types.GetMatchGroupPredictionsResult {
        predictionHandler.getMatchGroupSummary(matchGroupId, ?caller);
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
        let stadiumId = switch (await* getOrCreateStadium()) {
            case (#ok(id)) id;
            case (#stadiumCreationError(error)) return Debug.trap("Failed to create stadium: " # error);
        };
        // TODO Move to scenario code

        let ?scenario = unresolvedScenarios.remove(scheduledMatchGroup.scenarioId) else Debug.trap("Unresolved scenario not found: " # scheduledMatchGroup.scenarioId);

        unresolvedScenarios := newUnresolvedScenarios;

        let resolvedScenario = ScenarioUtil.resolveScenario(
            prng,
            scenario,
            scenarioTeamData,
        );
        let (newResolvedScenarios, _) = Trie.put(resolvedScenarios, scenarioKey, Text.equal, resolvedScenario);
        resolvedScenarios := newResolvedScenarios;

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
        // TO HERE
        seasonState.startMatchGroup(matchGroupId, stadiumId);

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
            scenarioId = inProgressMatchGroup.scenarioId;
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

    private func hashNatAsNat32(matchGroupId : Nat) : Nat32 {
        Nat32.fromNat(matchGroupId);
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

};
