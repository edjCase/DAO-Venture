import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";
import Random "mo:base/Random";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Text "mo:base/Text";
import Bool "mo:base/Bool";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Types "Types";
import Season "../models/Season";
import Scenario "../models/Scenario";
import SeasonHandler "../handlers/SeasonHandler";
import PredictionHandler "../handlers/PredictionHandler";
import ScenarioHandler "../handlers/ScenarioHandler";
import PlayerHandler "../handlers/PlayerHandler";
import TeamsHandler "../handlers/TeamsHandler";
import UserHandler "../handlers/UserHandler";
import SimulationHandler "../handlers/SimulationHandler";
import Dao "../Dao";
import Result "mo:base/Result";
import Player "../models/Player";

actor MainActor : Types.Actor {
    // Types  ---------------------------------------------------------
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    type CompletedMatchResult = {
        match : Season.CompletedMatch;
        matchStats : [Player.PlayerMatchStatsWithId];
    };

    // Stables ---------------------------------------------------------

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

    stable var playerStableData : PlayerHandler.StableData = {
        players = [];
        retiredPlayers = [];
        unusedFluff = [];
    };

    stable var teamStableData : TeamsHandler.StableData = {
        entropyThreshold = 100;
        traits = [];
        teams = [];
    };

    stable var userStableData : UserHandler.StableData = {
        users = [];
    };

    // Unstables ---------------------------------------------------------

    var playerHandler = PlayerHandler.PlayerHandler(playerStableData);

    private func processEffectOutcomes(effectOutcomes : [Scenario.EffectOutcome]) : async* ScenarioHandler.ProcessEffectOutcomesResult {
        let processedOutcomes = Buffer.Buffer<ScenarioHandler.EffectOutcomeData>(effectOutcomes.size());
        for (effectOutcome in Iter.fromArray(effectOutcomes)) {
            let processResult : Result.Result<(), Text> = try {
                switch (effectOutcome) {
                    case (#injury(injuryEffect)) {
                        let result = await playerHandler.applyEffects([#injury(injuryEffect)]); // TODO optimize with bulk call
                        switch (result) {
                            case (#ok) #ok;
                            case (#err(e)) #err(debug_show (e));
                        };
                    };
                    case (#entropy(entropyEffect)) {
                        let result = await teamsHandler.updateTeamEntropy(entropyEffect.teamId, entropyEffect.delta);
                        switch (result) {
                            case (#ok) #ok;
                            case (#err(e)) #err(debug_show (e));
                        };
                    };
                    case (#energy(e)) {
                        let result = await teamsHandler.updateTeamEnergy(e.teamId, e.delta);
                        switch (result) {
                            case (#ok) #ok;
                            case (#err(e)) #err(debug_show (e));
                        };
                    };
                    case (#skill(s)) {
                        let result = await playerHandler.applyEffects([#skill(s)]); // TODO optimize with bulk call
                        switch (result) {
                            case (#ok) #ok;
                            case (#err(e)) #err(debug_show (e));
                        };
                    };
                    case (#teamTrait(t)) {
                        let result = switch (t.kind) {
                            case (#add) await teamsActor.addTraitToTeam(t.teamId, t.traitId);
                            case (#remove) await teamsActor.removeTraitFromTeam(t.teamId, t.traitId);
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
    var scenarioHandler = ScenarioHandler.Handler<system>(scenarioStableData, processEffectOutcomes, userCanisterId, teamsCanisterId);

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
            let result = await teamsHandler.onMatchGroupComplete(request.matchGroup);
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
                switch (await teamsHandler.onSeasonEnd()) {
                    case (#ok) ();
                    case (#err(#notAuthorized)) Debug.print("Error: League is not authorized to notify team of season completion");
                };
            } catch (err) {
                Debug.print("Failed to notify team of season completion: " # Error.message(err));
            };

            // TODO handle failures
            try {
                switch (await usersHandler.onSeasonEnd()) {
                    case (#ok) ();
                    case (#err(#notAuthorized)) Debug.print("League is not authorized to call users actor 'onSeasonEnd'");
                };
            } catch (err) {
                Debug.print("Failed to call usersHandler.onSeasonEnd: " # Error.message(err));
            };
            try {
                switch (await playersHandler.onSeasonEnd()) {
                    case (#ok) ();
                    case (#err(#notAuthorized)) Debug.print("League is not authorized to call players actor 'onSeasonEnd'");
                };
            } catch (err) {
                Debug.print("Failed to call playersHandler.onSeasonEnd: " # Error.message(err));
            };
        };
    };

    var seasonHandler = SeasonHandler.SeasonHandler<system>(seasonStableData, seasonEventHandler, playersCanisterId);

    func onExecute(proposal : Types.Proposal) : async* Result.Result<(), Text> {
        // TODO change league proposal for team data to be a simple approve w/ callback. Dont need to expose all the update routes
        switch (proposal.content) {
            case (#changeTeamName(c)) {
                let result = teamsHandler.updateTeamName(c.teamId, c.name);
                let error = switch (result) {
                    case (#ok) return #ok;
                    case (#err(#notAuthorized)) "League is not authorized";
                    case (#err(#teamNotFound)) "Team not found";
                    case (#err(#nameTaken)) "Name is already taken";
                };
                #err("Failed to update team name: " # error);
            };
            case (#changeTeamColor(c)) {
                let result = teamsHandler.updateTeamColor(c.teamId, c.color);
                let error = switch (result) {
                    case (#ok) return #ok;
                    case (#err(#notAuthorized)) "League is not authorized";
                    case (#err(#teamNotFound)) "Team not found";
                };
                #err("Failed to update team color: " # error);
            };
            case (#changeTeamLogo(c)) {
                let result = teamsHandler.updateTeamLogo(c.teamId, c.logoUrl);
                let error = switch (result) {
                    case (#ok) return #ok;
                    case (#err(#notAuthorized)) "League is not authorized";
                    case (#err(#teamNotFound)) "Team not found";
                };
                #err("Failed to update team logo: " # error);
            };
            case (#changeTeamMotto(c)) {
                let result = teamsHandler.updateTeamMotto(c.teamId, c.motto);
                let error = switch (result) {
                    case (#ok) return #ok;
                    case (#err(#notAuthorized)) "League is not authorized";
                    case (#err(#teamNotFound)) "Team not found";
                };
                #err("Failed to update team motto: " # error);
            };
            case (#changeTeamDescription(c)) {
                let result = teamsHandler.updateTeamDescription(c.teamId, c.description);
                let error = switch (result) {
                    case (#ok) return #ok;
                    case (#err(#notAuthorized)) "League is not authorized";
                    case (#err(#teamNotFound)) "Team not found";
                };
                #err("Failed to update team description: " # error);
            };
        };
    };
    func onReject(_ : Types.Proposal) : async* () {}; // TODO
    func onValidate(_ : Types.ProposalContent) : async* Result.Result<(), [Text]> {
        #ok; // TODO
    };
    var dao = Dao.Dao<system, Types.ProposalContent>(daoStableData, onExecute, onReject, onValidate);

    var teamsHandler = TeamsHandler.Handler<system>(teamStableData, leagueCanisterId, playersCanisterId);

    var userHandler = UserHandler.UserHandler(userStableData);

    var simulationHandler = SimulationHandler.Handler();

    // System Methods ---------------------------------------------------------

    system func preupgrade() {
        seasonStableData := seasonHandler.toStableData();
        predictionStableData := predictionHandler.toStableData();
        scenarioStableData := scenarioHandler.toStableData();
        daoStableData := dao.toStableData();
        playerStableData := playerHandler.toStableData();
        teamStableData := teamsHandler.toStableData();
        userStableData := userHandler.toStableData();
    };

    system func postupgrade() {
        seasonHandler := SeasonHandler.SeasonHandler<system>(seasonStableData, seasonEventHandler, playersCanisterId);
        predictionHandler := PredictionHandler.Handler(predictionStableData);
        scenarioHandler := ScenarioHandler.Handler<system>(scenarioStableData, processEffectOutcomes, userCanisterId, teamsCanisterId);
        dao := Dao.Dao<system, Types.ProposalContent>(daoStableData, onExecute, onReject, onValidate);
        playerHandler := PlayerHandler.PlayerHandler(playerStableData);
        teamsHandler := TeamsHandler.Handler<system>(teamStableData, leagueCanisterId, playersCanisterId);
        userHandler := UserHandler.UserHandler(userStableData);

        // Restart the timers for any match groups that were in progress
        for ((matchGroupId, matchGroup) in Trie.iter(matchGroups)) {
            resetTickTimerInternal<system>(matchGroupId);
        };
    };

    // Public Methods ---------------------------------------------------------

    public shared ({ caller }) func claimBenevolentDictatorRole() : async Types.ClaimBenevolentDictatorRoleResult {
        if (Principal.isAnonymous(caller)) {
            return #err(#notAuthenticated);
        };
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
        let members = switch (await usersActor.getTeamOwners(#all)) {
            case (#ok(members)) members;
        };
        switch (request.content) {
            case (#changeTeamName(_) or #changeTeamColor(_) or #changeTeamLogo(_) or #changeTeamMotto(_) or #changeTeamDescription(_)) {
                // Team is only one who can propose to change their name
                if (caller != teamsCanisterId) {
                    return #err(#notAuthorized);
                };
            };
        };
        await* dao.createProposal<system>(caller, request.content, members);
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
        let ?standings = seasonHandler.teamStandings else return #err(#notFound);
        #ok(Buffer.toArray(standings));
    };

    public query func getScenario(scenarioId : Nat) : async Types.GetScenarioResult {
        let ?scenario = scenarioHandler.getScenario(scenarioId) else return #err(#notFound);
        #ok(scenario);
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
        let teamsArray = await teamsActor.getTeams();

        let allPlayers = await playersActor.getAllPlayers();

        let prng = PseudoRandomX.fromBlob(seedBlob);
        await* seasonHandler.startSeason<system>(
            prng,
            stadiumCanisterId,
            request.startTime,
            request.weekDays,
            teamsArray,
            allPlayers,
        );
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

    public shared ({ caller }) func closeSeason() : async Types.CloseSeasonResult {
        if (not isLeagueOrDictator(caller)) {
            return #err(#notAuthorized);
        };
        let result = await* seasonHandler.close();
        result;
    };
    public shared ({ caller }) func addFluff(request : Types.CreatePlayerFluffRequest) : async Types.CreatePlayerFluffResult {
        if (not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        playerHandler.addFluff(request);
    };

    public query func getPlayer(id : Nat32) : async Types.GetPlayerResult {
        switch (playerHandler.get(id)) {
            case (?player) {
                #ok(player);
            };
            case (null) {
                #err(#notFound);
            };
        };
    };

    public query func getPosition(teamId : Nat, position : FieldPosition.FieldPosition) : async Result.Result<Player.Player, Types.GetPositionError> {
        switch (playerHandler.getPosition(teamId, position)) {
            case (?player) #ok(player);
            case (null) #err(#teamNotFound);
        };
    };

    public query func getTeamPlayers(teamId : Nat) : async [Player.Player] {
        playerHandler.getAll(?teamId);
    };

    public query func getAllPlayers() : async [Player.Player] {
        playerHandler.getAll(null);
    };

    public shared ({ caller }) func onSeasonEnd() : async Types.OnSeasonEndResult {
        if (not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        // TODO archive?
        stats := Trie.empty<Nat32, Trie.Trie<Nat, Player.PlayerMatchStats>>();
        #ok;
    };

    public query func getMatchGroup(id : Nat) : async ?Types.MatchGroupWithId {
        switch (getMatchGroupOrNull(id)) {
            case (null) return null;
            case (?m) {
                ?{
                    m with
                    id = id;
                };
            };
        };
    };

    public query func getMatchGroups() : async [Types.MatchGroupWithId] {
        matchGroups
        |> Trie.iter(_)
        |> Iter.map(
            _,
            func(m : (Nat, Types.MatchGroup)) : Types.MatchGroupWithId = {
                m.1 with
                id = m.0;
            },
        )
        |> Iter.toArray(_);
    };

    public shared ({ caller }) func cancelMatchGroup(
        request : Types.CancelMatchGroupRequest
    ) : async Types.CancelMatchGroupResult {
        if (not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        simulationHandler.cancelMatchGroup(request.id);
    };

    // TODO remove
    public shared func finishMatchGroup(id : Nat) : async () {
        if (not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        simulationHandler.finishMatchGroup(id);
    };

    public shared query func getEntropyThreshold() : async Nat {
        teamsHandler.getEntropyThreshold();
    };

    public shared query func getTeams() : async [Team.Team] {
        teamsHandler.getAll();
    };

    public shared ({ caller }) func createTeam(request : Types.CreateTeamRequest) : async Types.CreateTeamResult {
        if (not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        await* teamsHandler.create(request);
    };

    public shared ({ caller }) func updateTeamEnergy(id : Nat, delta : Int) : async Types.UpdateTeamEnergyResult {
        if (not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        switch (teamsHandler.updateEnergy(id, delta, true)) {
            case (#ok) #ok;
            case (#err(#teamNotFound)) #err(#teamNotFound);
            case (#err(#notEnoughEnergy)) Prelude.unreachable(); // Only happens when 0 energy is min
        };
    };

    public shared ({ caller }) func updateTeamEntropy(id : Nat, delta : Int) : async Types.UpdateTeamEntropyResult {
        if (not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        await* teamsHandler.updateEntropy(id, delta);
    };

    public shared ({ caller }) func updateTeamMotto(id : Nat, motto : Text) : async Types.UpdateTeamMottoResult {
        if (not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        teamsHandler.updateMotto(id, motto);
    };

    public shared ({ caller }) func updateTeamDescription(id : Nat, description : Text) : async Types.UpdateTeamDescriptionResult {
        if (not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        teamsHandler.updateDescription(id, description);
    };

    public shared ({ caller }) func updateTeamLogo(id : Nat, logoUrl : Text) : async Types.UpdateTeamLogoResult {
        if (not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        teamsHandler.updateLogo(id, logoUrl);
    };

    public shared ({ caller }) func updateTeamColor(id : Nat, color : (Nat8, Nat8, Nat8)) : async Types.UpdateTeamColorResult {
        if (not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        teamsHandler.updateColor(id, color);
    };

    public shared ({ caller }) func updateTeamName(id : Nat, name : Text) : async Types.UpdateTeamNameResult {
        if (not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        teamsHandler.updateName(id, name);
    };

    public shared query func getTraits() : async [Trait.Trait] {
        teamsHandler.getTraits();
    };

    public shared ({ caller }) func createTeamTrait(request : Types.CreateTeamTraitRequest) : async Types.CreateTeamTraitResult {
        if (not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        teamsHandler.createTrait(request);
    };

    public shared ({ caller }) func createTeamProposal(teamId : Nat, request : Types.CreateProposalRequest) : async Types.CreateProposalResult {
        let members = switch (await usersActor.getTeamOwners(#team(teamId))) {
            case (#ok(members)) members;
        };
        let isAMember = members
        |> Iter.fromArray(_)
        |> Iter.filter(
            _,
            func(member : Dao.Member) : Bool = member.id == caller,
        )
        |> _.next() != null;
        if (not isAMember) {
            return #err(#notAuthorized);
        };
        await* teamsHandler.createProposal<system>(teamId, caller, request, members);
    };

    public shared query func getTeamProposal(teamId : Nat, id : Nat) : async Types.GetProposalResult {
        teamsHandler.getProposal(teamId, id);
    };

    public shared query func getTeamProposals(teamId : Nat, count : Nat, offset : Nat) : async Types.GetProposalsResult {
        teamsHandler.getProposals(teamId, count, offset);
    };

    public shared ({ caller }) func voteOnTeamProposal(teamId : Nat, request : Types.VoteOnProposalRequest) : async Types.VoteOnProposalResult {
        await* teamsHandler.voteOnProposal(teamId, caller, request);
    };

    public shared ({ caller }) func getCycles() : async Types.GetCyclesResult {
        if (not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        let canisterStatus = await ic.canister_status({
            canister_id = Principal.fromActor(this);
        });
        return #ok(canisterStatus.cycles);
    };

    public shared query func getUser(userId : Principal) : async Types.GetUserResult {
        let ?user = userHandler.get(userId) else return #err(#notFound);
        #ok(user);
    };

    public shared query func getUserStats() : async Types.GetStatsResult {
        let stats = userHandler.getStats();
        #ok(stats);
    };

    public shared query func getUserLeaderboard(request : Types.GetUserLeaderboardRequest) : async Types.GetUserLeaderboardResult {
        let topUsers = userHandler.getUserLeaderboard(request.count, request.offset);
        #ok(topUsers);
    };

    public shared query func getTeamOwners(request : Types.GetTeamOwnersRequest) : async Types.GetTeamOwnersResult {
        let owners = userHandler.getTeamOwners(request);
        #ok(owners);
    };

    public shared ({ caller }) func setFavoriteTeam(userId : Principal, teamId : Nat) : async Types.SetUserFavoriteTeamResult {
        if (Principal.isAnonymous(userId)) {
            return #err(#identityRequired);
        };
        if (caller != userId and not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };

        userHandler.setFavoriteTeam(userId, teamId);
    };

    public shared ({ caller }) func addTeamOwner(request : Types.AddTeamOwnerRequest) : async Types.AddTeamOwnerResult {
        if (not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        userHandler.addTeamOwner(request);
    };

    // Private Methods ---------------------------------------------------------

    private func isLeagueOrDictator(id : Principal) : Bool {
        if (id == Principal.fromActor(this)) {
            // League is admin
            return true;
        };
        switch (benevolentDictator) {
            case (#open or #disabled) false;
            case (#claimed(claimantId)) return id == claimantId;
        };
    };

};
