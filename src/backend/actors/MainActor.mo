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
import Season "../models/Season";
import Scenario "../models/Scenario";
import SeasonHandler "SeasonHandler";
import PredictionHandler "PredictionHandler";
import ScenarioHandler "ScenarioHandler";
import Dao "../Dao";
import Result "mo:base/Result";
import UserTypes "../users/Types";
import TeamTypes "../teams/Types";
import PlayerTypes "../players/Types";

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
    stable var stats = Trie.empty<Nat32, Trie.Trie<Nat, Player.PlayerMatchStats>>();

    stable var matchGroups = Trie.empty<Nat, Types.MatchGroup>();

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
                        let result = await playersActor.applyEffects([#injury(injuryEffect)]); // TODO optimize with bulk call
                        switch (result) {
                            case (#ok) #ok;
                            case (#err(e)) #err(debug_show (e));
                        };
                    };
                    case (#entropy(entropyEffect)) {
                        let result = await teamsActor.updateTeamEntropy(entropyEffect.teamId, entropyEffect.delta);
                        switch (result) {
                            case (#ok) #ok;
                            case (#err(e)) #err(debug_show (e));
                        };
                    };
                    case (#energy(e)) {
                        let result = await teamsActor.updateTeamEnergy(e.teamId, e.delta);
                        switch (result) {
                            case (#ok) #ok;
                            case (#err(e)) #err(debug_show (e));
                        };
                    };
                    case (#skill(s)) {
                        let result = await playersActor.applyEffects([#skill(s)]); // TODO optimize with bulk call
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
            let result = await teamsActor.onMatchGroupComplete({
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
                switch (await teamsActor.onSeasonEnd()) {
                    case (#ok) ();
                    case (#err(#notAuthorized)) Debug.print("Error: League is not authorized to notify team of season completion");
                };
            } catch (err) {
                Debug.print("Failed to notify team of season completion: " # Error.message(err));
            };

            // TODO handle failures
            try {
                switch (await usersActor.onSeasonEnd()) {
                    case (#ok) ();
                    case (#err(#notAuthorized)) Debug.print("League is not authorized to call users actor 'onSeasonEnd'");
                };
            } catch (err) {
                Debug.print("Failed to call usersActor.onSeasonEnd: " # Error.message(err));
            };
            try {
                switch (await playersActor.onSeasonEnd()) {
                    case (#ok) ();
                    case (#err(#notAuthorized)) Debug.print("League is not authorized to call players actor 'onSeasonEnd'");
                };
            } catch (err) {
                Debug.print("Failed to call playersActor.onSeasonEnd: " # Error.message(err));
            };
        };
    };

    var seasonHandler = SeasonHandler.SeasonHandler<system>(seasonStableData, seasonEventHandler, playersCanisterId);

    func onExecute(proposal : Types.Proposal) : async* Result.Result<(), Text> {
        // TODO change league proposal for team data to be a simple approve w/ callback. Dont need to expose all the update routes
        switch (proposal.content) {
            case (#changeTeamName(c)) {
                let result = await teamsActor.updateTeamName(c.teamId, c.name);
                let error = switch (result) {
                    case (#ok) return #ok;
                    case (#err(#notAuthorized)) "League is not authorized";
                    case (#err(#teamNotFound)) "Team not found";
                    case (#err(#nameTaken)) "Name is already taken";
                };
                #err("Failed to update team name: " # error);
            };
            case (#changeTeamColor(c)) {
                let result = await teamsActor.updateTeamColor(c.teamId, c.color);
                let error = switch (result) {
                    case (#ok) return #ok;
                    case (#err(#notAuthorized)) "League is not authorized";
                    case (#err(#teamNotFound)) "Team not found";
                };
                #err("Failed to update team color: " # error);
            };
            case (#changeTeamLogo(c)) {
                let result = await teamsActor.updateTeamLogo(c.teamId, c.logoUrl);
                let error = switch (result) {
                    case (#ok) return #ok;
                    case (#err(#notAuthorized)) "League is not authorized";
                    case (#err(#teamNotFound)) "Team not found";
                };
                #err("Failed to update team logo: " # error);
            };
            case (#changeTeamMotto(c)) {
                let result = await teamsActor.updateTeamMotto(c.teamId, c.motto);
                let error = switch (result) {
                    case (#ok) return #ok;
                    case (#err(#notAuthorized)) "League is not authorized";
                    case (#err(#teamNotFound)) "Team not found";
                };
                #err("Failed to update team motto: " # error);
            };
            case (#changeTeamDescription(c)) {
                let result = await teamsActor.updateTeamDescription(c.teamId, c.description);
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

    public shared ({ caller }) func onLeagueCollapse() : async Types.OnLeagueCollapseResult {
        if (caller != teamsCanisterId and not isLeagueOrDictator(caller)) {
            return #err(#notAuthorized);
        };
        Debug.print("League collapsing...");
        await* seasonHandler.onLeagueCollapse();
        await* scenarioHandler.onLeagueCollapse();
        #ok;
    };

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

    public shared ({ caller }) func createTeam(request : Types.CreateTeamRequest) : async Types.CreateTeamResult {
        if (not isLeagueOrDictator(caller)) {
            return #err(#notAuthorized);
        };
        try {
            await teamsActor.createTeam(request);
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
        if (caller != stadiumCanisterId) {
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
    public shared ({ caller }) func addFluff(request : Types.CreatePlayerFluffRequest) : async Types.CreatePlayerFluffResult {
        if (not (await* isLeagueOrBDFN(caller))) {
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

    public shared ({ caller }) func populateTeamRoster(teamId : Nat) : async Types.PopulateTeamRosterResult {
        if (caller != teamsCanisterId and not (await* isLeagueOrBDFN(caller))) {
            return #err(#notAuthorized);
        };
        playerHandler.populateTeamRoster(teamId);
    };

    public shared ({ caller }) func applyEffects(request : Types.ApplyEffectsRequest) : async Types.ApplyEffectsResult {
        if (caller != teamsCanisterId and not (await* isLeagueOrBDFN(caller))) {
            return #err(#notAuthorized);
        };
        playerHandler.applyEffects(request);
    };

    public shared ({ caller }) func swapTeamPositions(
        teamId : Nat,
        position1 : FieldPosition.FieldPosition,
        position2 : FieldPosition.FieldPosition,
    ) : async Types.SwapPlayerPositionsResult {
        if (caller != teamsCanisterId and not (await* isLeagueOrBDFN(caller))) {
            return #err(#notAuthorized);
        };
        playerHandler.swapTeamPositions(teamId, position1, position2);
    };

    public shared ({ caller }) func addMatchStats(matchGroupId : Nat, playerStats : [Player.PlayerMatchStatsWithId]) : async Types.AddMatchStatsResult {
        if (not (await* isLeagueOrBDFN(caller))) {
            return #err(#notAuthorized);
        };

        let matchGroupKey = {
            key = matchGroupId;
            hash = Nat32.fromNat(matchGroupId); // TODO
        };
        for (playerStat in Iter.fromArray(playerStats)) {
            let playerKey = {
                key = playerStat.playerId;
                hash = playerStat.playerId;
            };
            let playerMatchGroupStats = switch (Trie.get(stats, playerKey, Nat32.equal)) {
                case (null) Trie.empty<Nat, Player.PlayerMatchStats>();
                case (?p) p;
            };

            let (newPlayerMatchGroupStats, oldPlayerStat) = Trie.put(playerMatchGroupStats, matchGroupKey, Nat.equal, playerStat);
            if (oldPlayerStat != null) {
                Debug.trap("Player match stats already exist for match group: " # Nat.toText(matchGroupId) # " and player: " # Nat32.toText(playerStat.playerId));
            };
            let (newStats, _) = Trie.put(stats, playerKey, Nat32.equal, newPlayerMatchGroupStats);
            stats := newStats;
        };
        #ok;
    };

    public shared ({ caller }) func onSeasonEnd() : async Types.OnSeasonEndResult {
        if (not (await* isLeagueOrBDFN(caller))) {
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

    public shared ({ caller }) func startMatchGroup(
        request : Types.StartMatchGroupRequest
    ) : async Types.StartMatchGroupResult {
        assertLeague(caller);

        let prng = PseudoRandomX.fromBlob(await Random.blob());
        let tickTimerId = startTickTimer<system>(request.id);

        let tickResults = Buffer.Buffer<Types.TickResult>(request.matches.size());
        label f for ((matchId, match) in IterTools.enumerate(Iter.fromArray(request.matches))) {

            let team1IsOffense = prng.nextCoin();
            let initState = MatchSimulator.initState(
                match.aura,
                match.team1,
                match.team2,
                team1IsOffense,
                prng,
            );
            tickResults.add({
                match = initState;
                status = #inProgress;
            });
        };
        if (tickResults.size() == 0) {
            return #err(#noMatchesSpecified);
        };

        let matchGroup : Types.MatchGroupWithId = {
            id = request.id;
            matches = Buffer.toArray(tickResults);
            tickTimerId = tickTimerId;
            currentSeed = prng.getCurrentSeed();
        };
        addOrUpdateMatchGroup(matchGroup);
        #ok;
    };

    public shared ({ caller }) func cancelMatchGroup(
        request : Types.CancelMatchGroupRequest
    ) : async Types.CancelMatchGroupResult {
        assertLeague(caller);
        let matchGroupKey = buildMatchGroupKey(request.id);
        let (newMatchGroups, matchGroup) = Trie.remove(matchGroups, matchGroupKey, Nat.equal);
        switch (matchGroup) {
            case (null) return #err(#matchGroupNotFound);
            case (?matchGroup) {
                matchGroups := newMatchGroups;
                Timer.cancelTimer(matchGroup.tickTimerId);
                #ok;
            };
        };
    };

    // TODO remove
    public shared func finishMatchGroup(id : Nat) : async () {
        // TODO check BDFN
        let ?matchGroupz = getMatchGroupOrNull(id) else Debug.trap("Match group not found");
        var matchGroup = matchGroupz;
        var prng = PseudoRandomX.LinearCongruentialGenerator(matchGroup.currentSeed);
        label l loop {
            switch (tickMatches(prng, matchGroup.matches)) {
                case (#completed(_)) break l;
                case (#inProgress(newMatches)) {
                    addOrUpdateMatchGroup({
                        matchGroup with
                        id = id;
                        matches = newMatches;
                        currentSeed = prng.getCurrentSeed();
                    });
                    let ?newMG = getMatchGroupOrNull(id) else Debug.trap("Match group not found");
                    matchGroup := newMG;
                    prng := PseudoRandomX.LinearCongruentialGenerator(matchGroup.currentSeed);
                };
            };
        };
    };

    public shared ({ caller }) func tickMatchGroup(id : Nat) : async Types.TickMatchGroupResult {
        if (caller != Principal.fromActor(this)) {
            return #err(#notAuthorized);
        };
        let ?matchGroup = getMatchGroupOrNull(id) else return #err(#matchGroupNotFound);
        let prng = PseudoRandomX.LinearCongruentialGenerator(matchGroup.currentSeed);

        switch (tickMatches(prng, matchGroup.matches)) {
            case (#completed(completedTickResults)) {
                // Cancel tick timer before disposing of match group
                // NOTE: Should be canceled even if the onMatchGroupComplete fails, so it doesnt
                // just keep ticking. Can retrigger manually if needed after fixing the
                // issue

                let completedMatches = completedTickResults
                |> Iter.fromArray(_)
                |> Iter.map(
                    _,
                    func(tickResult : CompletedMatchResult) : Season.CompletedMatch = tickResult.match,
                )
                |> Iter.toArray(_);

                let playerStats = completedTickResults
                |> Iter.fromArray(_)
                |> Iter.map(
                    _,
                    func(tickResult : CompletedMatchResult) : Iter.Iter<Player.PlayerMatchStatsWithId> = Iter.fromArray(tickResult.matchStats),
                )
                |> IterTools.flatten<Player.PlayerMatchStatsWithId>(_)
                |> Iter.toArray(_);

                Timer.cancelTimer(matchGroup.tickTimerId);
                let leagueActor = actor (Principal.toText(leagueCanisterId)) : LeagueTypes.LeagueActor;
                let onCompleteRequest : LeagueTypes.OnMatchGroupCompleteRequest = {
                    id = id;
                    matches = completedMatches;
                    playerStats = playerStats;
                };
                let result = try {
                    await leagueActor.onMatchGroupComplete(onCompleteRequest);
                } catch (err) {
                    #err(#onCompleteCallbackError(Error.message(err)));
                };

                let errorMessage = switch (result) {
                    case (#ok) {
                        // Remove match group if successfully passed info to the league
                        let matchGroupKey = buildMatchGroupKey(id);
                        let (newMatchGroups, _) = Trie.remove(matchGroups, matchGroupKey, Nat.equal);
                        matchGroups := newMatchGroups;
                        return #ok(#completed);
                    };
                    case (#err(#notAuthorized)) "Failed: Not authorized to complete match group";
                    case (#err(#matchGroupNotFound)) "Failed: Match group not found - " # Nat.toText(id);
                    case (#err(#seedGenerationError(err))) "Failed: Seed generation error - " # err;
                    case (#err(#seasonNotOpen)) "Failed: Season not open";
                    case (#err(#onCompleteCallbackError(err))) "Failed: On complete callback error - " # err;
                    case (#err(#matchGroupNotInProgress)) "Failed: Match group not in progress";
                };
                Debug.print("On Match Group Complete Result - " # errorMessage);
                // Stuck in a bad state. Can retry by a manual tick call
                #ok(#completed);
            };
            case (#inProgress(newMatches)) {
                addOrUpdateMatchGroup({
                    matchGroup with
                    id = id;
                    matches = newMatches;
                    currentSeed = prng.getCurrentSeed();
                });

                #ok(#inProgress);
            };
        };
    };

    public shared func resetTickTimer(matchGroupId : Nat) : async Types.ResetTickTimerResult {
        resetTickTimerInternal<system>(matchGroupId);
        #ok;
    };

    public shared query func getEntropyThreshold() : async Nat {
        teamsHandler.getEntropyThreshold();
    };

    public shared query func getTeams() : async [Team.Team] {
        teamsHandler.getAll();
    };

    public shared ({ caller }) func createTeam(request : Types.CreateTeamRequest) : async Types.CreateTeamResult {
        if (not (await* isLeagueOrBDFN(caller))) {
            return #err(#notAuthorized);
        };
        await* teamsHandler.create(request);
    };

    public shared ({ caller }) func updateTeamEnergy(id : Nat, delta : Int) : async Types.UpdateTeamEnergyResult {
        if (not (await* isLeagueOrBDFN(caller))) {
            return #err(#notAuthorized);
        };
        switch (teamsHandler.updateEnergy(id, delta, true)) {
            case (#ok) #ok;
            case (#err(#teamNotFound)) #err(#teamNotFound);
            case (#err(#notEnoughEnergy)) Prelude.unreachable(); // Only happens when 0 energy is min
        };
    };

    public shared ({ caller }) func updateTeamEntropy(id : Nat, delta : Int) : async Types.UpdateTeamEntropyResult {
        if (not (await* isLeagueOrBDFN(caller))) {
            return #err(#notAuthorized);
        };
        await* teamsHandler.updateEntropy(id, delta);
    };

    public shared ({ caller }) func updateTeamMotto(id : Nat, motto : Text) : async Types.UpdateTeamMottoResult {
        if (not (await* isLeagueOrBDFN(caller))) {
            return #err(#notAuthorized);
        };
        teamsHandler.updateMotto(id, motto);
    };

    public shared ({ caller }) func updateTeamDescription(id : Nat, description : Text) : async Types.UpdateTeamDescriptionResult {
        if (not (await* isLeagueOrBDFN(caller))) {
            return #err(#notAuthorized);
        };
        teamsHandler.updateDescription(id, description);
    };

    public shared ({ caller }) func updateTeamLogo(id : Nat, logoUrl : Text) : async Types.UpdateTeamLogoResult {
        if (not (await* isLeagueOrBDFN(caller))) {
            return #err(#notAuthorized);
        };
        teamsHandler.updateLogo(id, logoUrl);
    };

    public shared ({ caller }) func updateTeamColor(id : Nat, color : (Nat8, Nat8, Nat8)) : async Types.UpdateTeamColorResult {
        if (not (await* isLeagueOrBDFN(caller))) {
            return #err(#notAuthorized);
        };
        teamsHandler.updateColor(id, color);
    };

    public shared ({ caller }) func updateTeamName(id : Nat, name : Text) : async Types.UpdateTeamNameResult {
        if (not (await* isLeagueOrBDFN(caller))) {
            return #err(#notAuthorized);
        };
        teamsHandler.updateName(id, name);
    };

    public shared query func getTraits() : async [Trait.Trait] {
        teamsHandler.getTraits();
    };

    public shared ({ caller }) func createTeamTrait(request : Types.CreateTeamTraitRequest) : async Types.CreateTeamTraitResult {
        if (not (await* isLeagueOrBDFN(caller))) {
            return #err(#notAuthorized);
        };
        teamsHandler.createTrait(request);
    };

    public shared ({ caller }) func addTraitToTeam(teamId : Nat, traitId : Text) : async Types.AddTraitToTeamResult {
        if (not (await* isLeagueOrBDFN(caller))) {
            return #err(#notAuthorized);
        };
        teamsHandler.addTraitToTeam(teamId, traitId);
    };

    public shared ({ caller }) func removeTraitFromTeam(teamId : Nat, traitId : Text) : async Types.RemoveTraitFromTeamResult {
        if (not (await* isLeagueOrBDFN(caller))) {
            return #err(#notAuthorized);
        };
        teamsHandler.removeTraitFromTeam(teamId, traitId);
    };

    public shared ({ caller }) func createProposal(teamId : Nat, request : Types.CreateProposalRequest) : async Types.CreateProposalResult {
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

    public shared query func getProposal(teamId : Nat, id : Nat) : async Types.GetProposalResult {
        teamsHandler.getProposal(teamId, id);
    };

    public shared query func getProposals(teamId : Nat, count : Nat, offset : Nat) : async Types.GetProposalsResult {
        teamsHandler.getProposals(teamId, count, offset);
    };

    public shared ({ caller }) func voteOnProposal(teamId : Nat, request : Types.VoteOnProposalRequest) : async Types.VoteOnProposalResult {
        await* teamsHandler.voteOnProposal(teamId, caller, request);
    };

    public shared ({ caller }) func onMatchGroupComplete(
        request : Types.OnMatchGroupCompleteRequest
    ) : async Result.Result<(), Types.OnMatchGroupCompleteError> {
        if (not (await* isLeagueOrBDFN(caller))) {
            return #err(#notAuthorized);
        };
        teamsHandler.onMatchGroupComplete(request.matchGroup);
        #ok;
    };

    public shared ({ caller }) func onSeasonEnd() : async Types.OnSeasonEndResult {
        if (not (await* isLeagueOrBDFN(caller))) {
            return #err(#notAuthorized);
        };
        // TODO
        #ok;
    };

    public shared ({ caller }) func getCycles() : async Types.GetCyclesResult {
        if (not (await* isLeagueOrBDFN(caller))) {
            return #err(#notAuthorized);
        };
        let canisterStatus = await ic.canister_status({
            canister_id = Principal.fromActor(this);
        });
        return #ok(canisterStatus.cycles);
    };

    public shared query func get(userId : Principal) : async Types.GetUserResult {
        switch (userHandler.get(userId)) {
            case (?user) #ok(user);
            case (null) #err(#notFound);
        };
    };

    public shared query func getStats() : async Types.GetStatsResult {
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
        if (caller != userId and not (await* isLeagueOrBDFN(caller))) {
            return #err(#notAuthorized);
        };

        userHandler.setFavoriteTeam(userId, teamId);
    };

    public shared ({ caller }) func addTeamOwner(request : Types.AddTeamOwnerRequest) : async Types.AddTeamOwnerResult {
        if (not (await* isLeagueOrBDFN(caller))) {
            return #err(#notAuthorized);
        };
        userHandler.addTeamOwner(request);
    };

    // TODO change to BoomDAO or ledger
    public shared ({ caller }) func awardPoints(awards : [Types.AwardPointsRequest]) : async Types.AwardPointsResult {
        if (not (await* isLeagueOrBDFN(caller))) {
            return #err(#notAuthorized);
        };
        userHandler.awardPoints(awards);
        #ok;
    };

    public shared ({ caller }) func onSeasonEnd() : async Types.OnSeasonEndResult {
        if (not (await* isLeagueOrBDFN(caller))) {
            return #err(#notAuthorized);
        };
        // TODO
        #ok;
    };

    // Private Methods ---------------------------------------------------------

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
                        switch (await usersActor.awardPoints(Buffer.toArray(awards))) {
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

    private func resetTickTimerInternal<system>(matchGroupId : Nat) : () {
        let ?matchGroup = getMatchGroupOrNull(matchGroupId) else return;
        Timer.cancelTimer(matchGroup.tickTimerId);
        let newTickTimerId = startTickTimer<system>(matchGroupId);
        addOrUpdateMatchGroup({
            matchGroup with
            id = matchGroupId;
            tickTimerId = newTickTimerId;
        });
    };

    private func startTickTimer<system>(matchGroupId : Nat) : Timer.TimerId {
        Timer.setTimer<system>(
            #seconds(5),
            func() : async () {
                switch (await tickMatchGroupCallback(matchGroupId)) {
                    case (#err(err)) {
                        Debug.print("Failed to tick match group: " # Nat.toText(matchGroupId) # ", Error: " # err # ". Canceling tick timer. Reset with `resetTickTimer` method");
                    };
                    case (#ok(isComplete)) {
                        if (not isComplete) {
                            resetTickTimerInternal<system>(matchGroupId);
                        } else {
                            Debug.print("Match group complete: " # Nat.toText(matchGroupId));
                        };
                    };
                };
            },
        );
    };

    private func addOrUpdateMatchGroup(newMatchGroup : Types.MatchGroupWithId) : () {
        let matchGroupKey = buildMatchGroupKey(newMatchGroup.id);
        let (newMatchGroups, _) = Trie.replace(matchGroups, matchGroupKey, Nat.equal, ?newMatchGroup);
        matchGroups := newMatchGroups;
    };

    private func tickMatchGroupCallback(matchGroupId : Nat) : async Result.Result<Bool, Text> {
        try {
            switch (await tickMatchGroup(matchGroupId)) {
                case (#ok(#inProgress(_))) #ok(false);
                case (#err(#matchGroupNotFound)) #err("Match Group not found");
                case (#err(#notAuthorized)) #err("Not authorized to tick match group");
                case (#err(#onStartCallbackError(err))) #err("On start callback error: " # debug_show (err));
                case (#ok(#completed(_))) #ok(true);
            };
        } catch (err) {
            #err("Failed to tick match group: " # Error.message(err));
        };
    };

    private func tickMatches(prng : Prng, tickResults : [Types.TickResult]) : {
        #completed : [CompletedMatchResult];
        #inProgress : [Types.TickResult];
    } {
        let completedMatches = Buffer.Buffer<(Types.Match, Types.MatchStatusCompleted)>(tickResults.size());
        let updatedTickResults = Buffer.Buffer<Types.TickResult>(tickResults.size());
        for (tickResult in Iter.fromArray(tickResults)) {
            let updatedTickResult = switch (tickResult.status) {
                // Don't tick if completed
                case (#completed(c)) {
                    completedMatches.add((tickResult.match, c));
                    tickResult;
                };
                // Tick if still in progress
                case (#inProgress) MatchSimulator.tick(tickResult.match, prng);
            };
            updatedTickResults.add(updatedTickResult);
        };
        if (updatedTickResults.size() == completedMatches.size()) {
            // If all matches are complete, then complete the group
            let completedCompiledMatches = completedMatches.vals()
            |> Iter.map(
                _,
                func((match, status) : (Types.Match, Types.MatchStatusCompleted)) : CompletedMatchResult {
                    compileCompletedMatch(match, status);
                },
            )
            |> Iter.toArray(_);
            #completed(completedCompiledMatches);
        } else {
            #inProgress(Buffer.toArray(updatedTickResults));
        };
    };

    private func compileCompletedMatch(match : Types.Match, status : Types.MatchStatusCompleted) : CompletedMatchResult {
        let winner : Team.TeamIdOrTie = switch (status.reason) {
            case (#noMoreRounds) {
                if (match.team1.score > match.team2.score) {
                    #team1;
                } else if (match.team1.score == match.team2.score) {
                    #tie;
                } else {
                    #team2;
                };
            };
            case (#error(e)) #tie;
        };

        let playerStats = buildPlayerStats(match);

        {
            match : Season.CompletedMatch = {
                team1 = match.team1;
                team2 = match.team2;
                aura = match.aura;
                log = match.log;
                winner = winner;
                playerStats = playerStats;
            };
            matchStats = playerStats;
        };
    };

    private func buildPlayerStats(match : Types.Match) : [Player.PlayerMatchStatsWithId] {
        match.players.vals()
        |> Iter.map(
            _,
            func(player : Types.PlayerStateWithId) : Player.PlayerMatchStatsWithId {
                {
                    playerId = player.id;
                    battingStats = {
                        atBats = player.matchStats.battingStats.atBats;
                        hits = player.matchStats.battingStats.hits;
                        runs = player.matchStats.battingStats.runs;
                        strikeouts = player.matchStats.battingStats.strikeouts;
                        homeRuns = player.matchStats.battingStats.homeRuns;
                    };
                    catchingStats = {
                        successfulCatches = player.matchStats.catchingStats.successfulCatches;
                        missedCatches = player.matchStats.catchingStats.missedCatches;
                        throws = player.matchStats.catchingStats.throws;
                        throwOuts = player.matchStats.catchingStats.throwOuts;
                    };
                    pitchingStats = {
                        pitches = player.matchStats.pitchingStats.pitches;
                        strikes = player.matchStats.pitchingStats.strikes;
                        hits = player.matchStats.pitchingStats.hits;
                        runs = player.matchStats.pitchingStats.runs;
                        strikeouts = player.matchStats.pitchingStats.strikeouts;
                        homeRuns = player.matchStats.pitchingStats.homeRuns;
                    };
                    injuries = player.matchStats.injuries;
                };
            },
        )
        |> Iter.toArray(_);
    };

    private func getMatchGroupOrNull(matchGroupId : Nat) : ?Types.MatchGroup {
        let matchGroupKey = buildMatchGroupKey(matchGroupId);
        Trie.get(matchGroups, matchGroupKey, Nat.equal);
    };

    private func buildMatchGroupKey(matchGroupId : Nat) : {
        key : Nat;
        hash : Nat32;
    } {
        {
            hash = Nat32.fromNat(matchGroupId); // TODO better hash? shouldnt need more than 32 bits
            key = matchGroupId;
        };
    };

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
