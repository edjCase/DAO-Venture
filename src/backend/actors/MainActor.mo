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
import Types "MainActorTypes";
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
import Nat32 "mo:base/Nat32";
import Player "../models/Player";
import TeamDao "../models/TeamDao";
import FieldPosition "../models/FieldPosition";
import Team "../models/Team";
import Trait "../models/Trait";
import LiveState "../models/LiveState";
import LeagueDao "../models/LeagueDao";
import Skill "../models/Skill";
import IterTools "mo:itertools/Iter";

actor MainActor : Types.Actor {
    // Types  ---------------------------------------------------------
    type Prng = PseudoRandomX.PseudoRandomGenerator;

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
    stable var leagueDaoStableData : Dao.StableData<LeagueDao.ProposalContent> = {
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

    stable var simulationStableData : SimulationHandler.StableData = {
        matchGroupState = null;
    };

    // Unstables ---------------------------------------------------------

    var playerHandler = PlayerHandler.PlayerHandler(playerStableData);

    private func processEffectOutcome(effectOutcome : Scenario.EffectOutcome) : () {
        switch (effectOutcome) {
            case (#injury(injuryEffect)) {
                let ?player = playerHandler.getPosition(injuryEffect.target.teamId, injuryEffect.target.position) else Debug.trap("Position " # debug_show (injuryEffect.target.position) # " not found in team " # Nat.toText(injuryEffect.target.teamId));

                switch (playerHandler.updateCondition(player.id, #injured)) {
                    case (#ok) ();
                    case (#err(e)) Debug.trap("Error updating player condition: " # debug_show (e));
                };
            };
            case (#entropy(entropyEffect)) {
                switch (teamsHandler.updateEntropy(entropyEffect.teamId, entropyEffect.delta)) {
                    case (#ok) ();
                    case (#err(#overThreshold)) (); // Will check for this after processing outcomes, ignore for now
                    case (#err(e)) Debug.trap("Error updating team entropy: " # debug_show (e));
                };
            };
            case (#energy(e)) {
                switch (teamsHandler.updateEnergy(e.teamId, e.delta, true)) {
                    case (#ok) ();
                    case (#err(e)) Debug.trap("Error updating team energy: " # debug_show (e));
                };
            };
            case (#skill(s)) {
                let playerId = switch (playerHandler.getPosition(s.target.teamId, s.target.position)) {
                    case (?player) player.id;
                    case (null) Debug.trap("Position " # debug_show (s.target.position) # " not found in team " # Nat.toText(s.target.teamId));
                };
                switch (playerHandler.updateSkill(playerId, s.skill, s.delta)) {
                    case (#ok) ();
                    case (#err(e)) Debug.trap("Error updating player skill: " # debug_show (e));
                };
            };
            case (#teamTrait(t)) {
                switch (t.kind) {
                    case (#add) {
                        ignore teamsHandler.addTraitToTeam(t.teamId, t.traitId);
                    };
                    case (#remove) {
                        ignore teamsHandler.removeTraitFromTeam(t.teamId, t.traitId);
                    };
                };
            };
        };
    };

    var predictionHandler = PredictionHandler.Handler(predictionStableData);
    var scenarioHandler = ScenarioHandler.Handler<system>(scenarioStableData, processEffectOutcome);

    let seasonEventHandler : SeasonHandler.EventHandler = {
        onMatchGroupSchedule = func(matchGroupId : Nat, matchGroup : Season.ScheduledMatchGroup) : () {
            predictionHandler.addMatchGroup(matchGroupId, matchGroup.matches.size());
        };
        onMatchGroupStart = func(matchGroupId : Nat, _ : Season.InProgressMatchGroup) : () {
            predictionHandler.closeMatchGroup(matchGroupId);
        };
    };

    var seasonHandler = SeasonHandler.SeasonHandler<system>(seasonStableData, seasonEventHandler);

    func onLeagueProposalExecute(proposal : Dao.Proposal<LeagueDao.ProposalContent>) : async* Result.Result<(), Text> {
        // TODO change league proposal for team data to be a simple approve w/ callback. Dont need to expose all the update routes
        switch (proposal.content) {
            case (#changeTeamName(c)) {
                let result = teamsHandler.updateName(c.teamId, c.name);
                let error = switch (result) {
                    case (#ok) return #ok;
                    case (#err(#teamNotFound)) "Team not found";
                    case (#err(#nameTaken)) "Name is already taken";
                };
                #err("Failed to update team name: " # error);
            };
            case (#changeTeamColor(c)) {
                let result = teamsHandler.updateColor(c.teamId, c.color);
                let error = switch (result) {
                    case (#ok) return #ok;
                    case (#err(#teamNotFound)) "Team not found";
                };
                #err("Failed to update team color: " # error);
            };
            case (#changeTeamLogo(c)) {
                let result = teamsHandler.updateLogo(c.teamId, c.logoUrl);
                let error = switch (result) {
                    case (#ok) return #ok;
                    case (#err(#teamNotFound)) "Team not found";
                };
                #err("Failed to update team logo: " # error);
            };
            case (#changeTeamMotto(c)) {
                let result = teamsHandler.updateMotto(c.teamId, c.motto);
                let error = switch (result) {
                    case (#ok) return #ok;
                    case (#err(#teamNotFound)) "Team not found";
                };
                #err("Failed to update team motto: " # error);
            };
            case (#changeTeamDescription(c)) {
                let result = teamsHandler.updateDescription(c.teamId, c.description);
                let error = switch (result) {
                    case (#ok) return #ok;
                    case (#err(#teamNotFound)) "Team not found";
                };
                #err("Failed to update team description: " # error);
            };
        };
    };
    func onLeagueProposalReject(_ : Dao.Proposal<LeagueDao.ProposalContent>) : async* () {}; // TODO
    func onLeagueProposalValidate(_ : LeagueDao.ProposalContent) : async* Result.Result<(), [Text]> {
        #ok; // TODO
    };
    var leagueDao = Dao.Dao<system, LeagueDao.ProposalContent>(
        leagueDaoStableData,
        onLeagueProposalExecute,
        onLeagueProposalReject,
        onLeagueProposalValidate,
    );

    func buildTeamDao<system>(
        teamId : Nat,
        data : Dao.StableData<TeamDao.ProposalContent>,
    ) : Dao.Dao<TeamDao.ProposalContent> {

        func onProposalExecute(proposal : Dao.Proposal<TeamDao.ProposalContent>) : async* Result.Result<(), Text> {
            let createLeagueProposal = func(leagueProposalContent : LeagueDao.ProposalContent) : async* Result.Result<(), Text> {
                let members = userHandler.getTeamOwners(null);
                let result = await* leagueDao.createProposal(proposal.proposerId, leagueProposalContent, members);
                switch (result) {
                    case (#ok(_)) #ok;
                    case (#err(#notAuthorized)) #err("Not authorized to create change name proposal in league DAO");
                    case (#err(#invalid(errors))) {
                        let errorText = errors.vals()
                        |> IterTools.fold(
                            _,
                            "",
                            func(acc : Text, error : Text) : Text = acc # error # "\n",
                        );
                        #err("Invalid proposal:\n" # errorText);
                    };
                };
            };
            switch (proposal.content) {
                case (#train(train)) {
                    // TODO atomic operation
                    let player = switch (playerHandler.getPosition(teamId, train.position)) {
                        case (?player) player;
                        case (null) return #err("Player not found in position " # debug_show (train.position) # " for team " # Nat.toText(teamId));
                    };
                    let trainCost = Skill.get(player.skills, train.skill); // Cost is the current skill level
                    switch (teamsHandler.updateEnergy(teamId, -trainCost, false)) {
                        case (#ok) ();
                        case (#err(#notEnoughEnergy)) return #err("Not enough energy to train player");
                        case (#err(#teamNotFound)) return #err("Team not found: " # Nat.toText(teamId));
                    };
                    switch (playerHandler.updateSkill(player.id, train.skill, 1)) {
                        case (#ok) #ok;
                        case (#err(#playerNotFound)) #err("Player not found: " # Nat32.toText(player.id));
                    };
                };
                case (#changeName(n)) {
                    let leagueProposal = #changeTeamName({
                        teamId = teamId;
                        name = n.name;
                    });
                    await* createLeagueProposal(leagueProposal);
                };
                case (#swapPlayerPositions(swap)) {
                    switch (playerHandler.swapTeamPositions(teamId, swap.position1, swap.position2)) {
                        case (#ok) #ok;
                    };
                };
                case (#changeColor(changeColor)) {
                    await* createLeagueProposal(#changeTeamColor({ teamId = teamId; color = changeColor.color }));
                };
                case (#changeLogo(changeLogo)) {
                    await* createLeagueProposal(#changeTeamLogo({ teamId = teamId; logoUrl = changeLogo.logoUrl }));
                };
                case (#changeMotto(changeMotto)) {
                    await* createLeagueProposal(#changeTeamMotto({ teamId = teamId; motto = changeMotto.motto }));
                };
                case (#changeDescription(changeDescription)) {
                    await* createLeagueProposal(#changeTeamDescription({ teamId = teamId; description = changeDescription.description }));
                };
                case (#modifyLink(modifyLink)) {
                    switch (teamsHandler.modifyLink(teamId, modifyLink.name, modifyLink.url)) {
                        case (#ok) #ok;
                        case (#err(#teamNotFound)) #err("Team not found: " # Nat.toText(teamId));
                        case (#err(#urlRequired)) #err("URL is required when adding a new link");
                    };
                };
            };
        };

        func onProposalReject(proposal : Dao.Proposal<TeamDao.ProposalContent>) : async* () {
            Debug.print("Rejected proposal: " # debug_show (proposal));
        };
        func onProposalValidate(_ : TeamDao.ProposalContent) : async* Result.Result<(), [Text]> {
            #ok; // TODO
        };
        let dao = Dao.Dao<system, TeamDao.ProposalContent>(data, onProposalExecute, onProposalReject, onProposalValidate);
        dao;
    };

    func onLeagueCollapse() : () {
        Debug.print("Entropy threshold reached, triggering league collapse");
        seasonHandler.onLeagueCollapse();
        scenarioHandler.onLeagueCollapse();
    };

    var teamsHandler = TeamsHandler.Handler<system>(teamStableData, buildTeamDao, onLeagueCollapse);

    var userHandler = UserHandler.UserHandler(userStableData);

    private func awardUserPoints(
        matchGroupId : Nat,
        completedMatches : [Season.CompletedMatch],
    ) : () {

        // Award users points for their predictions
        let anyAwards = switch (predictionHandler.getMatchGroup(matchGroupId)) {
            case (null) false;
            case (?matchGroupPredictions) {
                let awards = Buffer.Buffer<{ userId : Principal; points : Nat }>(0);
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
                    for (award in awards.vals()) {
                        switch (userHandler.awardPoints(award.userId, award.points)) {
                            case (#ok) ();
                            case (#err(#userNotFound)) Debug.trap("User not found: " # Principal.toText(award.userId));
                        };
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

    func onMatchGroupComplete<system>(data : SimulationHandler.OnMatchGroupCompleteData) : () {

        // TODO real prng
        let prng = PseudoRandomX.fromSeed(0);
        let result = seasonHandler.onMatchGroupComplete<system>(prng, data.matchGroupId, data.matches);

        teamsHandler.onMatchGroupComplete(data.matches);
        playerHandler.addMatchStats(data.matchGroupId, data.playerStats);

        switch (result) {
            case (#ok) ();
            case (#err(#matchGroupNotFound)) Debug.trap("OnMatchGroupComplete Failed: Match group not found - " # Nat.toText(data.matchGroupId));
            case (#err(#seasonNotOpen)) Debug.trap("OnMatchGroupComplete Failed: Season not open");
            case (#err(#matchGroupNotInProgress)) Debug.trap("OnMatchGroupComplete Failed: Match group not in progress");
        };
        // Award users points for their predictions
        awardUserPoints(data.matchGroupId, data.matches);
    };

    var simulationHandler = SimulationHandler.Handler<system>(simulationStableData, onMatchGroupComplete);

    // System Methods ---------------------------------------------------------

    system func preupgrade() {
        seasonStableData := seasonHandler.toStableData();
        predictionStableData := predictionHandler.toStableData();
        scenarioStableData := scenarioHandler.toStableData();
        leagueDaoStableData := leagueDao.toStableData();
        playerStableData := playerHandler.toStableData();
        teamStableData := teamsHandler.toStableData();
        userStableData := userHandler.toStableData();
        simulationStableData := simulationHandler.toStableData();
    };

    system func postupgrade() {
        seasonHandler := SeasonHandler.SeasonHandler<system>(seasonStableData, seasonEventHandler);
        predictionHandler := PredictionHandler.Handler(predictionStableData);
        scenarioHandler := ScenarioHandler.Handler<system>(scenarioStableData, processEffectOutcome);
        leagueDao := Dao.Dao<system, LeagueDao.ProposalContent>(
            leagueDaoStableData,
            onLeagueProposalExecute,
            onLeagueProposalReject,
            onLeagueProposalValidate,
        );
        playerHandler := PlayerHandler.PlayerHandler(playerStableData);
        teamsHandler := TeamsHandler.Handler<system>(teamStableData, buildTeamDao, onLeagueCollapse);
        userHandler := UserHandler.UserHandler(userStableData);
        simulationHandler := SimulationHandler.Handler<system>(simulationStableData, onMatchGroupComplete);
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
        if (not isLeagueOrBDFN(caller)) {
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

    public shared query func getLeagueProposal(id : Nat) : async Types.GetLeagueProposalResult {
        switch (leagueDao.getProposal(id)) {
            case (?proposal) return #ok(proposal);
            case (null) return #err(#proposalNotFound);
        };
    };

    public shared query func getLeagueProposals(count : Nat, offset : Nat) : async Types.GetLeagueProposalsResult {
        #ok(leagueDao.getProposals(count, offset));
    };

    public shared ({ caller }) func voteOnLeagueProposal(request : Types.VoteOnLeagueProposalRequest) : async Types.VoteOnLeagueProposalResult {
        await* leagueDao.vote(request.proposalId, caller, request.vote);
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
        if (not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        let members = userHandler.getTeamOwners(null);
        let teams = teamsHandler.getAll();
        scenarioHandler.add<system>(scenario, members, teams);
    };

    public shared query ({ caller }) func getScenarioVote(request : Types.GetScenarioVoteRequest) : async Types.GetScenarioVoteResult {
        scenarioHandler.getVote(request.scenarioId, caller);
    };

    public shared ({ caller }) func voteOnScenario(request : Types.VoteOnScenarioRequest) : async Types.VoteOnScenarioResult {
        scenarioHandler.vote(request.scenarioId, caller, request.value);
    };

    public shared ({ caller }) func startSeason(request : Types.StartSeasonRequest) : async Types.StartSeasonResult {
        if (not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        Debug.print("Starting season");
        let seedBlob = try {
            await Random.blob();
        } catch (err) {
            return #err(#seedGenerationError(Error.message(err)));
        };

        let teamsArray = teamsHandler.getAll();

        let allPlayers = playerHandler.getAll(null);

        let prng = PseudoRandomX.fromBlob(seedBlob);
        seasonHandler.startSeason<system>(
            prng,
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

    public shared query func getLiveMatchGroupState() : async ?LiveState.LiveMatchGroupState {
        simulationHandler.getLiveMatchGroupState();
    };

    public shared ({ caller }) func startNextMatchGroup() : async Types.StartMatchGroupResult {
        if (not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };

        seasonHandler.startNextMatchGroup();

    };

    public shared ({ caller }) func closeSeason() : async Types.CloseSeasonResult {
        if (not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        Debug.print("Season complete, clearing season data");
        switch (seasonHandler.close()) {
            case (#ok) ();
            case (#err(#seasonNotOpen)) return #err(#seasonNotOpen);
        };
        ignore simulationHandler.cancelMatchGroup();
        predictionHandler.clear();

        // TODO archive vs delete
        // TODO teams reset energy/entropy? or is that a scenario thing
        #ok;
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

    // TODO remove
    public shared ({ caller }) func finishLiveMatchGroup() : async Types.FinishMatchGroupResult {
        if (not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        simulationHandler.finishMatchGroup();
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
        let teamId = switch (
            teamsHandler.create<system>(
                request.name,
                request.logoUrl,
                request.motto,
                request.description,
                request.color,
            )
        ) {
            case (#ok(teamId)) teamId;
            case (#err(#nameTaken)) return #err(#nameTaken);
        };
        switch (playerHandler.populateTeamRoster(teamId)) {
            case (#ok(_)) #ok(teamId);
            case (#err(e)) Debug.trap("Error populating team roster: " # debug_show (e));
        };
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

    public shared ({ caller }) func createTeamProposal(teamId : Nat, request : Types.CreateTeamProposalRequest) : async Types.CreateTeamProposalResult {
        let members = userHandler.getTeamOwners(?teamId);
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

    public shared query func getTeamProposal(teamId : Nat, id : Nat) : async Types.GetTeamProposalResult {
        teamsHandler.getProposal(teamId, id);
    };

    public shared query func getTeamProposals(teamId : Nat, count : Nat, offset : Nat) : async Types.GetTeamProposalsResult {
        teamsHandler.getProposals(teamId, count, offset);
    };

    public shared ({ caller }) func voteOnTeamProposal(teamId : Nat, request : Types.VoteOnTeamProposalRequest) : async Types.VoteOnTeamProposalResult {
        await* teamsHandler.voteOnProposal(teamId, caller, request.proposalId, request.vote);
    };

    public shared query func getUser(userId : Principal) : async Types.GetUserResult {
        let ?user = userHandler.get(userId) else return #err(#notFound);
        #ok(user);
    };

    public shared query func getUserStats() : async Types.GetUserStatsResult {
        let stats = userHandler.getStats();
        #ok(stats);
    };

    public shared query func getUserLeaderboard(request : Types.GetUserLeaderboardRequest) : async Types.GetUserLeaderboardResult {
        let topUsers = userHandler.getUserLeaderboard(request.count, request.offset);
        #ok(topUsers);
    };

    public shared query func getTeamOwners(request : Types.GetTeamOwnersRequest) : async Types.GetTeamOwnersResult {
        let teamId = switch (request) {
            case (#team(teamId)) ?teamId;
            case (#all) null;
        };
        let owners = userHandler.getTeamOwners(teamId);
        #ok(owners);
    };

    public shared ({ caller }) func setFavoriteTeam(userId : Principal, teamId : Nat) : async Types.SetUserFavoriteTeamResult {
        if (Principal.isAnonymous(userId)) {
            return #err(#identityRequired);
        };
        if (caller != userId and not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        let ?_ = teamsHandler.get(teamId) else return #err(#teamNotFound);
        userHandler.setFavoriteTeam(userId, teamId);
    };

    public shared ({ caller }) func addTeamOwner(request : Types.AddTeamOwnerRequest) : async Types.AddTeamOwnerResult {
        if (not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        let ?_ = teamsHandler.get(request.teamId) else return #err(#teamNotFound);
        userHandler.addTeamOwner(request.userId, request.teamId, request.votingPower);
    };

    // Private Methods ---------------------------------------------------------

    private func isLeagueOrBDFN(id : Principal) : Bool {
        if (id == Principal.fromActor(MainActor)) {
            // League is admin
            return true;
        };
        switch (benevolentDictator) {
            case (#open or #disabled) false;
            case (#claimed(claimantId)) return id == claimantId;
        };
    };

};
