import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";
import Random "mo:base/Random";
import Debug "mo:base/Debug";
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
import Time "mo:base/Time";
import Timer "mo:base/Timer";
import IterTools "mo:itertools/Iter";
import WorldDao "../models/WorldDao";
import TownDao "../models/TownDao";
import TownsHandler "../handlers/TownsHandler";
import Town "../models/Town";

actor MainActor : Types.Actor {
    // Types  ---------------------------------------------------------
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    type ReverseEffectWithDuration = {
        duration : Duration;
        effect : Scenario.ReverseEffect;
    };

    type Duration = {
        #days : Nat;
    };

    // Stables ---------------------------------------------------------

    let defaultWorldIncome : Nat = 100;
    let defaultEntropyThreshold : Nat = 100;

    stable let genesisTime : Time.Time = Time.now();
    stable var daysProcessed : Nat = 0;

    stable var benevolentDictator : Types.BenevolentDictatorState = #open;
    stable var worldIncome : Nat = defaultWorldIncome;
    stable var entropyThreshold : Nat = defaultEntropyThreshold;

    stable var reverseEffectStableData : [ReverseEffectWithDuration] = [];

    stable var scenarioStableData : ScenarioHandler.StableData = {
        scenarios = [];
    };
    stable var worldDaoStableData : ProposalTypes.StableData<WorldDao.ProposalContent> = {
        proposalDuration = #days(3);
        proposals = [];
        votingThreshold = #percent({
            percent = 50;
            quorum = ?20;
        });
    };

    stable var townDaoStableData : [(Nat, ProposalTypes.StableData<TownDao.ProposalContent>)] = [];

    stable var townStableData : TownsHandler.StableData = {
        towns = [];
    };

    stable var userStableData : UserHandler.StableData = {
        users = [];
    };

    // Unstables ---------------------------------------------------------

    var reverseEffects = Buffer.fromIter<ReverseEffectWithDuration>(reverseEffectStableData.vals());

    var townsHandler = TownsHandler.Handler<system>(townStableData);

    private func processEffectOutcome<system>(
        effectOutcome : Scenario.EffectOutcome
    ) : () {
        let reverseEffectOrNull : ?ReverseEffectWithDuration = switch (effectOutcome) {
            case (#entropy(entropyEffect)) {
                switch (townsHandler.updateEntropy(entropyEffect.townId, entropyEffect.delta)) {
                    case (#ok) {
                        // TODO check if entropy is above threshold
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
            case (#worldIncome(incomeEffect)) {
                let newIncome : Int = worldIncome + incomeEffect.delta;
                if (newIncome <= 0) {
                    worldIncome := 0;
                } else {
                    worldIncome := Int.abs(newIncome);
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
        switch (reverseEffectOrNull) {
            case (?reverseEffect) {
                reverseEffects.add(reverseEffect);
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

    var userHandler = UserHandler.UserHandler(userStableData);

    func onWorldProposalExecute(proposal : ProposalTypes.Proposal<WorldDao.ProposalContent>) : async* Result.Result<(), Text> {
        // TODO change world proposal for town data to be a simple approve w/ callback. Dont need to expose all the update routes
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
            case (#changeTownFlag(c)) {
                let result = townsHandler.updateFlag(c.townId, c.flagImage);
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
        };
    };
    func onWorldProposalReject(_ : ProposalTypes.Proposal<WorldDao.ProposalContent>) : async* () {}; // TODO
    func onWorldProposalValidate(_ : WorldDao.ProposalContent) : async* Result.Result<(), [Text]> {
        #ok; // TODO
    };
    var worldDao = ProposalEngine.ProposalEngine<system, WorldDao.ProposalContent>(
        worldDaoStableData,
        onWorldProposalExecute,
        onWorldProposalReject,
        onWorldProposalValidate,
    );

    func buildTownDao<system>(
        townId : Nat,
        data : ProposalTypes.StableData<TownDao.ProposalContent>,
    ) : ProposalEngine.ProposalEngine<TownDao.ProposalContent> {

        func onProposalExecute(proposal : ProposalTypes.Proposal<TownDao.ProposalContent>) : async* Result.Result<(), Text> {
            let createWorldProposal = func(worldProposalContent : WorldDao.ProposalContent) : async* Result.Result<(), Text> {
                let members = userHandler.getTownOwners(null);
                let result = await* worldDao.createProposal(proposal.proposerId, worldProposalContent, members);
                switch (result) {
                    case (#ok(_)) #ok;
                    case (#err(#notAuthorized)) #err("Not authorized to create change name proposal in world DAO");
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
                case (#changeName(n)) {
                    let worldProposal = #changeTownName({
                        townId = townId;
                        name = n.name;
                    });
                    await* createWorldProposal(worldProposal);
                };
                case (#changeFlag(changeFlag)) {
                    await* createWorldProposal(#changeTownFlag({ townId = townId; flagImage = changeFlag.image }));
                };
                case (#changeMotto(changeMotto)) {
                    await* createWorldProposal(#changeTownMotto({ townId = townId; motto = changeMotto.motto }));
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

        Debug.print("Giving currency to towns based on entropy. World Income: " # Nat.toText(worldIncome));

        for ((town, currencyWeight) in IterTools.zip(towns.vals(), proportionalWeights.vals())) {
            var newCurrency = Float.toInt(Float.floor(Float.fromInt(worldIncome) * currencyWeight));
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

    private func getDayInfo() : { timeTillNextDay : Nat; currentDay : Nat } {
        let timeElapsed = Time.now() - genesisTime;
        if (timeElapsed < 0) {
            Debug.trap("Time elapsed is negative: " # Int.toText(timeElapsed));
        };
        let timeElapsedNat : Nat = Int.abs(timeElapsed);
        let dayInNanos : Nat = 60 * 60 * 24 * 1_000_000_000;
        let timeTillNextDay : Nat = timeElapsedNat % dayInNanos;
        let currentDay : Nat = timeElapsedNat / dayInNanos;
        { timeTillNextDay = timeTillNextDay; currentDay = currentDay };
    };

    private func resetDayTimer<system>() {
        let { timeTillNextDay } = getDayInfo();
        ignore Timer.setTimer<system>(
            #nanoseconds(timeTillNextDay),
            func() : async () {
                await* processDays();
            },
        );
    };

    // System Methods ---------------------------------------------------------

    system func preupgrade() {
        reverseEffectStableData := Buffer.toArray(reverseEffects);
        scenarioStableData := scenarioHandler.toStableData();
        worldDaoStableData := worldDao.toStableData();
        townStableData := townsHandler.toStableData();
        userStableData := userHandler.toStableData();
        townDaoStableData := townDaos.entries()
        |> Iter.map<(Nat, ProposalEngine.ProposalEngine<TownDao.ProposalContent>), (Nat, ProposalTypes.StableData<TownDao.ProposalContent>)>(
            _,
            func((id, d) : (Nat, ProposalEngine.ProposalEngine<TownDao.ProposalContent>)) : (Nat, ProposalTypes.StableData<TownDao.ProposalContent>) = (id, d.toStableData()),
        )
        |> Iter.toArray(_);
    };

    system func postupgrade() {
        reverseEffects := Buffer.fromIter<ReverseEffectWithDuration>(reverseEffectStableData.vals());
        scenarioHandler := ScenarioHandler.Handler<system>(scenarioStableData, processEffectOutcome, chargeTownCurrency);
        worldDao := ProposalEngine.ProposalEngine<system, WorldDao.ProposalContent>(
            worldDaoStableData,
            onWorldProposalExecute,
            onWorldProposalReject,
            onWorldProposalValidate,
        );
        townsHandler := TownsHandler.Handler<system>(townStableData);
        userHandler := UserHandler.UserHandler(userStableData);
        townDaos := buildTownDaos<system>();
    };

    // Public Methods ---------------------------------------------------------

    public shared ({ caller }) func joinWorld() : async Result.Result<(), Types.JoinWorldError> {
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
        userHandler.addWorldMember(caller, randomTownId, votingPower);
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
        if (not isWorldOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        benevolentDictator := state;
        #ok;
    };

    public query func getBenevolentDictatorState() : async Types.BenevolentDictatorState {
        benevolentDictator;
    };

    public shared query func getWorldProposal(id : Nat) : async Types.GetWorldProposalResult {
        switch (worldDao.getProposal(id)) {
            case (?proposal) return #ok(proposal);
            case (null) return #err(#proposalNotFound);
        };
    };

    public shared query func getWorldProposals(count : Nat, offset : Nat) : async Types.GetWorldProposalsResult {
        #ok(worldDao.getProposals(count, offset));
    };

    public shared ({ caller }) func createWorldProposal(request : Types.CreateWorldProposalRequest) : async Types.CreateWorldProposalResult {
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
        Debug.print("Creating proposal for world with content: " # debug_show (request));
        await* worldDao.createProposal<system>(caller, request, members);
    };

    public shared ({ caller }) func voteOnWorldProposal(request : Types.VoteOnWorldProposalRequest) : async Types.VoteOnWorldProposalResult {
        await* worldDao.vote(request.proposalId, caller, request.vote);
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

    public query func getScenario(scenarioId : Nat) : async Types.GetScenarioResult {
        let ?scenario = scenarioHandler.getScenario(scenarioId) else return #err(#notFound);
        #ok(scenario);
    };

    public query func getScenarios() : async Types.GetScenariosResult {
        let openScenarios = scenarioHandler.getScenarios(false);
        #ok(openScenarios);
    };

    public shared ({ caller }) func addScenario(scenario : Types.AddScenarioRequest) : async Types.AddScenarioResult {
        if (not isWorldOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        let members = userHandler.getTownOwners(null);
        let towns = townsHandler.getAll();
        let townsWithStats : [ScenarioHandler.TownWithStats] = towns.vals()
        |> Iter.map<Town.Town, ScenarioHandler.TownWithStats>(
            _,
            func(town : Town.Town) : ScenarioHandler.TownWithStats = {
                town with
                age = 1; // TODO
                population = 1; // TODO
                size = 1; // TODO
            },
        )
        |> Iter.toArray(_);
        scenarioHandler.add<system>(scenario, members, townsWithStats);
    };

    public shared query ({ caller }) func getScenarioVote(request : Types.GetScenarioVoteRequest) : async Types.GetScenarioVoteResult {
        scenarioHandler.getVote(request.scenarioId, caller);
    };

    public shared ({ caller }) func voteOnScenario(request : Types.VoteOnScenarioRequest) : async Types.VoteOnScenarioResult {
        scenarioHandler.vote<system>(request.scenarioId, caller, request.value);
    };

    public shared query func getWorldData() : async Types.WorldData {
        let currentEntropy = townsHandler.getCurrentEntropy();

        {
            entropyThreshold = entropyThreshold;
            currentEntropy = currentEntropy;
            worldIncome = worldIncome;
        };
    };

    public shared query func getTowns() : async [Town.Town] {
        townsHandler.getAll();
    };

    public shared query func getUser(userId : Principal) : async Types.GetUserResult {
        let ?user = userHandler.get(userId) else return #err(#notFound);
        #ok(user);
    };

    public shared query func getUserStats() : async Types.GetUserStatsResult {
        let stats = userHandler.getStats();
        #ok(stats);
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
        if (not isWorldOrBDFN(caller)) {
            return #err(#notAuthorized);
        };
        let ?_ = townsHandler.get(request.townId) else return #err(#townNotFound);
        userHandler.changeTown(request.userId, request.townId);
    };

    // Private Methods ---------------------------------------------------------

    private func processDays() : async* () {
        let { currentDay } = getDayInfo();
        label l loop {
            if (currentDay <= daysProcessed) {
                break l;
            };
            disperseCurrencyDividends();
            // TODO reverse effects
            daysProcessed := daysProcessed + 1;
        };
        resetDayTimer<system>();
    };

    private func isWorldOrBDFN(id : Principal) : Bool {
        if (id == Principal.fromActor(MainActor)) {
            // World is admin
            return true;
        };
        switch (benevolentDictator) {
            case (#open or #disabled) false;
            case (#claimed(claimantId)) return id == claimantId;
        };
    };

};
