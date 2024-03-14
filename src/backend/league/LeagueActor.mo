import Principal "mo:base/Principal";
import IterTools "mo:itertools/Iter";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";
import Random "mo:base/Random";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Text "mo:base/Text";
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
import TeamTypes "../team/Types";
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

    stable var stadiumInitialized = false;

    var seasonHandler = SeasonHandler.SeasonHandler(stableData.season);
    var predictionHandler = PredictionHandler.Handler(stableData.predictions);
    var scenarioHandler = ScenarioHandler.Handler(stableData.scenarios);
    var teamsHandler = TeamsHandler.Handler(stableData.teams);

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
        seasonHandler := SeasonHandler.SeasonHandler(stableData.season);
        predictionHandler := PredictionHandler.Handler(stableData.predictions);
        scenarioHandler := ScenarioHandler.Handler(stableData.scenarios);
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

    public shared query func getProposals() : async Types.GetProposalsResult {
        #ok(dao.getProposals());
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
                let options : [Types.ScenarioOption] = scenario.options
                |> Iter.fromArray(_)
                |> IterTools.mapEntries(
                    _,
                    func(i : Nat, option : Scenario.ScenarioOption) : Types.ScenarioOption {
                        {
                            id = i;
                            title = option.title;
                            description = option.description;
                        };
                    },
                )
                |> Iter.toArray(_);
                #ok({
                    id = scenario.id;
                    title = scenario.title;
                    description = scenario.description;
                    options = options;
                    state = scenario.state;
                });
            };
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

        let scenarioIds = Buffer.Buffer<Text>(request.scenarios.size());
        for (scenario in Iter.fromArray(request.scenarios)) {
            switch (scenarioHandler.add(scenario)) {
                case (#ok) ();
                case (#idTaken) return #idTaken;
                case (#invalid(errors)) return #invalidScenario({
                    id = scenario.id;
                    errors = errors;
                });
            };
            scenarioIds.add(scenario.id);
        };

        let prng = PseudoRandomX.fromBlob(seedBlob);
        seasonHandler.startSeason<system>(
            prng,
            stadiumId,
            request.startTime,
            Buffer.toArray(scenarioIds),
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

    public shared ({ caller }) func processEffectOutcomes(request : Types.ProcessEffectOutcomesRequest) : async Types.ProcessEffectOutcomesResult {
        if (not isAdminId(caller)) {
            return #notAuthorized;
        };

        let playerOutcomes = Buffer.Buffer<Scenario.PlayerEffectOutcome>(request.outcomes.size());
        for (effectOutcome in Iter.fromArray(request.outcomes)) {
            switch (effectOutcome) {
                case (#injury(injuryEffect)) playerOutcomes.add(#injury(injuryEffect));
                case (#entropy(entropyEffect)) {
                    teamsHandler.updateTeamEntropy(entropyEffect.teamId, entropyEffect.delta);
                };
                case (#energy(e)) {
                    teamsHandler.updateTeamEnergy(e.teamId, e.delta);
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

    public shared func startMatchGroup(matchGroupId : Nat) : async Types.StartMatchGroupResult {
        // TODO
        // if (not isAdminId(caller)) {
        //     return #notAuthorized;
        // };
        let prng = PseudoRandomX.fromBlob(await Random.blob());
        switch (await* buildTeamScenarioData(matchGroupId)) {
            case (#ok(data)) {
                let resolvedScenarioState = scenarioHandler.resolve(
                    data.scenarioId,
                    data.teamScenarioData,
                    prng,
                );

                // TODO handle failure
                try {
                    let result = await processEffectOutcomes({
                        outcomes = resolvedScenarioState.effectOutcomes;
                    });
                    switch (result) {
                        case (#ok) ();
                        case (#notAuthorized) Debug.trap("League is not authorized to process effect outcomes");
                        case (#seasonNotInProgress) Debug.trap("Season is not in progress");
                    };
                } catch (err) {
                    Debug.print("Failed to process effect outcomes: " # Error.message(err));
                };
            };
            case (#notScheduledYet) return #notScheduledYet;
        };

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
        await* teamsHandler.onSeasonComplete();
        result;
    };

    private func awardUserPoints(
        matchGroupId : Nat,
        completedMatches : [Season.CompletedMatch],
    ) : async* () {
        // Award users points for their predictions
        let ?matchGroupPredictions = predictionHandler.getMatchGroup(matchGroupId) else Debug.trap("Match group predictions not found: " # Nat.toText(matchGroupId));
        let awards = Buffer.Buffer<UserTypes.AwardPointsRequest>(0);
        var i = 0;
        for (match in Iter.fromArray(completedMatches)) {
            let matchPredictions = matchGroupPredictions[i];
            i += 1;
            for (p in Iter.fromArray(matchPredictions)) {
                if (p.teamId == match.winner) {
                    // Award points
                    awards.add({
                        userId = p.userId;
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

    private func isAdminId(id : Principal) : Bool {
        if (id == Principal.fromActor(LeagueActor)) {
            // League is admin
            return true;
        };
        return true; // TODO i dont want to use admin pattern
        // TrieSet.mem(admins, id, Principal.hash(id), Principal.equal);
    };

    private func buildTeamScenarioData(matchGroupId : Nat) : async* {
        #ok : {
            scenarioId : Text;
            teamScenarioData : [ScenarioHandler.TeamScenarioData];
        };
        #notScheduledYet;
    } {
        let ?matchGroupInfo = seasonHandler.getMatchGroup(matchGroupId) else Debug.trap("Match group not found: " # Nat.toText(matchGroupId));

        let teams = switch (matchGroupInfo.season) {
            case (#inProgress(s)) s.teams;
            case (#completed(c)) c.teams;
        };
        let teamScenarioData = Buffer.Buffer<ScenarioHandler.TeamScenarioData>(teams.size());

        let scenarioId = switch (matchGroupInfo.matchGroup) {
            case (#notScheduled(_)) return #notScheduledYet;
            case (#scheduled(s)) s.scenarioId;
            case (#inProgress(i)) i.scenarioId;
            case (#completed(c)) c.scenarioId;
        };
        let scenarioResults = try {
            await TeamsActor.getScenarioVotingResults({
                scenarioId = scenarioId;
            });
        } catch (err : Error.Error) {
            return Debug.trap("Failed to get scenario voting results: " # Error.message(err));
        };
        let teamResults = switch (scenarioResults) {
            case (#ok(o)) o;
            case (#scenarioNotFound) return Debug.trap("Scenario not found: " # scenarioId);
            case (#notAuthorized) return Debug.trap("League is not authorized to get scenario results");
        };

        for (team in Iter.fromArray(teams)) {
            let optionOrNull = IterTools.find(teamResults.teamOptions.vals(), func(o : TeamTypes.ScenarioTeamVotingResult) : Bool = o.teamId == team.id);
            let option = switch (optionOrNull) {
                case (?o) o.option;
                case (null) 0; // TODO random if no votes?
            };

            teamScenarioData.add({
                team with
                option = option;
                positions = team.positions;
            });
        };
        #ok({
            scenarioId = scenarioId;
            teamScenarioData = Buffer.toArray(teamScenarioData);
        });
    };

    private func initStadium() : async* () {

        if (not stadiumInitialized) {
            let #ok = await StadiumActor.setLeague(Principal.fromActor(LeagueActor)) else Debug.trap("Failed to set league on stadium");
            stadiumInitialized := true;
        };
    };
};
