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
    var dayTimerId : ?Timer.TimerId = null;

    stable var benevolentDictator : Types.BenevolentDictatorState = #open;

    stable var reverseEffectStableData : [ReverseEffectWithDuration] = [];

    // TODO randomly generate
    stable var worldGridStableData : [World.WorldLocationWithoutId] = Array.tabulate(
        19,
        func(_ : Nat) : World.WorldLocationWithoutId = {
            townId = null;
            resources = {
                gold = { difficulty = 0 };
                wood = { amount = 1000 };
                food = { amount = 1000 };
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

    private func chargeTownResources(townId : Nat, resoureCosts : [Scenario.ResourceCost]) : Result.Result<(), { #notEnoughResources : [{ defecit : Nat; kind : World.ResourceKind }] }> {
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
            switch (proposal.content) {
                case (#motion(_)) {
                    // Do nothing
                    #ok;
                };
                case (#changeName(c)) {
                    let result = townsHandler.updateName(townId, c.name);
                    let error = switch (result) {
                        case (#ok) return #ok;
                        case (#err(#townNotFound)) "Town not found";
                        case (#err(#nameTaken)) "Name is already taken";
                    };
                    #err("Failed to update name: " # error);
                };
                case (#changeFlag(c)) {
                    let result = townsHandler.updateFlag(townId, c.image);
                    let error = switch (result) {
                        case (#ok) return #ok;
                        case (#err(#townNotFound)) "Town not found";
                    };
                    #err("Failed to update flag: " # error);
                };
                case (#changeMotto(c)) {
                    let result = townsHandler.updateMotto(townId, c.motto);
                    let error = switch (result) {
                        case (#ok) return #ok;
                        case (#err(#townNotFound)) "Town not found";
                    };
                    #err("Failed to update motto: " # error);
                };
                case (#addJob(addJob)) {
                    let error = switch (townsHandler.addJob(townId, addJob.job)) {
                        case (#ok(_)) return #ok;
                        case (#err(#townNotFound)) "Town not found";
                        case (#err(#notEnoughWorkers)) "Not enough workers";
                    };
                    #err("Failed to add job:" # error);
                };
                case (#updateJob(updateJob)) {
                    let error = switch (townsHandler.updateJob(townId, updateJob.jobId, updateJob.job)) {
                        case (#ok(_)) return #ok;
                        case (#err(#townNotFound)) "Town not found";
                        case (#err(#notEnoughWorkers)) "Not enough workers";
                        case (#err(#jobNotFound)) "Job not found";
                    };
                    #err("Failed to update job:" # error);
                };
                case (#removeJob(removeJob)) {
                    let error = switch (townsHandler.removeJob(townId, removeJob.jobId)) {
                        case (#ok) return #ok;
                        case (#err(#townNotFound)) "Town not found";
                        case (#err(#jobNotFound)) "Job not found";
                    };
                    #err("Failed to remove job:" # error);
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

    private func resetDayTimer<system>(runImmediately : Bool) {
        let timeTillNextDay = if (runImmediately) {
            0;
        } else {
            let { timeTillNextDay } = TimeUtil.getAge(genesisTime);
            timeTillNextDay;
        };
        Debug.print("Resetting day timer for " # Int.toText(timeTillNextDay / 1_000_000_000) # " seconds");
        switch (dayTimerId) {
            case (?id) Timer.cancelTimer(id);
            case (null) ();
        };
        dayTimerId := ?Timer.setTimer<system>(
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
        resetDayTimer<system>(true); // TODO is this sufficient if there is any weird down time?
    };

    // Public Methods ---------------------------------------------------------

    public shared ({ caller }) func joinWorld() : async Result.Result<(), Types.JoinWorldError> {
        // TODO restrict to NFT?/TOken holders
        let seedBlob = await Random.blob();
        let prng = PseudoRandomX.fromBlob(seedBlob);
        let towns = townsHandler.getAll();
        let randomTownId : Nat = if (towns.size() <= 0) {
            // TODO better initialization
            let height : Nat = 12;
            let width : Nat = 16;

            let image = {
                pixels = Array.tabulate<[Flag.Pixel]>(
                    height,
                    func(_ : Nat) : [Flag.Pixel] {
                        Array.tabulate<Flag.Pixel>(
                            width,
                            func(i : Nat) : Flag.Pixel {
                                let factor : Nat = (i * 255) / (width - 1);
                                {
                                    red = Nat8.fromNat(factor);
                                    green = Nat8.fromNat(factor);
                                    blue = Nat8.fromNat(factor);
                                };
                            },
                        );
                    },
                );
            };
            let resources = {
                gold = 1000;
                wood = 1000;
                food = 1000;
                stone = 1000;
            };
            let #ok(townId) = townsHandler.create<system>(
                "First Town",
                image,
                "First Town Motto",
                resources,
            ) else Debug.trap("Failed to create first town");
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

    public shared query func getWorld() : async Types.GetWorldResult {
        let calcuatedWorldLocations = worldGrid.vals()
        |> IterTools.mapEntries<MutableWorldLocation, World.WorldLocation>(
            _,
            func(i : Nat, location : MutableWorldLocation) : World.WorldLocation = {
                fromMutableWorldLocation(location) with
                id = i;
                coordinate = HexGrid.indexToAxialCoord(i);
            },
        )
        |> Iter.toArray(_);
        let { days; nextDayStartTime } = TimeUtil.getAge(genesisTime);
        #ok({
            age = days;
            nextDayStartTime = nextDayStartTime;
            locations = calcuatedWorldLocations;
        });
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
        Debug.print("Processing days");
        let { days } = TimeUtil.getAge(genesisTime);
        label l loop {
            if (days <= daysProcessed) {
                break l;
            };
            Debug.print("Processing day " # Nat.toText(daysProcessed));
            processResourceGathering();
            processTownTradeResources();
            processTownConsumeResources();
            processRegenResources();
            processPopulationGrowth();
            // TODO
            // TODO reverse effects
            daysProcessed := daysProcessed + 1;
        };
        Debug.print("All days processed");
        resetDayTimer<system>(false);
    };

    private func processPopulationGrowth() {
        // TODO ability to pause growth or should excess food be required???
        for (town in townsHandler.getAll().vals()) {
            if (town.health <= 0) {
                // Dying town
                let tenPercentPop : Nat = Nat.max(1, town.population / 10); // TODO 10%?
                Debug.print("Town's population " # Nat.toText(town.id) # " is dying from lack of health. Death count: " # Nat.toText(tenPercentPop));
                switch (townsHandler.updatePopulation(town.id, -tenPercentPop)) {
                    case (#ok) ();
                    case (#err(#townNotFound)) Debug.trap("Town not found: " # Nat.toText(town.id));
                    case (#err(#populationExtinct)) {
                        // TODO
                        Debug.print("Town " # Nat.toText(town.id) # " has died out");
                    };
                };
            };
        };
    };

    private func processTownTradeResources() {
        // TODO
    };

    private func processTownConsumeResources() {
        // TODO
        for (town in townsHandler.getAll().vals()) {
            // Food Consumption
            switch (townsHandler.updateResource(town.id, #food, -town.population, false)) {
                case (#ok) {
                    let healthIncrease = 10; // TODO how much for being fed?
                    switch (townsHandler.updateHealth(town.id, healthIncrease)) {
                        case (#ok(_)) ();
                        case (#err(#townNotFound)) Debug.trap("Town not found: " # Nat.toText(town.id));
                    };
                };
                case (#err(#notEnoughResource(_))) {
                    let healthDecrease = -10; // TODO how much for being NOT being fed?
                    Debug.print("Town " # Nat.toText(town.id) # " does not have enough food to feed its population, reducing health by " # Int.toText(-healthDecrease));
                    switch (townsHandler.updateHealth(town.id, healthDecrease)) {
                        case (#ok(_)) ();
                        case (#err(#townNotFound)) Debug.trap("Town not found: " # Nat.toText(town.id));
                    };

                };
                case (#err(#townNotFound)) Debug.trap("Town not found: " # Nat.toText(town.id));
            };

            // Size maintenance costs
            if (town.size > 0) {
                let payMaintenanceResource = func(resource : World.ResourceKind) {
                    let cost = town.size * 10; // TODO
                    switch (townsHandler.updateResource(town.id, resource, -cost, false)) {
                        case (#ok) {
                            let conditionIncrease = 10; // TODO how much for being upkept?
                            switch (townsHandler.updateUpkeepCondition(town.id, conditionIncrease)) {
                                case (#ok(_)) ();
                                case (#err(#townNotFound)) Debug.trap("Town not found: " # Nat.toText(town.id));
                            };
                        };
                        case (#err(#notEnoughResource(_))) {
                            let conditionDecrease = -10; // TODO how much for being NOT being upkept?
                            Debug.print("Town " # Nat.toText(town.id) # " does not have enough " # debug_show (resource) # " to pay maintenance, reducing condition by " # Int.toText(-conditionDecrease));
                            switch (townsHandler.updateUpkeepCondition(town.id, conditionDecrease)) {
                                case (#ok(_)) ();
                                case (#err(#townNotFound)) Debug.trap("Town not found: " # Nat.toText(town.id));
                            };
                        };
                        case (#err(#townNotFound)) Debug.trap("Town not found: " # Nat.toText(town.id));
                    };
                };

                payMaintenanceResource(#wood);
                payMaintenanceResource(#stone);
            };
        };
    };

    private func processRegenResources() {
        for ((locationId, location) in IterTools.enumerate(worldGrid.vals())) {
            let foodRegenAmount = calculateRegeneration(location.resources.food.amount);
            if (foodRegenAmount > 0) {
                location.resources.food.amount += foodRegenAmount;
                Debug.print("Food regeneration amount for location " # Nat.toText(locationId) # ": " # Nat.toText(foodRegenAmount));
            };

            let woodRegenAmount = calculateRegeneration(location.resources.wood.amount);
            if (woodRegenAmount > 0) {
                location.resources.wood.amount += woodRegenAmount;
                Debug.print("Wood regeneration amount for location " # Nat.toText(locationId) # ": " # Nat.toText(woodRegenAmount));
            };
        };
    };

    private func calculateRegeneration(currentAmount : Nat) : Nat {
        let maxResource = 1000.0;
        let regenRate = 0.05;
        let optimalResourceLevel = 0.7 * maxResource;
        let depletionThreshold = 0.3 * maxResource;
        let resourceRatio = Float.fromInt(currentAmount) / maxResource;
        let currentAmountFloat = Float.fromInt(currentAmount);

        let amountFloat : Float = if (resourceRatio >= 1.0) {
            0; // No regeneration if at or above max capacity
        } else if (resourceRatio > optimalResourceLevel / maxResource) {
            // Slow regeneration above optimal level
            regenRate * (1.0 - resourceRatio) * currentAmountFloat;
        } else if (currentAmountFloat > depletionThreshold) {
            // Normal regeneration between depletion threshold and optimal level
            regenRate * currentAmountFloat;
        } else {
            // Fast regeneration below depletion threshold
            regenRate * (optimalResourceLevel / currentAmountFloat) * currentAmountFloat;
        };
        if (amountFloat <= 0) {
            0;
        } else {
            Int.abs(Float.toInt(amountFloat));
        };
    };

    type TownAvailableWork = {
        townId : Nat;
        var goldCanHarvest : Nat;
        var woodCanHarvest : Nat;
        var foodCanHarvest : Nat;
        var stoneCanHarvest : Nat;
    };

    private func processResourceGathering() {
        Debug.print("Processing resource gathering");
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

            let calculateProportion = func(value : Nat, total : Nat) : Float {
                if (total == 0) {
                    return 0;
                };
                Float.min(1, Float.fromInt(value) / Float.fromInt(total));
            };

            // Calculate proportions if requests exceed available resources
            let woodProportion = calculateProportion(location.resources.wood.amount, totalWoodRequest);
            let foodProportion = calculateProportion(location.resources.food.amount, totalFoodRequest);

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

            // let addProficiencyExperience = func(townId : Nat, resource : World.ResourceKind, workers : Nat) {
            //     let proficiency = switch (resource) {
            //         case (#wood) #woodCutting;
            //         case (#food) #farming;
            //         case (#gold) #mining;
            //         case (#stone) #mining;
            //     };
            //     switch (townsHandler.addProficiencyExperience(townId, proficiency, workers)) {
            //         case (#ok) ();
            //         case (#err(#townNotFound)) Debug.trap("Town not found: " # Nat.toText(townId));
            //     };
            // };

            // Process each town's work
            for ((townId, townWork) in townWorkMap.entries()) {
                // Adjust wood harvesting
                let adjustedWoodHarvest = calculatePropotionValue(townWork.woodCanHarvest, woodProportion);
                location.resources.wood.amount -= adjustedWoodHarvest;
                addTownResource(townId, adjustedWoodHarvest, #wood);
                // addProficiencyExperience(townId, #wood, townWork.wood.workers);

                // Adjust food harvesting
                let adjustedFoodHarvest = calculatePropotionValue(townWork.foodCanHarvest, foodProportion);
                location.resources.food.amount -= adjustedFoodHarvest;
                addTownResource(townId, adjustedFoodHarvest, #food);
                // addProficiencyExperience(townId, #food, townWork.food.workers);

                // Stone difficulty increases regardless of proportion
                location.resources.stone.difficulty += townWork.stoneCanHarvest;
                addTownResource(townId, townWork.stoneCanHarvest, #stone);
                // addProficiencyExperience(townId, #stone, townWork.stone.workers);

                // Gold difficulty increases regardless of proportion
                location.resources.gold.difficulty += townWork.goldCanHarvest;
                addTownResource(townId, townWork.goldCanHarvest, #gold);
                // addProficiencyExperience(townId, #gold, townWork.gold.workers);
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

                let calculateAmountWithDifficulty = func(workerCount : Int, proficiencyLevel : Nat, techLevel : Nat, difficulty : Nat) : Nat {
                    let baseAmount = workerCount + proficiencyLevel + techLevel;
                    let difficultyScalingFactor = 0.001; // Adjust this value to change the steepness of the linear decrease

                    let scaledDifficulty = Float.fromInt(difficulty) * difficultyScalingFactor;
                    let amountFloat = Float.fromInt(baseAmount) - scaledDifficulty;

                    let amountInt = Float.toInt(amountFloat);
                    if (amountInt <= 1) {
                        1;
                    } else {
                        Int.abs(amountInt);
                    };
                };

                let amountCanHarvest : Nat = switch (gatherResourceJob.resource) {
                    case (#wood) gatherResourceJob.workerCount + town.skills.woodCutting.proficiencyLevel + town.skills.woodCutting.techLevel;
                    case (#food) gatherResourceJob.workerCount + town.skills.farming.proficiencyLevel + town.skills.farming.techLevel;
                    case (#gold) calculateAmountWithDifficulty(
                        gatherResourceJob.workerCount,
                        town.skills.mining.proficiencyLevel,
                        town.skills.mining.techLevel,
                        location.resources.gold.difficulty,
                    );
                    case (#stone) calculateAmountWithDifficulty(
                        gatherResourceJob.workerCount,
                        town.skills.mining.proficiencyLevel,
                        town.skills.mining.techLevel,
                        location.resources.stone.difficulty,
                    );
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

    // Intialization ---------------------------------------------------------
    resetDayTimer<system>(true);
};
