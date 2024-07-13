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
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Float "mo:base/Float";
import Prelude "mo:base/Prelude";
import Array "mo:base/Array";
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

    let defaultLeagueIncome : Nat = 100;
    let defaultEntropyThreshold : Nat = 100;

    stable var benevolentDictator : Types.BenevolentDictatorState = #open;
    stable var leagueIncome : Nat = defaultLeagueIncome;
    stable var entropyThreshold : Nat = defaultEntropyThreshold;

    stable var seasonStableData : SeasonHandler.StableData = {
        seasonStatus = #notStarted;
        completedSeasons = [];
        reverseEffects = [];
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

    stable var teamDaoStableData : [(Nat, Dao.StableData<TeamDao.ProposalContent>)] = [];

    stable var playerStableData : PlayerHandler.StableData = {
        players = [];
        retiredPlayers = [];
        unusedFluff = [];
    };

    stable var teamStableData : TeamsHandler.StableData = {
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

    var predictionHandler = PredictionHandler.Handler(predictionStableData);
    let seasonEvents : SeasonHandler.Events = {
        onSeasonStart = Buffer.Buffer<SeasonHandler.OnSeasonStartEvent>(0);
        onMatchGroupSchedule = Buffer.Buffer<SeasonHandler.OnMatchGroupScheduleEvent>(0);
        onMatchGroupStart = Buffer.Buffer<SeasonHandler.OnMatchGroupStartEvent>(0);
        onMatchGroupComplete = Buffer.Buffer<SeasonHandler.OnMatchGroupCompleteEvent>(0);
        onSeasonComplete = Buffer.Buffer<SeasonHandler.OnSeasonCompleteEvent>(0);
        onEffectReversal = Buffer.Buffer<SeasonHandler.OnEffectReversalEvent>(0);
    };

    seasonEvents.onSeasonStart.add(
        func<system>(_ : Season.InProgressSeason) : () {
            predictionHandler.clear();
        }
    );

    seasonEvents.onMatchGroupSchedule.add(
        func<system>(matchGroupId : Nat, matchGroup : Season.ScheduledMatchGroup) : () {
            predictionHandler.addMatchGroup(matchGroupId, matchGroup.matches.size());
        }
    );

    seasonEvents.onMatchGroupStart.add(
        func<system>(
            matchGroupId : Nat,
            _ : Season.InProgressSeason,
            _ : Season.InProgressMatchGroup,
            _ : [Season.InProgressMatch],
        ) : () {
            predictionHandler.closeMatchGroup(matchGroupId);
        }
    );
    var playerHandler = PlayerHandler.PlayerHandler(playerStableData);

    private func getTeamData(teamId : Nat) : Season.InProgressTeam {
        let ?pitcher = playerHandler.getPosition(teamId, #pitcher) else Debug.trap("Pitcher not found in team " # Nat.toText(teamId));
        let ?firstBase = playerHandler.getPosition(teamId, #firstBase) else Debug.trap("First base not found in team " # Nat.toText(teamId));
        let ?secondBase = playerHandler.getPosition(teamId, #secondBase) else Debug.trap("Second base not found in team " # Nat.toText(teamId));
        let ?thirdBase = playerHandler.getPosition(teamId, #thirdBase) else Debug.trap("Third base not found in team " # Nat.toText(teamId));
        let ?shortStop = playerHandler.getPosition(teamId, #shortStop) else Debug.trap("Short stop not found in team " # Nat.toText(teamId));
        let ?leftField = playerHandler.getPosition(teamId, #leftField) else Debug.trap("Left field not found in team " # Nat.toText(teamId));
        let ?centerField = playerHandler.getPosition(teamId, #centerField) else Debug.trap("Center field not found in team " # Nat.toText(teamId));
        let ?rightField = playerHandler.getPosition(teamId, #rightField) else Debug.trap("Right field not found in team " # Nat.toText(teamId));

        {
            id = teamId;
            positions = {
                pitcher = pitcher.id;
                firstBase = firstBase.id;
                secondBase = secondBase.id;
                thirdBase = thirdBase.id;
                shortStop = shortStop.id;
                leftField = leftField.id;
                centerField = centerField.id;
                rightField = rightField.id;
            };
            anomolies = []; // TODO anomolies
        };
    };

    var seasonHandler = SeasonHandler.SeasonHandler<system>(seasonStableData, seasonEvents, getTeamData);

    var teamsHandler = TeamsHandler.Handler<system>(teamStableData);

    private func processEffectOutcome<system>(
        closeAndClearAllScenarios : <system>() -> (),
        effectOutcome : Scenario.EffectOutcome,
    ) : () {
        let result : ?{ matchCount : Nat; effect : Scenario.ReverseEffect } = switch (effectOutcome) {
            case (#injury(injuryEffect)) {
                let ?player = playerHandler.getPosition(injuryEffect.position.teamId, injuryEffect.position.position) else Debug.trap("Position " # debug_show (injuryEffect.position.position) # " not found in team " # Nat.toText(injuryEffect.position.teamId));

                switch (playerHandler.updateCondition(player.id, #injured)) {
                    case (#ok) null;
                    case (#err(e)) Debug.trap("Error updating player condition: " # debug_show (e));
                };
            };
            case (#entropy(entropyEffect)) {
                switch (teamsHandler.updateEntropy(entropyEffect.teamId, entropyEffect.delta)) {
                    case (#ok) {
                        let thresholdReached = teamsHandler.getCurrentEntropy() >= entropyThreshold;
                        if (thresholdReached) {
                            Debug.print("Entropy threshold reached, triggering league collapse");
                            // TODO archive data
                            ignore seasonHandler.close<system>();
                            seasonHandler.clear();
                            closeAndClearAllScenarios<system>();
                            teamsHandler.clear();
                            predictionHandler.clear();
                        };
                        null;
                    };
                    case (#err(e)) Debug.trap("Error updating team entropy: " # debug_show (e));
                };
            };
            case (#currency(e)) {
                switch (teamsHandler.updateCurrency(e.teamId, e.delta, true)) {
                    case (#ok) null;
                    case (#err(e)) Debug.trap("Error updating team currency: " # debug_show (e));
                };
            };
            case (#skill(s)) {
                let playerId = switch (playerHandler.getPosition(s.position.teamId, s.position.position)) {
                    case (?player) player.id;
                    case (null) Debug.trap("Position " # debug_show (s.position.position) # " not found in team " # Nat.toText(s.position.teamId));
                };
                switch (playerHandler.updateSkill(playerId, s.skill, s.delta)) {
                    case (#ok) ();
                    case (#err(e)) Debug.trap("Error updating player skill: " # debug_show (e));
                };
                switch (s.duration) {
                    case (#indefinite) null;
                    case (#matches(matchCount)) {
                        let effect = #skill({
                            playerId = playerId;
                            skill = s.skill;
                            deltaToRemove = s.delta;
                        });
                        ?{ matchCount; effect };
                    };
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
                null;
            };
            case (#leagueIncome(incomeEffect)) {
                let newIncome : Int = leagueIncome + incomeEffect.delta;
                if (newIncome <= 0) {
                    leagueIncome := 0;
                } else {
                    leagueIncome := Int.abs(newIncome);
                };
                null;
            };
            case (#entropyThreshold(entropyThresholdEffect)) {
                let newThreshold : Int = entropyThreshold + entropyThresholdEffect.delta;
                if (newThreshold <= 0) {
                    entropyThreshold := 0;
                } else {
                    entropyThreshold := Int.abs(newThreshold);
                };
                null;
            };
        };
        switch (result) {
            case (?{ matchCount; effect }) {
                seasonHandler.scheduleReverseEffect(matchCount, effect);
            };
            case (null) ();
        };
    };

    private func chargeTeamCurrency(teamId : Nat, amount : Nat) : {
        #ok;
        #notEnoughCurrency;
    } {
        switch (teamsHandler.updateCurrency(teamId, -amount, false)) {
            case (#ok) #ok;
            case (#err(#notEnoughCurrency)) #notEnoughCurrency;
            case (#err(#teamNotFound)) Debug.trap("Team not found: " # Nat.toText(teamId));
        };
    };

    var scenarioHandler = ScenarioHandler.Handler<system>(scenarioStableData, processEffectOutcome, chargeTeamCurrency);

    seasonEvents.onEffectReversal.add(
        func<system>(effects : [Scenario.ReverseEffect]) : () {
            for (effect in Iter.fromArray(effects)) {
                switch (effect) {
                    case (#skill(s)) {
                        switch (playerHandler.updateSkill(s.playerId, s.skill, -s.deltaToRemove)) {
                            case (#ok) ();
                            case (#err(e)) Debug.trap("Error updating player skill: " # debug_show (e));
                        };
                    };
                };
            };
        }
    );

    var userHandler = UserHandler.UserHandler(userStableData);

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
                    let player = switch (playerHandler.getPosition(teamId, train.position)) {
                        case (?player) player;
                        case (null) return #err("Player not found in position " # debug_show (train.position) # " for team " # Nat.toText(teamId));
                    };
                    let trainCost = Skill.get(player.skills, train.skill) + 1; // Cost is the next skill level
                    switch (teamsHandler.updateCurrency(teamId, -trainCost, false)) {
                        case (#ok) ();
                        case (#err(#notEnoughCurrency)) return #err("Not enough currency to train player");
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
        Dao.Dao<system, TeamDao.ProposalContent>(data, onProposalExecute, onProposalReject, onProposalValidate);
    };

    private func buildTeamDaos<system>() : HashMap.HashMap<Nat, Dao.Dao<TeamDao.ProposalContent>> {
        let daos = HashMap.HashMap<Nat, Dao.Dao<TeamDao.ProposalContent>>(teamDaoStableData.size(), Nat.equal, Nat32.fromNat);

        for ((teamId, data) in teamDaoStableData.vals()) {
            let teamDao = buildTeamDao<system>(teamId, data);
            daos.put(teamId, teamDao);
        };
        daos;
    };

    var teamDaos = buildTeamDaos<system>();

    func onMatchGroupComplete<system>(data : SimulationHandler.OnMatchGroupCompleteData) : () {

        switch (seasonHandler.completeMatchGroup<system>(data.matchGroupId, data.matches, data.playerStats)) {
            case (#ok) ();
            case (#err(#matchGroupNotFound)) Debug.trap("OnMatchGroupComplete Failed: Match group not found - " # Nat.toText(data.matchGroupId));
            case (#err(#seasonNotOpen)) Debug.trap("OnMatchGroupComplete Failed: Season not open");
            case (#err(#matchGroupNotInProgress)) Debug.trap("OnMatchGroupComplete Failed: Match group not in progress");
        };

        // Give winners
        for (match in data.matches.vals()) {
            Debug.print("Reducing winning teams' entropy...");
            switch (match.winner) {
                case (#team1) {
                    ignore teamsHandler.updateEntropy(match.team1.id, -1);
                };
                case (#team2) {
                    ignore teamsHandler.updateEntropy(match.team2.id, -1);
                };
                case (#tie) ();
            };
        };

        disperseCurrencyDividends();
        playerHandler.addMatchStats(data.matchGroupId, data.playerStats);
        // Award users points for their predictions
        awardUserPoints(data.matchGroupId, data.matches);
    };

    private func disperseCurrencyDividends() {
        // Give team X currency that is divided purpotionally to how much relative entropy
        // (based on combined entropy of all teams) they have
        let teams = teamsHandler.getAll();
        let proportionalWeights = teams.vals()
        |> Iter.map<Team.Team, Nat>(
            _,
            func(team : Team.Team) : Nat = team.entropy,
        )
        |> Iter.toArray(_)
        |> getProportionalEntropyWeights(_);

        Debug.print("Giving currency to teams based on entropy. League Income: " # Nat.toText(leagueIncome));

        for ((team, currencyWeight) in IterTools.zip(teams.vals(), proportionalWeights.vals())) {
            var newCurrency = Float.toInt(Float.floor(Float.fromInt(leagueIncome) * currencyWeight));
            switch (teamsHandler.updateCurrency(team.id, newCurrency, false)) {
                case (#ok) ();
                case (#err(#teamNotFound)) Debug.trap("Team not found: " # Nat.toText(team.id));
                case (#err(#notEnoughCurrency)) Debug.trap("Team " # Nat.toText(team.id) # " does not have enough currency to receive " # Int.toText(newCurrency) # " currency");
            };
            Debug.print("Team " # Nat.toText(team.id) # " share of the currency is: " # Int.toText(newCurrency) # " (weight: " # Float.toText(currencyWeight) # ")");
        };
    };

    private func getProportionalEntropyWeights(entropyValues : [Nat]) : [Float] {
        if (entropyValues.size() == 0) {
            return [];
        };
        let ?maxEntropy = IterTools.max<Nat>(entropyValues.vals(), Nat.compare) else Prelude.unreachable();
        let ?minEntropy = IterTools.min<Nat>(entropyValues.vals(), Nat.compare) else Prelude.unreachable();
        let entropyRange : Nat = maxEntropy - minEntropy;

        // If all entropy values are 0 or the total entropy is 0, return an array of equal weights
        if (maxEntropy == 0) {
            let equalWeight = 1.0 / Float.fromInt(entropyValues.size());
            return Array.tabulate<Float>(entropyValues.size(), func(_ : Nat) : Float { equalWeight });
        };

        let weights = Iter.map<Nat, Float>(
            entropyValues.vals(),
            func(entropy : Nat) : Float {
                let relativeEntropy = Float.fromInt(maxEntropy - entropy) / Float.fromInt(entropyRange);
                return relativeEntropy + 1.0;
            },
        )
        |> Iter.toArray(_);

        let totalWeight = IterTools.fold<Float, Float>(
            weights.vals(),
            0.0,
            func(sum : Float, weight : Float) : Float {
                return sum + weight;
            },
        );
        return Iter.map<Float, Float>(
            weights.vals(),
            func(weight : Float) : Float {
                return weight / totalWeight;
            },
        )
        |> Iter.toArray(_);
    };

    var simulationHandler = SimulationHandler.Handler<system>(simulationStableData, onMatchGroupComplete);

    seasonEvents.onMatchGroupStart.add(
        func<system>(
            matchGroupId : Nat,
            _ : Season.InProgressSeason,
            _ : Season.InProgressMatchGroup,
            matches : [Season.InProgressMatch],
        ) : () {
            let prng = PseudoRandomX.fromSeed(0); // TODO fix seed to use random blob

            let getPlayer = func(teamId : Nat, position : FieldPosition.FieldPosition) : Player.Player {
                switch (playerHandler.getPosition(teamId, position)) {
                    case (?player) player;
                    case (null) Debug.trap("Player not found in position " # debug_show (position) # " for team " # Nat.toText(teamId));
                };
            };

            let getTeam = func(teamId : Nat) : SimulationHandler.StartMatchTeam {
                {
                    id = teamId;
                    anomolies = []; // TODO
                    positions = {
                        pitcher = getPlayer(teamId, #pitcher);
                        firstBase = getPlayer(teamId, #firstBase);
                        secondBase = getPlayer(teamId, #secondBase);
                        thirdBase = getPlayer(teamId, #thirdBase);
                        shortStop = getPlayer(teamId, #shortStop);
                        leftField = getPlayer(teamId, #leftField);
                        centerField = getPlayer(teamId, #centerField);
                        rightField = getPlayer(teamId, #rightField);
                    };
                };
            };
            let matchRequests = matches.vals()
            |> Iter.map<Season.InProgressMatch, SimulationHandler.StartMatchRequest>(
                _,
                func(match : Season.InProgressMatch) : SimulationHandler.StartMatchRequest {
                    {
                        team1 = getTeam(match.team1.id);
                        team2 = getTeam(match.team2.id);
                    };
                },
            )
            |> Iter.toArray(_);
            switch (simulationHandler.startMatchGroup<system>(prng, matchGroupId, matchRequests)) {
                case (#ok) ();
                case (#err(#noMatchesSpecified)) Debug.trap("seasonEvents.onMatchGroupStart No matches specified: " # Nat.toText(matchGroupId));
                case (#err(#matchGroupInProgress)) Debug.trap("seasonEvents.onMatchGroupStart Match group already in progress: " # Nat.toText(matchGroupId));
            };
            ignore simulationHandler.finishMatchGroup<system>(); // TODO remove after re-implement live matches
        }
    );

    seasonEvents.onMatchGroupComplete.add(
        func<system>(_ : Nat, _ : Season.CompletedMatchGroup) : () {
            ignore simulationHandler.cancelMatchGroup();
        }
    );

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
        teamDaoStableData := teamDaos.entries()
        |> Iter.map<(Nat, Dao.Dao<TeamDao.ProposalContent>), (Nat, Dao.StableData<TeamDao.ProposalContent>)>(
            _,
            func((id, d) : (Nat, Dao.Dao<TeamDao.ProposalContent>)) : (Nat, Dao.StableData<TeamDao.ProposalContent>) = (id, d.toStableData()),
        )
        |> Iter.toArray(_);
    };

    system func postupgrade() {
        seasonHandler := SeasonHandler.SeasonHandler<system>(seasonStableData, seasonEvents, getTeamData);
        predictionHandler := PredictionHandler.Handler(predictionStableData);
        scenarioHandler := ScenarioHandler.Handler<system>(scenarioStableData, processEffectOutcome, chargeTeamCurrency);
        leagueDao := Dao.Dao<system, LeagueDao.ProposalContent>(
            leagueDaoStableData,
            onLeagueProposalExecute,
            onLeagueProposalReject,
            onLeagueProposalValidate,
        );
        playerHandler := PlayerHandler.PlayerHandler(playerStableData);
        teamsHandler := TeamsHandler.Handler<system>(teamStableData);
        userHandler := UserHandler.UserHandler(userStableData);
        simulationHandler := SimulationHandler.Handler<system>(simulationStableData, onMatchGroupComplete);
        teamDaos := buildTeamDaos<system>();
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

    public shared ({ caller }) func createTeamProposal(teamId : Nat, content : Types.TeamProposalContent) : async Types.CreateTeamProposalResult {
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
        let ?dao = teamDaos.get(teamId) else return #err(#teamNotFound);
        Debug.print("Creating proposal for team " # Nat.toText(teamId) # " with content: " # debug_show (content));
        await* dao.createProposal<system>(caller, content, members);
    };

    public shared query func getTeamProposal(teamId : Nat, id : Nat) : async Types.GetTeamProposalResult {
        let ?dao = teamDaos.get(teamId) else return #err(#teamNotFound);
        let ?proposal = dao.getProposal(id) else return #err(#proposalNotFound);
        #ok(proposal);
    };

    public shared query func getTeamProposals(teamId : Nat, count : Nat, offset : Nat) : async Types.GetTeamProposalsResult {
        let ?dao = teamDaos.get(teamId) else return #err(#teamNotFound);
        let proposals = dao.getProposals(count, offset);
        #ok(proposals);
    };

    public shared ({ caller }) func voteOnTeamProposal(teamId : Nat, request : Types.VoteOnTeamProposalRequest) : async Types.VoteOnTeamProposalResult {
        let ?dao = teamDaos.get(teamId) else return #err(#teamNotFound);
        await* dao.vote(request.proposalId, caller, request.vote);
    };

    public query func getTeamStandings() : async Types.GetTeamStandingsResult {
        let ?standings = seasonHandler.getTeamStandings() else return #err(#notFound);
        #ok(standings);
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
        scenarioHandler.vote<system>(request.scenarioId, caller, request.value);
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

        let teamIds = teamsHandler.getAll().vals()
        |> Iter.map<Team.Team, Nat>(
            _,
            func(team : Team.Team) : Nat = team.id,
        )
        |> Iter.toArray(_);

        let prng = PseudoRandomX.fromBlob(seedBlob);
        seasonHandler.startSeason<system>(
            prng,
            request.startTime,
            request.weekDays,
            teamIds,
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

        seasonHandler.startNextMatchGroup<system>();

    };

    public shared ({ caller }) func closeSeason() : async Types.CloseSeasonResult {
        if (not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        Debug.print("Season complete, clearing season data");
        switch (seasonHandler.close<system>()) {
            case (#ok) ();
            case (#err(#seasonNotOpen)) return #err(#seasonNotOpen);
        };

        // TODO archive vs delete
        // TODO teams reset currency/entropy? or is that a scenario thing
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

    public shared query func getLeagueData() : async Types.LeagueData {
        let currentEntropy = teamsHandler.getCurrentEntropy();

        {
            entropyThreshold = entropyThreshold;
            currentEntropy = currentEntropy;
            leagueIncome = leagueIncome;
        };
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
                request.entropy,
                request.currency,
            )
        ) {
            case (#ok(teamId)) teamId;
            case (#err(#nameTaken)) return #err(#nameTaken);
        };

        let daoData : Dao.StableData<TeamDao.ProposalContent> = {
            proposals = [];
            proposalDuration = #days(3);
            votingThreshold = #percent({
                percent = 50;
                quorum = ?20;
            });
        };
        let teamDao = buildTeamDao<system>(teamId, daoData);
        Debug.print("Created team " # Nat.toText(teamId));
        teamDaos.put(teamId, teamDao);

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
