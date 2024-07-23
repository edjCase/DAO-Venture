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
import Array "mo:base/Array";
import Time "mo:base/Time";
import Timer "mo:base/Timer";
import Nat8 "mo:base/Nat8";
import Int "mo:base/Int";
import Float "mo:base/Float";
import IterTools "mo:itertools/Iter";
import WorldDao "../models/WorldDao";
import TownDao "../models/TownDao";
import TownsHandler "../handlers/TownsHandler";
import Town "../models/Town";
import Flag "../models/Flag";
import TimeUtil "../TimeUtil";
import World "../models/World";
import HexGrid "../models/HexGrid";

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

    type MutableWorldLocation = {
        var townId : ?Nat;
        resources : {
            gold : MutableGoldResourceInfo;
            wood : MutableWoodResourceInfo;
            food : MutableFoodResourceInfo;
            stone : MutableStoneResourceInfo;
        };
    };

    public type MutableGoldResourceInfo = {
        var difficulty : Nat;
    };

    public type MutableWoodResourceInfo = {
        var amount : Nat;
    };

    public type MutableFoodResourceInfo = {
        var amount : Nat;
    };

    public type MutableStoneResourceInfo = {
        var difficulty : Nat;
    };

    // Stables ---------------------------------------------------------

    stable let genesisTime : Time.Time = Time.now();
    stable var daysProcessed : Nat = 0;

    stable var benevolentDictator : Types.BenevolentDictatorState = #open;

    stable var reverseEffectStableData : [ReverseEffectWithDuration] = [];

    // TODO randomly generate
    stable var worldGridStableData : [World.WorldLocationWithoutId] = Array.tabulate(
        19,
        func(_ : Nat) : World.WorldLocationWithoutId = {
            townId = null;
            resources = {
                gold = { difficulty = 0 };
                wood = { amount = 0 };
                food = { amount = 0 };
                stone = { difficulty = 0 };
            };
        },
    );

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

    private func toMutableWorldLocation(location : World.WorldLocationWithoutId) : MutableWorldLocation {
        {
            var townId = location.townId;
            resources = {
                gold = { var difficulty = location.resources.gold.difficulty };
                wood = { var amount = location.resources.wood.amount };
                food = { var amount = location.resources.food.amount };
                stone = { var difficulty = location.resources.stone.difficulty };
            };
        };
    };

    private func fromMutableWorldLocation(location : MutableWorldLocation) : World.WorldLocationWithoutId {
        {
            townId = location.townId;
            resources = {
                gold = { difficulty = location.resources.gold.difficulty };
                wood = { amount = location.resources.wood.amount };
                food = { amount = location.resources.food.amount };
                stone = { difficulty = location.resources.stone.difficulty };
            };
        };
    };

    var worldGrid = worldGridStableData.vals()
    |> Iter.map(
        _,
        toMutableWorldLocation,
    )
    |> Buffer.fromIter<MutableWorldLocation>(_);

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
            case (#resource(resourceEffect)) {
                switch (townsHandler.updateResource(resourceEffect.townId, resourceEffect.kind, resourceEffect.delta, true)) {
                    case (#ok) null;
                    case (#err(e)) Debug.trap("Error updating town gold: " # debug_show (e));
                };
            };
        };
        switch (reverseEffectOrNull) {
            case (?reverseEffect) {
                reverseEffects.add(reverseEffect);
            };
            case (null) ();
        };
    };

    private func chargeTownResources(townId : Nat, resoureCosts : [Scenario.ResourceCost]) : Result.Result<(), { #notEnoughResources : [World.ResourceKind] }> {
        let costs = resoureCosts.vals()
        |> Iter.map(
            _,
            func(cost : Scenario.ResourceCost) : {
                delta : Int;
                kind : World.ResourceKind;
            } = {
                delta = -cost.amount;
                kind = cost.kind;
            },
        )
        |> Iter.toArray(_);
        switch (townsHandler.updateResourceBulk(townId, costs, false)) {
            case (#ok) #ok;
            case (#err(#notEnoughResources(r))) #err(#notEnoughResources(r));
            case (#err(#townNotFound)) Debug.trap("Town not found: " # Nat.toText(townId));
        };
    };

    var scenarioHandler = ScenarioHandler.Handler<system>(scenarioStableData, processEffectOutcome, chargeTownResources);

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

    private func resetDayTimer<system>() {
        let { timeInDay } = TimeUtil.getAge(genesisTime);
        ignore Timer.setTimer<system>(
            #nanoseconds(timeInDay),
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
        worldGridStableData := worldGrid.vals()
        |> Iter.map<MutableWorldLocation, World.WorldLocationWithoutId>(
            _,
            fromMutableWorldLocation,
        )
        |> Iter.toArray(_);
    };

    system func postupgrade() {
        reverseEffects := Buffer.fromIter<ReverseEffectWithDuration>(reverseEffectStableData.vals());
        scenarioHandler := ScenarioHandler.Handler<system>(scenarioStableData, processEffectOutcome, chargeTownResources);
        worldDao := ProposalEngine.ProposalEngine<system, WorldDao.ProposalContent>(
            worldDaoStableData,
            onWorldProposalExecute,
            onWorldProposalReject,
            onWorldProposalValidate,
        );
        townsHandler := TownsHandler.Handler<system>(townStableData);
        userHandler := UserHandler.UserHandler(userStableData);
        townDaos := buildTownDaos<system>();
        worldGrid := worldGridStableData.vals()
        |> Iter.map(
            _,
            toMutableWorldLocation,
        )
        |> Buffer.fromIter<MutableWorldLocation>(_);
    };

    // Public Methods ---------------------------------------------------------

    public shared ({ caller }) func joinWorld() : async Result.Result<(), Types.JoinWorldError> {
        // TODO restrict to NFT?/TOken holders
        let seedBlob = await Random.blob();
        let prng = PseudoRandomX.fromBlob(seedBlob);
        let towns = townsHandler.getAll();
        let randomTownId : Nat = if (towns.size() <= 0) {
            // TODO better initialization
            let height = 24;
            let width = 32;
            let image = {
                pixels = Array.tabulate(
                    height,
                    func(_ : Nat) : [Flag.Pixel] {
                        Array.tabulate(
                            width,
                            func(i : Nat) : Flag.Pixel = {
                                red = Nat8.fromNat(i);
                                green = Nat8.fromNat(i);
                                blue = Nat8.fromNat(i);
                            },
                        );
                    },
                );
            };
            let #ok(townId) = townsHandler.create<system>("First Town", image, "First Town Motto") else Debug.trap("Failed to create first town");
            let townDao = buildTownDao<system>(
                townId,
                {
                    proposalDuration = #days(3);
                    proposals = [];
                    votingThreshold = #percent({
                        percent = 50;
                        quorum = ?20;
                    });
                },
            );
            townDaos.put(
                townId,
                townDao,
            );
            worldGrid.get(0).townId := ?townId;
            townId;
        } else {
            towns.vals()
            |> Iter.map<Town.Town, Nat>(
                _,
                func(town : Town.Town) : Nat = town.id,
            )
            |> Iter.toArray(_)
            |> prng.nextArrayElement(_);
        };
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
        Debug.print("Creating proposal for town " # Nat.toText(townId));
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
        scenarioHandler.add<system>(scenario, members, towns);
    };

    public shared query ({ caller }) func getScenarioVote(request : Types.GetScenarioVoteRequest) : async Types.GetScenarioVoteResult {
        scenarioHandler.getVote(request.scenarioId, caller);
    };

    public shared ({ caller }) func voteOnScenario(request : Types.VoteOnScenarioRequest) : async Types.VoteOnScenarioResult {
        scenarioHandler.vote<system>(request.scenarioId, caller, request.value);
    };

    public shared query func getWorldGrid() : async Types.GetWorldGridResult {

        let calcuatedWorldGrid = worldGrid.vals()
        |> IterTools.mapEntries<MutableWorldLocation, World.WorldLocation>(
            _,
            func(i : Nat, location : MutableWorldLocation) : World.WorldLocation = {
                fromMutableWorldLocation(location) with
                id = i;
                coordinate = HexGrid.indexToAxialCoord(i);
            },
        )
        |> Iter.toArray(_);
        #ok(calcuatedWorldGrid);
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

    public shared query func getTopUsers(request : Types.GetTopUsersRequest) : async Types.GetTopUsersResult {
        let result = userHandler.getTopUsers(request.count, request.offset);
        #ok(result);
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
        let { days } = TimeUtil.getAge(genesisTime);
        label l loop {
            if (days <= daysProcessed) {
                break l;
            };
            processResourceGathering();
            processTownTradeResources();
            processTownConsumeResources();
            processUpdateResources();
            // TODO
            // TODO reverse effects
            daysProcessed := daysProcessed + 1;
        };
        resetDayTimer<system>();
    };

    private func processTownTradeResources() {
        // TODO
    };

    private func processTownConsumeResources() {
        // TODO
    };

    private func processUpdateResources() {
        // TODO
    };

    type TownAvailableWork = {
        townId : Nat;
        var goldCanHarvest : Nat;
        var woodCanHarvest : Nat;
        var foodCanHarvest : Nat;
        var stoneCanHarvest : Nat;
    };

    private func processResourceGathering() {
        let locationJobsMap = buildLocationJobs();
        for ((locationId, townWorkMap) in locationJobsMap.entries()) {
            let location = worldGrid.get(locationId);

            // Calculate total resource requests
            var totalWoodRequest = 0;
            var totalFoodRequest = 0;

            for ((_, townWork) in townWorkMap.entries()) {
                totalWoodRequest += townWork.woodCanHarvest;
                totalFoodRequest += townWork.foodCanHarvest;
            };

            // Calculate proportions if requests exceed available resources
            let woodProportion = Float.min(1, Float.fromInt(location.resources.wood.amount) / Float.fromInt(totalWoodRequest));
            let foodProportion = Float.min(1, Float.fromInt(location.resources.food.amount) / Float.fromInt(totalFoodRequest));

            let calculatePropotionValue = func(value : Nat, proportion : Float) : Nat {
                let adjustedValueInt = Float.toInt(Float.fromInt(value) * proportion);
                if (adjustedValueInt < 0) {
                    Debug.trap("Adjusted value is less than 0");
                };
                Int.abs(adjustedValueInt);
            };
            let addTownResource = func(townId : Nat, amount : Nat, resource : World.ResourceKind) {
                switch (townsHandler.addResource(townId, resource, amount)) {
                    case (#ok) {};
                    case (#err(#townNotFound)) Debug.trap("Town not found: " # Nat.toText(townId));
                };
            };

            // Process each town's work
            for ((townId, townWork) in townWorkMap.entries()) {
                // Adjust wood harvesting
                let adjustedWoodHarvest = calculatePropotionValue(townWork.woodCanHarvest, woodProportion);
                location.resources.wood.amount -= adjustedWoodHarvest;
                addTownResource(townId, adjustedWoodHarvest, #wood);

                // Adjust food harvesting
                let adjustedFoodHarvest = calculatePropotionValue(townWork.foodCanHarvest, foodProportion);
                location.resources.food.amount -= adjustedFoodHarvest;
                addTownResource(townId, adjustedFoodHarvest, #food);

                // Stone difficulty increases regardless of proportion
                location.resources.stone.difficulty += townWork.stoneCanHarvest;
                addTownResource(townId, townWork.stoneCanHarvest, #food);
            };
        };
    };

    private func buildLocationJobs() : HashMap.HashMap<Nat, HashMap.HashMap<Nat, TownAvailableWork>> {
        let locationTownWorkMap = HashMap.HashMap<Nat, HashMap.HashMap<Nat, TownAvailableWork>>(worldGrid.size(), Nat.equal, Nat32.fromNat);
        // Go through all the towns
        for (town in townsHandler.getAll().vals()) {
            // And for each job, add the amount of resources that can be harvested
            // from that location for that town
            label j for (job in town.jobs.vals()) {
                let #gatherResource(gatherResourceJob) = job else continue j;
                let location = worldGrid.get(gatherResourceJob.locationId);
                let amountCanHarvest = switch (gatherResourceJob.resource) {
                    case (#wood) gatherResourceJob.workerCount * town.skills.woodCutting.proficiencyLevel * town.skills.woodCutting.techLevel;
                    case (#food) gatherResourceJob.workerCount * town.skills.farming.proficiencyLevel * town.skills.farming.techLevel;
                    case (#gold) {
                        let amountInt : Int = gatherResourceJob.workerCount * town.skills.mining.proficiencyLevel * town.skills.mining.techLevel;
                        if (amountInt <= 0) 0 else Int.abs(amountInt);
                    };
                    case (#stone) {
                        let amountInt : Int = gatherResourceJob.workerCount * town.skills.mining.proficiencyLevel * town.skills.mining.techLevel - location.resources.stone.difficulty;
                        if (amountInt <= 0) 0 else Int.abs(amountInt);
                    };
                };

                let townWorkMap : HashMap.HashMap<Nat, TownAvailableWork> = switch (locationTownWorkMap.get(gatherResourceJob.locationId)) {
                    case (?townWorkMap) townWorkMap;
                    case (null) {
                        let newTownWorkMap = HashMap.HashMap<Nat, TownAvailableWork>(1, Nat.equal, Nat32.fromNat);
                        locationTownWorkMap.put(gatherResourceJob.locationId, newTownWorkMap);
                        newTownWorkMap;
                    };
                };
                let townWork : TownAvailableWork = switch (townWorkMap.get(town.id)) {
                    case (?townWork) townWork;
                    case (null) {
                        let newTownWork : TownAvailableWork = {
                            townId = town.id;
                            var goldCanHarvest = 0;
                            var woodCanHarvest = 0;
                            var foodCanHarvest = 0;
                            var stoneCanHarvest = 0;
                        };
                        townWorkMap.put(town.id, newTownWork);
                        newTownWork;
                    };
                };
                switch (gatherResourceJob.resource) {
                    case (#gold) townWork.goldCanHarvest += amountCanHarvest;
                    case (#wood) townWork.woodCanHarvest += amountCanHarvest;
                    case (#food) townWork.foodCanHarvest += amountCanHarvest;
                    case (#stone) townWork.stoneCanHarvest += amountCanHarvest;
                };
            };
        };
        locationTownWorkMap;
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
