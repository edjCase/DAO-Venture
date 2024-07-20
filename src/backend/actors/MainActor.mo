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
import Scenario "../models/Scenario";
import ScenarioHandler "../handlers/ScenarioHandler";
import UserHandler "../handlers/UserHandler";
import ProposalEngine "mo:dao-proposal-engine/ProposalEngine";
import ProposalTypes "mo:dao-proposal-engine/Types";
import Result "mo:base/Result";
import Nat32 "mo:base/Nat32";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Float "mo:base/Float";
import Prelude "mo:base/Prelude";
import Array "mo:base/Array";
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
    stable var leagueDaoStableData : ProposalTypes.StableData<LeagueDao.ProposalContent> = {
        proposalDuration = #days(3);
        proposals = [];
        votingThreshold = #percent({
            percent = 50;
            quorum = ?20;
        });
    };

    stable var townDaoStableData : [(Nat, ProposalTypes.StableData<TownDao.ProposalContent>)] = [];

    stable var playerStableData : PlayerHandler.StableData = {
        players = [];
        retiredPlayers = [];
        unusedFluff = [];
    };

    stable var townStableData : TownsHandler.StableData = {
        traits = [];
        towns = [];
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

    private func getTownData(townId : Nat) : Season.InProgressTown {
        let ?pitcher = playerHandler.getPosition(townId, #pitcher) else Debug.trap("Pitcher not found in town " # Nat.toText(townId));
        let ?firstBase = playerHandler.getPosition(townId, #firstBase) else Debug.trap("First base not found in town " # Nat.toText(townId));
        let ?secondBase = playerHandler.getPosition(townId, #secondBase) else Debug.trap("Second base not found in town " # Nat.toText(townId));
        let ?thirdBase = playerHandler.getPosition(townId, #thirdBase) else Debug.trap("Third base not found in town " # Nat.toText(townId));
        let ?shortStop = playerHandler.getPosition(townId, #shortStop) else Debug.trap("Short stop not found in town " # Nat.toText(townId));
        let ?leftField = playerHandler.getPosition(townId, #leftField) else Debug.trap("Left field not found in town " # Nat.toText(townId));
        let ?centerField = playerHandler.getPosition(townId, #centerField) else Debug.trap("Center field not found in town " # Nat.toText(townId));
        let ?rightField = playerHandler.getPosition(townId, #rightField) else Debug.trap("Right field not found in town " # Nat.toText(townId));

        {
            id = townId;
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

    var seasonHandler = SeasonHandler.SeasonHandler<system>(seasonStableData, seasonEvents, getTownData);

    var townsHandler = TownsHandler.Handler<system>(townStableData);

    private func processEffectOutcome<system>(
        closeAndClearAllScenarios : <system>() -> (),
        effectOutcome : Scenario.EffectOutcome,
    ) : () {
        let result : ?{ matchCount : Nat; effect : Scenario.ReverseEffect } = switch (effectOutcome) {
            case (#injury(injuryEffect)) {
                let ?player = playerHandler.getPosition(injuryEffect.position.townId, injuryEffect.position.position) else Debug.trap("Position " # debug_show (injuryEffect.position.position) # " not found in town " # Nat.toText(injuryEffect.position.townId));

                switch (playerHandler.updateCondition(player.id, #injured)) {
                    case (#ok) null;
                    case (#err(e)) Debug.trap("Error updating player condition: " # debug_show (e));
                };
            };
            case (#entropy(entropyEffect)) {
                switch (townsHandler.updateEntropy(entropyEffect.townId, entropyEffect.delta)) {
                    case (#ok) {
                        let thresholdReached = townsHandler.getCurrentEntropy() >= entropyThreshold;
                        if (thresholdReached) {
                            Debug.print("Entropy threshold reached, triggering league collapse");
                            // TODO archive data
                            ignore seasonHandler.close<system>();
                            seasonHandler.clear();
                            closeAndClearAllScenarios<system>();
                            townsHandler.clear();
                            predictionHandler.clear();
                        };
                        null;
                    };
                    case (#err(e)) Debug.trap("Error updating town entropy: " # debug_show (e));
                };
            };
            case (#currency(e)) {
                switch (townsHandler.updateCurrency(e.townId, e.delta, true)) {
                    case (#ok) null;
                    case (#err(e)) Debug.trap("Error updating town currency: " # debug_show (e));
                };
            };
            case (#skill(s)) {
                let playerId = switch (playerHandler.getPosition(s.position.townId, s.position.position)) {
                    case (?player) player.id;
                    case (null) Debug.trap("Position " # debug_show (s.position.position) # " not found in town " # Nat.toText(s.position.townId));
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
            case (#townTrait(t)) {
                switch (t.kind) {
                    case (#add) {
                        ignore townsHandler.addTraitToTown(t.townId, t.traitId);
                    };
                    case (#remove) {
                        ignore townsHandler.removeTraitFromTown(t.townId, t.traitId);
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

    private func chargeTownCurrency(townId : Nat, amount : Nat) : {
        #ok;
        #notEnoughCurrency;
    } {
        switch (townsHandler.updateCurrency(townId, -amount, false)) {
            case (#ok) #ok;
            case (#err(#notEnoughCurrency)) #notEnoughCurrency;
            case (#err(#townNotFound)) Debug.trap("Town not found: " # Nat.toText(townId));
        };
    };

    var scenarioHandler = ScenarioHandler.Handler<system>(scenarioStableData, processEffectOutcome, chargeTownCurrency);

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

    func onLeagueProposalExecute(proposal : ProposalTypes.Proposal<LeagueDao.ProposalContent>) : async* Result.Result<(), Text> {
        // TODO change league proposal for town data to be a simple approve w/ callback. Dont need to expose all the update routes
        switch (proposal.content) {
            case (#motion(_)) {
                // Do nothing
                #ok;
            };
            case (#changeTownName(c)) {
                let result = townsHandler.updateName(c.townId, c.name);
                let error = switch (result) {
                    case (#ok) return #ok;
                    case (#err(#townNotFound)) "Town not found";
                    case (#err(#nameTaken)) "Name is already taken";
                };
                #err("Failed to update town name: " # error);
            };
            case (#changeTownColor(c)) {
                let result = townsHandler.updateColor(c.townId, c.color);
                let error = switch (result) {
                    case (#ok) return #ok;
                    case (#err(#townNotFound)) "Town not found";
                };
                #err("Failed to update town color: " # error);
            };
            case (#changeTownLogo(c)) {
                let result = townsHandler.updateLogo(c.townId, c.logoUrl);
                let error = switch (result) {
                    case (#ok) return #ok;
                    case (#err(#townNotFound)) "Town not found";
                };
                #err("Failed to update town logo: " # error);
            };
            case (#changeTownMotto(c)) {
                let result = townsHandler.updateMotto(c.townId, c.motto);
                let error = switch (result) {
                    case (#ok) return #ok;
                    case (#err(#townNotFound)) "Town not found";
                };
                #err("Failed to update town motto: " # error);
            };
            case (#changeTownDescription(c)) {
                let result = townsHandler.updateDescription(c.townId, c.description);
                let error = switch (result) {
                    case (#ok) return #ok;
                    case (#err(#townNotFound)) "Town not found";
                };
                #err("Failed to update town description: " # error);
            };
        };
    };
    func onLeagueProposalReject(_ : ProposalTypes.Proposal<LeagueDao.ProposalContent>) : async* () {}; // TODO
    func onLeagueProposalValidate(_ : LeagueDao.ProposalContent) : async* Result.Result<(), [Text]> {
        #ok; // TODO
    };
    var leagueDao = ProposalEngine.ProposalEngine<system, LeagueDao.ProposalContent>(
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
                    for ((userId, townId) in Iter.fromArray(matchPredictions)) {
                        if (townId == match.winner) {
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

    func buildTownDao<system>(
        townId : Nat,
        data : ProposalTypes.StableData<TownDao.ProposalContent>,
    ) : ProposalEngine.ProposalEngine<TownDao.ProposalContent> {

        func onProposalExecute(proposal : ProposalTypes.Proposal<TownDao.ProposalContent>) : async* Result.Result<(), Text> {
            let createLeagueProposal = func(leagueProposalContent : LeagueDao.ProposalContent) : async* Result.Result<(), Text> {
                let members = userHandler.getTownOwners(null);
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
                case (#motion(_)) {
                    // Do nothing
                    #ok;
                };
                case (#train(train)) {
                    let player = switch (playerHandler.getPosition(townId, train.position)) {
                        case (?player) player;
                        case (null) return #err("Player not found in position " # debug_show (train.position) # " for town " # Nat.toText(townId));
                    };
                    let trainCost = Skill.get(player.skills, train.skill) + 1; // Cost is the next skill level
                    switch (townsHandler.updateCurrency(townId, -trainCost, false)) {
                        case (#ok) ();
                        case (#err(#notEnoughCurrency)) return #err("Not enough currency to train player");
                        case (#err(#townNotFound)) return #err("Town not found: " # Nat.toText(townId));
                    };
                    switch (playerHandler.updateSkill(player.id, train.skill, 1)) {
                        case (#ok) #ok;
                        case (#err(#playerNotFound)) #err("Player not found: " # Nat32.toText(player.id));
                    };
                };
                case (#changeName(n)) {
                    let leagueProposal = #changeTownName({
                        townId = townId;
                        name = n.name;
                    });
                    await* createLeagueProposal(leagueProposal);
                };
                case (#swapPlayerPositions(swap)) {
                    switch (playerHandler.swapTownPositions(townId, swap.position1, swap.position2)) {
                        case (#ok) #ok;
                    };
                };
                case (#changeColor(changeColor)) {
                    await* createLeagueProposal(#changeTownColor({ townId = townId; color = changeColor.color }));
                };
                case (#changeLogo(changeLogo)) {
                    await* createLeagueProposal(#changeTownLogo({ townId = townId; logoUrl = changeLogo.logoUrl }));
                };
                case (#changeMotto(changeMotto)) {
                    await* createLeagueProposal(#changeTownMotto({ townId = townId; motto = changeMotto.motto }));
                };
                case (#changeDescription(changeDescription)) {
                    await* createLeagueProposal(#changeTownDescription({ townId = townId; description = changeDescription.description }));
                };
                case (#modifyLink(modifyLink)) {
                    switch (townsHandler.modifyLink(townId, modifyLink.name, modifyLink.url)) {
                        case (#ok) #ok;
                        case (#err(#townNotFound)) #err("Town not found: " # Nat.toText(townId));
                        case (#err(#urlRequired)) #err("URL is required when adding a new link");
                    };
                };
            };
        };

        func onProposalReject(proposal : ProposalTypes.Proposal<TownDao.ProposalContent>) : async* () {
            Debug.print("Rejected proposal: " # debug_show (proposal));
        };
        func onProposalValidate(_ : TownDao.ProposalContent) : async* Result.Result<(), [Text]> {
            #ok; // TODO
        };
        ProposalEngine.ProposalEngine<system, TownDao.ProposalContent>(data, onProposalExecute, onProposalReject, onProposalValidate);
    };

    private func buildTownDaos<system>() : HashMap.HashMap<Nat, ProposalEngine.ProposalEngine<TownDao.ProposalContent>> {
        let daos = HashMap.HashMap<Nat, ProposalEngine.ProposalEngine<TownDao.ProposalContent>>(townDaoStableData.size(), Nat.equal, Nat32.fromNat);

        for ((townId, data) in townDaoStableData.vals()) {
            let townDao = buildTownDao<system>(townId, data);
            daos.put(townId, townDao);
        };
        daos;
    };

    var townDaos = buildTownDaos<system>();

    func onMatchGroupComplete<system>(data : SimulationHandler.OnMatchGroupCompleteData) : () {

        switch (seasonHandler.completeMatchGroup<system>(data.matchGroupId, data.matches, data.playerStats)) {
            case (#ok) ();
            case (#err(#matchGroupNotFound)) Debug.trap("OnMatchGroupComplete Failed: Match group not found - " # Nat.toText(data.matchGroupId));
            case (#err(#seasonNotOpen)) Debug.trap("OnMatchGroupComplete Failed: Season not open");
            case (#err(#matchGroupNotInProgress)) Debug.trap("OnMatchGroupComplete Failed: Match group not in progress");
        };

        // Give winners
        for (match in data.matches.vals()) {
            Debug.print("Reducing winning towns' entropy...");
            switch (match.winner) {
                case (#town1) {
                    ignore townsHandler.updateEntropy(match.town1.id, -1);
                };
                case (#town2) {
                    ignore townsHandler.updateEntropy(match.town2.id, -1);
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
        // Give town X currency that is divided purpotionally to how much relative entropy
        // (based on combined entropy of all towns) they have
        let towns = townsHandler.getAll();
        let proportionalWeights = towns.vals()
        |> Iter.map<Town.Town, Nat>(
            _,
            func(town : Town.Town) : Nat = town.entropy,
        )
        |> Iter.toArray(_)
        |> getProportionalEntropyWeights(_);

        Debug.print("Giving currency to towns based on entropy. League Income: " # Nat.toText(leagueIncome));

        for ((town, currencyWeight) in IterTools.zip(towns.vals(), proportionalWeights.vals())) {
            var newCurrency = Float.toInt(Float.floor(Float.fromInt(leagueIncome) * currencyWeight));
            switch (townsHandler.updateCurrency(town.id, newCurrency, false)) {
                case (#ok) ();
                case (#err(#townNotFound)) Debug.trap("Town not found: " # Nat.toText(town.id));
                case (#err(#notEnoughCurrency)) Debug.trap("Town " # Nat.toText(town.id) # " does not have enough currency to receive " # Int.toText(newCurrency) # " currency");
            };
            Debug.print("Town " # Nat.toText(town.id) # " share of the currency is: " # Int.toText(newCurrency) # " (weight: " # Float.toText(currencyWeight) # ")");
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

            let getPlayer = func(townId : Nat, position : FieldPosition.FieldPosition) : Player.Player {
                switch (playerHandler.getPosition(townId, position)) {
                    case (?player) player;
                    case (null) Debug.trap("Player not found in position " # debug_show (position) # " for town " # Nat.toText(townId));
                };
            };

            let getTown = func(townId : Nat) : SimulationHandler.StartMatchTown {
                {
                    id = townId;
                    anomolies = []; // TODO
                    positions = {
                        pitcher = getPlayer(townId, #pitcher);
                        firstBase = getPlayer(townId, #firstBase);
                        secondBase = getPlayer(townId, #secondBase);
                        thirdBase = getPlayer(townId, #thirdBase);
                        shortStop = getPlayer(townId, #shortStop);
                        leftField = getPlayer(townId, #leftField);
                        centerField = getPlayer(townId, #centerField);
                        rightField = getPlayer(townId, #rightField);
                    };
                };
            };
            let matchRequests = matches.vals()
            |> Iter.map<Season.InProgressMatch, SimulationHandler.StartMatchRequest>(
                _,
                func(match : Season.InProgressMatch) : SimulationHandler.StartMatchRequest {
                    {
                        town1 = getTown(match.town1.id);
                        town2 = getTown(match.town2.id);
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
        townStableData := townsHandler.toStableData();
        userStableData := userHandler.toStableData();
        simulationStableData := simulationHandler.toStableData();
        townDaoStableData := townDaos.entries()
        |> Iter.map<(Nat, ProposalEngine.ProposalEngine<TownDao.ProposalContent>), (Nat, ProposalTypes.StableData<TownDao.ProposalContent>)>(
            _,
            func((id, d) : (Nat, ProposalEngine.ProposalEngine<TownDao.ProposalContent>)) : (Nat, ProposalTypes.StableData<TownDao.ProposalContent>) = (id, d.toStableData()),
        )
        |> Iter.toArray(_);
    };

    system func postupgrade() {
        seasonHandler := SeasonHandler.SeasonHandler<system>(seasonStableData, seasonEvents, getTownData);
        predictionHandler := PredictionHandler.Handler(predictionStableData);
        scenarioHandler := ScenarioHandler.Handler<system>(scenarioStableData, processEffectOutcome, chargeTownCurrency);
        leagueDao := ProposalEngine.ProposalEngine<system, LeagueDao.ProposalContent>(
            leagueDaoStableData,
            onLeagueProposalExecute,
            onLeagueProposalReject,
            onLeagueProposalValidate,
        );
        playerHandler := PlayerHandler.PlayerHandler(playerStableData);
        townsHandler := TownsHandler.Handler<system>(townStableData);
        userHandler := UserHandler.UserHandler(userStableData);
        simulationHandler := SimulationHandler.Handler<system>(simulationStableData, onMatchGroupComplete);
        townDaos := buildTownDaos<system>();
    };

    // Public Methods ---------------------------------------------------------

    public shared ({ caller }) func joinLeague() : async Result.Result<(), Types.JoinLeagueError> {
        // TODO restrict to NFT?/TOken holders
        let seedBlob = await Random.blob();
        let prng = PseudoRandomX.fromBlob(seedBlob);
        let towns = townsHandler.getAll();
        if (towns.size() <= 0) {
            return #err(#noTowns);
        };
        let randomTownId : Nat = towns.vals()
        |> Iter.map<Town.Town, Nat>(
            _,
            func(town : Town.Town) : Nat = town.id,
        )
        |> Iter.toArray(_)
        |> prng.nextArrayElement(_);
        let votingPower = 1; // TODO get voting power from token
        userHandler.addLeagueMember(caller, randomTownId, votingPower);
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

    public shared ({ caller }) func createLeagueProposal(request : Types.CreateLeagueProposalRequest) : async Types.CreateLeagueProposalResult {
        let members = userHandler.getTownOwners(null);
        let isAMember = members
        |> Iter.fromArray(_)
        |> Iter.filter(
            _,
            func(member : ProposalTypes.Member) : Bool = member.id == caller,
        )
        |> _.next() != null;
        if (not isAMember) {
            return #err(#notAuthorized);
        };
        Debug.print("Creating proposal for league with content: " # debug_show (request));
        await* leagueDao.createProposal<system>(caller, request, members);
    };

    public shared ({ caller }) func voteOnLeagueProposal(request : Types.VoteOnLeagueProposalRequest) : async Types.VoteOnLeagueProposalResult {
        await* leagueDao.vote(request.proposalId, caller, request.vote);
    };

    public shared ({ caller }) func createTownProposal(townId : Nat, content : Types.TownProposalContent) : async Types.CreateTownProposalResult {
        let members = userHandler.getTownOwners(?townId);
        let isAMember = members
        |> Iter.fromArray(_)
        |> Iter.filter(
            _,
            func(member : ProposalTypes.Member) : Bool = member.id == caller,
        )
        |> _.next() != null;
        if (not isAMember) {
            return #err(#notAuthorized);
        };
        let ?dao = townDaos.get(townId) else return #err(#townNotFound);
        Debug.print("Creating proposal for town " # Nat.toText(townId) # " with content: " # debug_show (content));
        await* dao.createProposal<system>(caller, content, members);
    };

    public shared query func getTownProposal(townId : Nat, id : Nat) : async Types.GetTownProposalResult {
        let ?dao = townDaos.get(townId) else return #err(#townNotFound);
        let ?proposal = dao.getProposal(id) else return #err(#proposalNotFound);
        #ok(proposal);
    };

    public shared query func getTownProposals(townId : Nat, count : Nat, offset : Nat) : async Types.GetTownProposalsResult {
        let ?dao = townDaos.get(townId) else return #err(#townNotFound);
        let proposals = dao.getProposals(count, offset);
        #ok(proposals);
    };

    public shared ({ caller }) func voteOnTownProposal(townId : Nat, request : Types.VoteOnTownProposalRequest) : async Types.VoteOnTownProposalResult {
        let ?dao = townDaos.get(townId) else return #err(#townNotFound);
        await* dao.vote(request.proposalId, caller, request.vote);
    };

    public query func getTownStandings() : async Types.GetTownStandingsResult {
        let ?standings = seasonHandler.getTownStandings() else return #err(#notFound);
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
        let members = userHandler.getTownOwners(null);
        let towns = townsHandler.getAll();
        scenarioHandler.add<system>(scenario, members, towns);
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

        let townIds = townsHandler.getAll().vals()
        |> Iter.map<Town.Town, Nat>(
            _,
            func(town : Town.Town) : Nat = town.id,
        )
        |> Iter.toArray(_);

        let prng = PseudoRandomX.fromBlob(seedBlob);
        seasonHandler.startSeason<system>(
            prng,
            request.startTime,
            request.weekDays,
            townIds,
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
        // TODO towns reset currency/entropy? or is that a scenario thing
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

    public query func getPosition(townId : Nat, position : FieldPosition.FieldPosition) : async Result.Result<Player.Player, Types.GetPositionError> {
        switch (playerHandler.getPosition(townId, position)) {
            case (?player) #ok(player);
            case (null) #err(#townNotFound);
        };
    };

    public query func getTownPlayers(townId : Nat) : async [Player.Player] {
        playerHandler.getAll(?townId);
    };

    public query func getAllPlayers() : async [Player.Player] {
        playerHandler.getAll(null);
    };

    public shared query func getLeagueData() : async Types.LeagueData {
        let currentEntropy = townsHandler.getCurrentEntropy();

        {
            entropyThreshold = entropyThreshold;
            currentEntropy = currentEntropy;
            leagueIncome = leagueIncome;
        };
    };

    public shared query func getTowns() : async [Town.Town] {
        townsHandler.getAll();
    };

    public shared ({ caller }) func createTown(request : Types.CreateTownRequest) : async Types.CreateTownResult {
        if (not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        let townId = switch (
            townsHandler.create<system>(
                request.name,
                request.logoUrl,
                request.motto,
                request.description,
                request.color,
                request.entropy,
                request.currency,
            )
        ) {
            case (#ok(townId)) townId;
            case (#err(#nameTaken)) return #err(#nameTaken);
        };

        let daoData : ProposalTypes.StableData<TownDao.ProposalContent> = {
            proposals = [];
            proposalDuration = #days(3);
            votingThreshold = #percent({
                percent = 50;
                quorum = ?20;
            });
        };
        let townDao = buildTownDao<system>(townId, daoData);
        Debug.print("Created town " # Nat.toText(townId));
        townDaos.put(townId, townDao);

        switch (playerHandler.populateTownRoster(townId)) {
            case (#ok(_)) #ok(townId);
            case (#err(e)) Debug.trap("Error populating town roster: " # debug_show (e));
        };
    };

    public shared query func getTraits() : async [Trait.Trait] {
        townsHandler.getTraits();
    };

    public shared ({ caller }) func createTownTrait(request : Types.CreateTownTraitRequest) : async Types.CreateTownTraitResult {
        if (not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        townsHandler.createTrait(request);
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

    public shared query func getTownOwners(request : Types.GetTownOwnersRequest) : async Types.GetTownOwnersResult {
        let townId = switch (request) {
            case (#town(townId)) ?townId;
            case (#all) null;
        };
        let owners = userHandler.getTownOwners(townId);
        #ok(owners);
    };

    public shared ({ caller }) func assignUserToTown(request : Types.AssignUserToTownRequest) : async Result.Result<(), Types.AssignUserToTownError> {
        if (not isLeagueOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        let ?_ = townsHandler.get(request.townId) else return #err(#townNotFound);
        userHandler.changeTown(request.userId, request.townId);
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
