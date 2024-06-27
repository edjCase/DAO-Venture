import Principal "mo:base/Principal";
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
import Season "../models/Season";
import UserTypes "../users/Types";
import Scenario "../models/Scenario";
import SeasonHandler "SeasonHandler";
import PredictionHandler "PredictionHandler";
import ScenarioHandler "ScenarioHandler";
import PlayersActor "canister:players";
import TeamsActor "canister:teams";
import Dao "../Dao";
import StadiumActor "canister:stadium";
import Result "mo:base/Result";

actor LeagueActor : Types.LeagueActor {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    stable var stadiumInitialized = false;
    stable var teamsInitialized = false;
    stable var benevolentDictator : Types.BenevolentDictatorState = #open;
    stable var seasonStableData : SeasonHandler.StableData = {
        seasonStatus = #notStarted;
        teamStandings = null;
        predictions = [];
    };
    stable var predictionStableData : PredictionHandler.StableData = {
        matchGroups = [];
    };
    stable var scenarioStableData : ScenarioHandler.StableData = {
        scenarios = [];
    };
    stable var daoStableData : Dao.StableData<Types.ProposalContent> = {
        proposalDuration = #days(3);
        proposals = [];
        votingThreshold = #percent({
            percent = 50;
            quorum = ?20;
        });
    };

    private func processEffectOutcomes(effectOutcomes : [Scenario.EffectOutcome]) : async* ScenarioHandler.ProcessEffectOutcomesResult {
        let processedOutcomes = Buffer.Buffer<ScenarioHandler.EffectOutcomeData>(effectOutcomes.size());
        for (effectOutcome in Iter.fromArray(effectOutcomes)) {
            let processResult : Result.Result<(), Text> = try {
                switch (effectOutcome) {
                    case (#injury(injuryEffect)) {
                        let result = await PlayersActor.applyEffects([#injury(injuryEffect)]); // TODO optimize with bulk call
                        switch (result) {
                            case (#ok) #ok;
                            case (#err(e)) #err(debug_show (e));
                        };
                    };
                    case (#entropy(entropyEffect)) {
                        let result = await TeamsActor.updateTeamEntropy(entropyEffect.teamId, entropyEffect.delta);
                        switch (result) {
                            case (#ok) #ok;
                            case (#err(e)) #err(debug_show (e));
                        };
                    };
                    case (#energy(e)) {
                        let result = await TeamsActor.updateTeamEnergy(e.teamId, e.delta);
                        switch (result) {
                            case (#ok) #ok;
                            case (#err(e)) #err(debug_show (e));
                        };
                    };
                    case (#skill(s)) {
                        let result = await PlayersActor.applyEffects([#skill(s)]); // TODO optimize with bulk call
                        switch (result) {
                            case (#ok) #ok;
                            case (#err(e)) #err(debug_show (e));
                        };
                    };
                    case (#teamTrait(t)) {
                        let result = switch (t.kind) {
                            case (#add) await TeamsActor.addTraitToTeam(t.teamId, t.traitId);
                            case (#remove) await TeamsActor.removeTraitFromTeam(t.teamId, t.traitId);
                        };
                        switch (result) {
                            case (#ok(_)) #ok;
                            case (#err(e)) #err(debug_show (e));
                        };
                    };
                };

            } catch (err) {
                // TODO this should have rollback and whatnot, there shouldnt be an error but im not sure how to handle
                // errors for now
                #err(Error.message(err));
            };
            let processed = switch (processResult) {
                case (#ok) true;
                case (#err(e)) {
                    Debug.print("Failed to process effect outcome: " # debug_show (effectOutcome) # ", Error: " # e);
                    false;
                };
            };
            processedOutcomes.add({
                outcome = effectOutcome;
                processed = processed;
            });
        };
        #ok(Buffer.toArray(processedOutcomes));
    };

    var predictionHandler = PredictionHandler.Handler(predictionStableData);
    var scenarioHandler = ScenarioHandler.Handler<system>(scenarioStableData, processEffectOutcomes);

    let seasonEventHandler : SeasonHandler.EventHandler = {
        onSeasonStart = func(_ : Season.InProgressSeason) : async* () {};
        onMatchGroupSchedule = func(matchGroupId : Nat, matchGroup : Season.ScheduledMatchGroup) : async* () {
            predictionHandler.addMatchGroup(matchGroupId, matchGroup.matches.size());
        };
        onMatchGroupStart = func(matchGroupId : Nat, _ : Season.InProgressMatchGroup) : async* () {
            predictionHandler.closeMatchGroup(matchGroupId);
        };
        onMatchGroupComplete = func(matchGroupId : Nat, matchGroup : Season.CompletedMatchGroup) : async* () {
            Debug.print("On match group complete event hook called for match group: " # Nat.toText(matchGroupId));
            let result = await TeamsActor.onMatchGroupComplete({
                matchGroup = matchGroup;
            });
            switch (result) {
                case (#ok) ();
                case (#err(#notAuthorized)) Debug.trap("League is not authorized to notify team of match group completion");
            };
            Debug.print("Match group complete event hook completed");
        };
        onSeasonEnd = func(_ : SeasonHandler.EndedSeasonVariant) : async* () {
            // TODO archive vs delete
            Debug.print("Season complete, clearing season data");
            predictionHandler.clear();
            // TODO teams reset energy/entropy? or is that a scenario thing

            try {
                switch (await TeamsActor.onSeasonEnd()) {
                    case (#ok) ();
                    case (#err(#notAuthorized)) Debug.print("Error: League is not authorized to notify team of season completion");
                };
            } catch (err) {
                Debug.print("Failed to notify team of season completion: " # Error.message(err));
            };

            // TODO handle failures
            try {
                switch (await UsersActor.onSeasonEnd()) {
                    case (#ok) ();
                    case (#err(#notAuthorized)) Debug.print("League is not authorized to call users actor 'onSeasonEnd'");
                };
            } catch (err) {
                Debug.print("Failed to call UsersActor.onSeasonEnd: " # Error.message(err));
            };
            try {
                switch (await PlayersActor.onSeasonEnd()) {
                    case (#ok) ();
                    case (#err(#notAuthorized)) Debug.print("League is not authorized to call players actor 'onSeasonEnd'");
                };
            } catch (err) {
                Debug.print("Failed to call PlayersActor.onSeasonEnd: " # Error.message(err));
            };
        };
    };

    var seasonHandler = SeasonHandler.SeasonHandler<system>(seasonStableData, seasonEventHandler);

    func onExecuted(proposal : Types.Proposal) : async* Result.Result<(), Text> {
        // TODO change league proposal for team data to be a simple approve w/ callback. Dont need to expose all the update routes
        switch (proposal.content) {
            case (#changeTeamName(c)) {
                let result = await TeamsActor.updateTeamName(c.teamId, c.name);
                let error = switch (result) {
                    case (#ok) return #ok;
                    case (#err(#notAuthorized)) "League is not authorized";
                    case (#err(#teamNotFound)) "Team not found";
                    case (#err(#nameTaken)) "Name is already taken";
                };
                #err("Failed to update team name: " # error);
            };
            case (#changeTeamColor(c)) {
                let result = await TeamsActor.updateTeamColor(c.teamId, c.color);
                let error = switch (result) {
                    case (#ok) return #ok;
                    case (#err(#notAuthorized)) "League is not authorized";
                    case (#err(#teamNotFound)) "Team not found";
                };
                #err("Failed to update team color: " # error);
            };
            case (#changeTeamLogo(c)) {
                let result = await TeamsActor.updateTeamLogo(c.teamId, c.logoUrl);
                let error = switch (result) {
                    case (#ok) return #ok;
                    case (#err(#notAuthorized)) "League is not authorized";
                    case (#err(#teamNotFound)) "Team not found";
                };
                #err("Failed to update team logo: " # error);
            };
            case (#changeTeamMotto(c)) {
                let result = await TeamsActor.updateTeamMotto(c.teamId, c.motto);
                let error = switch (result) {
                    case (#ok) return #ok;
                    case (#err(#notAuthorized)) "League is not authorized";
                    case (#err(#teamNotFound)) "Team not found";
                };
                #err("Failed to update team motto: " # error);
            };
            case (#changeTeamDescription(c)) {
                let result = await TeamsActor.updateTeamDescription(c.teamId, c.description);
                let error = switch (result) {
                    case (#ok) return #ok;
                    case (#err(#notAuthorized)) "League is not authorized";
                    case (#err(#teamNotFound)) "Team not found";
                };
                #err("Failed to update team description: " # error);
            };
        };
    };
    func onRejected(_ : Types.Proposal) : async* () {}; // TODO
    var dao = Dao.Dao<system, Types.ProposalContent>(daoStableData, onExecuted, onRejected);

    system func preupgrade() {
        seasonStableData := seasonHandler.toStableData();
        predictionStableData := predictionHandler.toStableData();
        scenarioStableData := scenarioHandler.toStableData();
        daoStableData := dao.toStableData();
    };

    system func postupgrade() {
        seasonHandler := SeasonHandler.SeasonHandler<system>(seasonStableData, seasonEventHandler);
        predictionHandler := PredictionHandler.Handler(predictionStableData);
        scenarioHandler := ScenarioHandler.Handler<system>(scenarioStableData, processEffectOutcomes);
        dao := Dao.Dao<system, Types.ProposalContent>(daoStableData, onExecuted, onRejected);
    };

    public shared ({ caller }) func claimBenevolentDictatorRole() : async Types.ClaimBenevolentDictatorRoleResult {
        if (benevolentDictator != #open) {
            return #err(#notOpenToClaim);
        };
        benevolentDictator := #claimed(caller);
        #ok;
    };

    public shared ({ caller }) func setBenevolentDictatorState(state : Types.BenevolentDictatorState) : async Types.SetBenevolentDictatorStateResult {
        if (not isLeagueOrDictator(caller)) {
            return #err(#notAuthorized);
        };
        benevolentDictator := state;
        #ok;
    };

    public query func getBenevolentDictatorState() : async Types.BenevolentDictatorState {
        benevolentDictator;
    };

    public query func getSeasonStatus() : async Season.SeasonStatus {
        seasonHandler.seasonStatus;
    };

    public shared ({ caller }) func createProposal(request : Types.CreateProposalRequest) : async Types.CreateProposalResult {
        let members = switch (await UsersActor.getTeamOwners(#all)) {
            case (#ok(members)) members;
        };
        switch (request.content) {
            case (#changeTeamName(_) or #changeTeamColor(_) or #changeTeamLogo(_) or #changeTeamMotto(_) or #changeTeamDescription(_)) {
                // Team is only one who can propose to change their name
                if (caller != Principal.fromActor(TeamsActor)) {
                    return #err(#notAuthorized);
                };
            };
        };
        dao.createProposal<system>(caller, request.content, members);
    };

    public shared query func getProposal(id : Nat) : async Types.GetProposalResult {
        switch (dao.getProposal(id)) {
            case (?proposal) return #ok(proposal);
            case (null) return #err(#proposalNotFound);
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
            case (null) return #err(#notFound);
        };
    };

    public query func getScenario(scenarioId : Nat) : async Types.GetScenarioResult {
        switch (scenarioHandler.getScenario(scenarioId)) {
            case (null) #err(#notFound);
            case (?scenario) {
                #ok(scenario);
            };
        };
    };

    public query func getScenarios() : async Types.GetScenariosResult {
        let openScenarios = scenarioHandler.getScenarios(false);
        #ok(openScenarios);
    };

    public shared ({ caller }) func addScenario(scenario : Types.AddScenarioRequest) : async Types.AddScenarioResult {
        if (not isLeagueOrDictator(caller)) {
            return #err(#notAuthorized);
        };
        switch (await* scenarioHandler.add<system>(scenario)) {
            case (#ok) #ok;
            case (#invalid(errors)) return #err(#invalid(errors));
        };
    };

    public shared query ({ caller }) func getScenarioVote(request : Types.GetScenarioVoteRequest) : async Types.GetScenarioVoteResult {
        scenarioHandler.getVote(request.scenarioId, caller);
    };

    public shared ({ caller }) func voteOnScenario(request : Types.VoteOnScenarioRequest) : async Types.VoteOnScenarioResult {
        await* scenarioHandler.vote(request.scenarioId, caller, request.value);
    };

    public shared ({ caller }) func startSeason(request : Types.StartSeasonRequest) : async Types.StartSeasonResult {
        if (not isLeagueOrDictator(caller)) {
            return #err(#notAuthorized);
        };
        Debug.print("Starting season");
        let seedBlob = try {
            await Random.blob();
        } catch (err) {
            return #err(#seedGenerationError(Error.message(err)));
        };
        await* initStadium(); // Hack to init stadium for calling
        await* initTeams(); // Hack to init teams for calling
        let stadiumId = Principal.fromActor(StadiumActor);
        let teamsArray = await TeamsActor.getTeams();

        let allPlayers = await PlayersActor.getAllPlayers();

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
        if (not isLeagueOrDictator(caller)) {
            return #err(#notAuthorized);
        };
        await* initTeams(); // Hack to init teams for calling
        try {
            await TeamsActor.createTeam(request);
        } catch (err) {
            return #err(#teamsCallError(Error.message(err)));
        };
    };

    public shared ({ caller }) func predictMatchOutcome(request : Types.PredictMatchOutcomeRequest) : async Types.PredictMatchOutcomeResult {
        let ?nextScheduled = seasonHandler.getNextScheduledMatchGroup() else return #err(#predictionsClosed);
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

    public shared ({ caller }) func startMatchGroup(matchGroupId : Nat) : async Types.StartMatchGroupResult {
        if (not isLeagueOrDictator(caller)) {
            return #err(#notAuthorized);
        };

        await* seasonHandler.startMatchGroup(matchGroupId);

    };

    public shared ({ caller }) func onMatchGroupComplete(
        request : Types.OnMatchGroupCompleteRequest
    ) : async Types.OnMatchGroupCompleteResult {
        Debug.print("On Match group complete called for: " # Nat.toText(request.id));
        if (caller != Principal.fromActor(StadiumActor)) {
            return #err(#notAuthorized);
        };

        let prng = try {
            PseudoRandomX.fromBlob(await Random.blob());
        } catch (err) {
            return #err(#seedGenerationError(Error.message(err)));
        };

        let result = await* seasonHandler.onMatchGroupComplete(request, prng);
        // TODO handle failure
        await* awardUserPoints(request.id, request.matches);
        result;
    };

    public shared ({ caller }) func closeSeason() : async Types.CloseSeasonResult {
        if (not isLeagueOrDictator(caller)) {
            return #err(#notAuthorized);
        };
        let result = await* seasonHandler.close();
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
                            case (#err(#notAuthorized)) ?"League is not authorized to award user points";
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

    private func isLeagueOrDictator(id : Principal) : Bool {
        if (id == Principal.fromActor(LeagueActor)) {
            // League is admin
            return true;
        };
        switch (benevolentDictator) {
            case (#open or #disabled) false;
            case (#claimed(claimantId)) return id == claimantId;
        };
    };

    private func initStadium() : async* () {

        if (not stadiumInitialized) {
            let #ok = await StadiumActor.setLeague(Principal.fromActor(LeagueActor)) else Debug.trap("Failed to set league on stadium");
            stadiumInitialized := true;
        };
    };

    private func initTeams() : async* () {
        if (not teamsInitialized) {
            let #ok = await TeamsActor.setLeague(Principal.fromActor(LeagueActor)) else Debug.trap("Failed to set league on teams");
            teamsInitialized := true;
        };
    };
};
