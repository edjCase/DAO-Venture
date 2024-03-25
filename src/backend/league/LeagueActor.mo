import Principal "mo:base/Principal";
import IterTools "mo:itertools/Iter";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";
import Random "mo:base/Random";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Text "mo:base/Text";
import Bool "mo:base/Bool";
import PseudoRandomX "mo:random/PseudoRandomX";
import Types "Types";
import UsersActor "canister:users";
import Team "../models/Team";
import Season "../models/Season";
import UserTypes "../users/Types";
import Scenario "../models/Scenario";
import SeasonHandler "SeasonHandler";
import PredictionHandler "PredictionHandler";
import ScenarioHandler "ScenarioHandler";
import TeamsHandler "TeamsHandler";
import PlayersActor "canister:players";
import TeamsActor "canister:teams";
import Dao "../Dao";
import StadiumActor "canister:stadium";

actor LeagueActor : Types.LeagueActor {
    type TeamWithId = Team.TeamWithId;
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    stable var stableData = {
        season : SeasonHandler.StableData = {
            seasonStatus = #notStarted;
            teamStandings = null;
            predictions = [];
        };
        predictions : PredictionHandler.StableData = {
            matchGroups = [];
        };
        scenarios : ScenarioHandler.StableData = {
            scenarios = [];
        };
        teams : TeamsHandler.StableData = {
            teams = [];
            teamsInitialized = false;
        };
        dao : Dao.StableData<Types.ProposalContent> = {
            proposalDuration = #days(3);
            proposals = [];
            votingThreshold = #percent({
                percent = 50;
                quorum = ?20;
            });
        };
    };

    private func processEffectOutcomes(effectOutcomes : [Scenario.EffectOutcome]) : async* ScenarioHandler.ProcessEffectOutcomesResult {
        let processedOutcomes = Buffer.Buffer<ScenarioHandler.EffectOutcomeData>(effectOutcomes.size());
        for (effectOutcome in Iter.fromArray(effectOutcomes)) {
            let processed = try {
                switch (effectOutcome) {
                    case (#injury(injuryEffect)) {
                        let result = await PlayersActor.applyEffects([#injury(injuryEffect)]); // TODO optimize with bulk call
                        switch (result) {
                            case (#ok) true;
                        };
                    };
                    case (#entropy(entropyEffect)) {
                        teamsHandler.updateTeamEntropy(entropyEffect.teamId, entropyEffect.delta);
                        true;
                    };
                    case (#energy(e)) {
                        teamsHandler.updateTeamEnergy(e.teamId, e.delta);
                        true;
                    };
                    case (#skill(s)) {
                        let result = await PlayersActor.applyEffects([#skill(s)]); // TODO optimize with bulk call
                        switch (result) {
                            case (#ok) true;
                        };
                    };
                };

            } catch (err) {
                // TODO this should have rollback and whatnot, there shouldnt be an error but im not sure how to handle
                // errors for now
                Debug.print("Failed to process team effect outcomes: " # Error.message(err));
                false;
            };
            processedOutcomes.add({
                outcome = effectOutcome;
                processed = processed;
            });
        };
        #ok(Buffer.toArray(processedOutcomes));
    };

    stable var stadiumInitialized = false;
    var predictionHandler = PredictionHandler.Handler(stableData.predictions);
    var teamsHandler = TeamsHandler.Handler(stableData.teams);
    var scenarioHandler = ScenarioHandler.Handler<system>(stableData.scenarios, processEffectOutcomes);

    let seasonEventHandler : SeasonHandler.EventHandler = {
        onSeasonStart = func(_ : Season.InProgressSeason) : async* () {};
        onMatchGroupSchedule = func(matchGroupId : Nat, matchGroup : Season.ScheduledMatchGroup) : async* () {
            predictionHandler.addMatchGroup(matchGroupId, matchGroup.matches.size());
        };
        onMatchGroupStart = func(matchGroupId : Nat, _ : Season.InProgressMatchGroup) : async* () {
            predictionHandler.closeMatchGroup(matchGroupId);
        };
        onMatchGroupComplete = func(_ : Nat, _ : Season.CompletedMatchGroup) : async* () {

        };
        onSeasonEnd = func(_ : SeasonHandler.EndedSeasonVariant) : async* () {
            // TODO archive vs delete
            Debug.print("Season complete, clearing season data");
            predictionHandler.clear();
            // TODO teams reset energy/entropy? or is that a scenario thing

            // TODO handle failures
            try {
                switch (await UsersActor.onSeasonEnd()) {
                    case (#ok) ();
                    case (#notAuthorized) Debug.print("League is not authorized to call users actor 'onSeasonEnd'");
                };
            } catch (err) {
                Debug.print("Failed to call UsersActor.onSeasonEnd: " # Error.message(err));
            };
            try {
                switch (await PlayersActor.onSeasonEnd()) {
                    case (#ok) ();
                    case (#notAuthorized) Debug.print("League is not authorized to call players actor 'onSeasonEnd'");
                };
            } catch (err) {
                Debug.print("Failed to call PlayersActor.onSeasonEnd: " # Error.message(err));
            };
        };
    };

    var seasonHandler = SeasonHandler.SeasonHandler<system>(stableData.season, seasonEventHandler);

    func onExecuted(proposal : Types.Proposal) : async* Dao.OnExecuteResult {
        switch (proposal.content) {
            case (#changeTeamName(c)) {
                teamsHandler.updateTeamName(c.teamId, c.name);
                #ok;
            };
        };
    };
    func onRejected(_ : Types.Proposal) : async* () {}; // TODO
    var dao = Dao.Dao(stableData.dao, onExecuted, onRejected);
    dao.resetEndTimers<system>(); // TODO move into DAO

    system func preupgrade() {
        stableData := {
            season = seasonHandler.toStableData();
            predictions = predictionHandler.toStableData();
            scenarios = scenarioHandler.toStableData();
            teams = teamsHandler.toStableData();
            dao = dao.toStableData();
        };
    };

    system func postupgrade() {
        seasonHandler := SeasonHandler.SeasonHandler<system>(stableData.season, seasonEventHandler);
        predictionHandler := PredictionHandler.Handler(stableData.predictions);
        scenarioHandler := ScenarioHandler.Handler<system>(stableData.scenarios, processEffectOutcomes);
        teamsHandler := TeamsHandler.Handler(stableData.teams);
        dao := Dao.Dao(stableData.dao, onExecuted, onRejected);
        dao.resetEndTimers<system>(); // TODO move into DAO
    };

    public query func getTeams() : async [TeamWithId] {
        teamsHandler.getAll();
    };

    // TODO REMOVE ALL DELETING METHODS
    public shared func clearTeams() : async () {
        teamsHandler := TeamsHandler.Handler({
            teamsInitialized = stableData.teams.teamsInitialized;
            teams = [];
        });
    };

    public query func getSeasonStatus() : async Season.SeasonStatus {
        seasonHandler.seasonStatus;
    };

    public shared ({ caller }) func createProposal(request : Types.CreateProposalRequest) : async Types.CreateProposalResult {
        let members = switch (await UsersActor.getTeamOwners(#all)) {
            case (#ok(members)) members;
        };
        switch (request.content) {
            case (#changeTeamName(c)) {
                // Team is only one who can propose to change their name
                if (caller != Principal.fromActor(TeamsActor)) {
                    return #notAuthorized;
                };
            };
        };
        dao.createProposal<system>(caller, request.content, members);
    };

    public shared query func getProposal(id : Nat) : async Types.GetProposalResult {
        switch (dao.getProposal(id)) {
            case (?proposal) return #ok(proposal);
            case (null) return #proposalNotFound;
        };
    };

    public shared query func getProposals(count : Nat, offset : Nat) : async Types.GetProposalsResult {
        #ok(dao.getProposals(count, offset));
    };

    public shared ({ caller }) func voteOnProposal(request : Types.VoteOnProposalRequest) : async Types.VoteOnProposalResult {
        await* dao.vote(request.proposalId, caller, request.vote);
    };

    public query func getTeamStandings() : async Types.GetTeamStandingsResult {
        switch (seasonHandler.teamStandings) {
            case (?standings) return #ok(Buffer.toArray(standings));
            case (null) return #notFound;
        };
    };

    public query func getScenario(scenarioId : Text) : async Types.GetScenarioResult {
        switch (scenarioHandler.getScenario(scenarioId)) {
            case (null) #notFound;
            case (?scenario) {
                #ok(mapScenario(scenario));
            };
        };
    };

    public query func getScenarios() : async Types.GetScenariosResult {
        let openScenarios = scenarioHandler.getScenarios(false).vals()
        |> Iter.map(_, mapScenario)
        |> Iter.toArray(_);
        #ok(openScenarios);
    };

    public shared ({ caller }) func addScenario(scenario : Types.AddScenarioRequest) : async Types.AddScenarioResult {
        if (not isAdminId(caller)) {
            return #notAuthorized;
        };
        Debug.print("Adding scenario: " # scenario.id);
        switch (scenarioHandler.add<system>(scenario)) {
            case (#ok) #ok;
            case (#invalid(errors)) return #invalid(errors);
        };
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
        await* initStadium(); // Hack to init stadium for calling
        let stadiumId = Principal.fromActor(StadiumActor);
        let teamsArray = teamsHandler.getAll();

        let allPlayers = await PlayersActor.getAllPlayers();

        // TODO validate the scenarios are not used

        let prng = PseudoRandomX.fromBlob(seedBlob);
        await* seasonHandler.startSeason<system>(
            prng,
            stadiumId,
            request.startTime,
            request.weekDays,
            teamsArray,
            allPlayers,
        );
    };

    public shared ({ caller }) func createTeam(request : Types.CreateTeamRequest) : async Types.CreateTeamResult {
        if (not isAdminId(caller)) {
            return #notAuthorized;
        };
        let leagueId = Principal.fromActor(LeagueActor);
        await* teamsHandler.create(leagueId, request);
    };

    public shared ({ caller }) func predictMatchOutcome(request : Types.PredictMatchOutcomeRequest) : async Types.PredictMatchOutcomeResult {
        let ?nextScheduled = seasonHandler.getNextScheduledMatchGroup() else return #predictionsClosed;
        predictionHandler.predictMatchOutcome(
            nextScheduled.matchGroupId,
            request.matchId,
            caller,
            request.winner,
        );
    };

    public shared query ({ caller }) func getMatchGroupPredictions(matchGroupId : Nat) : async Types.GetMatchGroupPredictionsResult {
        predictionHandler.getMatchGroupSummary(matchGroupId, ?caller);
    };

    public shared func startMatchGroup(matchGroupId : Nat) : async Types.StartMatchGroupResult {
        // TODO
        // if (not isAdminId(caller)) {
        //     return #notAuthorized;
        // };

        await* seasonHandler.startMatchGroup(matchGroupId);

    };

    public shared ({ caller }) func onMatchGroupComplete(
        request : Types.OnMatchGroupCompleteRequest
    ) : async Types.OnMatchGroupCompleteResult {
        Debug.print("On Match group complete called for: " # Nat.toText(request.id));
        if (caller != Principal.fromActor(StadiumActor)) {
            return #notAuthorized;
        };

        let prng = try {
            PseudoRandomX.fromBlob(await Random.blob());
        } catch (err) {
            return #seedGenerationError(Error.message(err));
        };

        let result = await* seasonHandler.onMatchGroupComplete(request, prng);
        // TODO handle failure
        await* awardUserPoints(request.id, request.matches);
        result;
    };

    public shared ({ caller }) func closeSeason() : async Types.CloseSeasonResult {
        if (not isAdminId(caller)) {
            return #notAuthorized;
        };
        let result = await* seasonHandler.close();
        await* teamsHandler.onSeasonEnd();
        result;
    };

    private func awardUserPoints(
        matchGroupId : Nat,
        completedMatches : [Season.CompletedMatch],
    ) : async* () {

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

    private func mapScenario(scenario : Scenario.Scenario) : Types.Scenario {
        let options : [Scenario.ScenarioOption] = scenario.options
        |> Iter.fromArray(_)
        |> IterTools.mapEntries(
            _,
            func(i : Nat, option : Scenario.ScenarioOptionWithEffect) : Scenario.ScenarioOption {
                {
                    id = i;
                    title = option.title;
                    description = option.description;
                };
            },
        )
        |> Iter.toArray(_);
        {
            id = scenario.id;
            title = scenario.title;
            description = scenario.description;
            options = options;
            state = scenario.state;
        };
    };

    private func isAdminId(id : Principal) : Bool {
        if (id == Principal.fromActor(LeagueActor)) {
            // League is admin
            return true;
        };
        return true; // TODO i dont want to use admin pattern
        // TrieSet.mem(admins, id, Principal.hash(id), Principal.equal);
    };

    private func initStadium() : async* () {

        if (not stadiumInitialized) {
            let #ok = await StadiumActor.setLeague(Principal.fromActor(LeagueActor)) else Debug.trap("Failed to set league on stadium");
            stadiumInitialized := true;
        };
    };
};
