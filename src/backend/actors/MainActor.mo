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
import Error "mo:base/Error";
import IterTools "mo:itertools/Iter";
import WorldDao "../models/WorldDao";
import TownDao "../models/TownDao";
import TownsHandler "../handlers/TownsHandler";
import Town "../models/Town";
import Flag "../models/Flag";
import TimeUtil "../TimeUtil";
import World "../models/World";
import JobCoordinator "../JobCoordinator";
import WorldGenerator "../WorldGenerator";
import WorldHandler "../handlers/WorldHandler";

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

    stable let genesisTime : Time.Time = Time.now();
    stable var daysProcessed : Nat = 0;
    var dayTimerId : ?Timer.TimerId = null;

    stable var reverseEffectStableData : [ReverseEffectWithDuration] = [];

    stable var worldStableData : ?WorldHandler.StableData = null;

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

    var worldHandlerOrNull : ?WorldHandler.Handler = switch (worldStableData) {
        case (null) null;
        case (?worldStableData) ?WorldHandler.Handler(worldStableData);
    };

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
                        case (#err(#invalid(invalid))) "Invalid job: " # debug_show (invalid); // TODO format
                    };
                    #err("Failed to add job:" # error);
                };
                case (#updateJob(updateJob)) {
                    let error = switch (townsHandler.updateJob(townId, updateJob.jobId, updateJob.job)) {
                        case (#ok(_)) return #ok;
                        case (#err(#townNotFound)) "Town not found";
                        case (#err(#jobNotFound)) "Job not found";
                        case (#err(#invalid(invalid))) "Invalid job: " # debug_show (invalid); // TODO format
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
                case (#increaseSize(_)) {
                    let ?town = townsHandler.get(townId) else Debug.trap("Town not found: " # Nat.toText(townId));
                    let sizeIncreaseCost = 1000 * (town.size + 1); // TODO
                    let resourceUpdates = [{ delta = -sizeIncreaseCost; kind = #wood }, { delta = -sizeIncreaseCost; kind = #stone }];
                    let error = switch (townsHandler.updateResourceBulk(townId, resourceUpdates, false)) {
                        case (#ok) switch (townsHandler.updateSize(townId, 1)) {
                            case (#ok(_)) return #ok;
                            case (#err(#townNotFound)) "Town not found";
                        };
                        case (#err(#notEnoughResources(_))) {
                            "Need " # Nat.toText(sizeIncreaseCost) # " wood and stone to increase size";
                        };
                        case (#err(#townNotFound)) Debug.trap("Town not found: " # Nat.toText(townId));
                    };
                    #err("Failed to increase size:" # error);
                };
                case (#startExpedition(startExpedition)) {
                    // TODO chance of failure/reward

                    let error = switch (worldHandlerOrNull) {
                        case (null) "World not initialized";
                        case (?worldHandler) {
                            let prng = try {
                                PseudoRandomX.fromBlob(await Random.blob()); // TODO need to make transaction?
                            } catch (e) {
                                return #err("Failed to create PRNG: " # Error.message(e));
                            };
                            switch (worldHandler.exploreLocation(prng, startExpedition.locationId)) {
                                case (#ok(_)) return #ok;
                                case (#err(#locationAlreadyExplored)) "Location already explored";
                                case (#err(#noAdjacentLocationExplored)) "No adjacent location explored";
                            };
                        };
                    };
                    #err("Failed to start expedition:" # error);
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
        worldStableData := switch (worldHandlerOrNull) {
            case (null) null;
            case (?worldStableData) ?worldStableData.toStableData();
        };
        townDaoStableData := townDaos.entries()
        |> Iter.map<(Nat, ProposalEngine.ProposalEngine<TownDao.ProposalContent>), (Nat, ProposalTypes.StableData<TownDao.ProposalContent>)>(
            _,
            func((id, d) : (Nat, ProposalEngine.ProposalEngine<TownDao.ProposalContent>)) : (Nat, ProposalTypes.StableData<TownDao.ProposalContent>) = (id, d.toStableData()),
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
        worldHandlerOrNull := switch (worldStableData) {
            case (null) null;
            case (?worldStableData) ?WorldHandler.Handler(worldStableData);
        };
        townDaos := buildTownDaos<system>();
        resetDayTimer<system>(true); // TODO is this sufficient if there is any weird down time?
    };

    // Public Methods ---------------------------------------------------------

    public shared ({ caller }) func joinWorld() : async Result.Result<(), Types.JoinWorldError> {
        // TODO restrict to NFT?/TOken holders
        let seedBlob = await Random.blob();
        let prng = PseudoRandomX.fromBlob(seedBlob);
        let towns = townsHandler.getAll();
        let randomTownId : Nat = switch (worldHandlerOrNull) {
            case (null) {
                let firstTownId = await* buildNewWorld(caller);
                firstTownId;
            };
            case (?_) {
                // Get random existing town
                towns.vals()
                |> Iter.map<Town.Town, Nat>(
                    _,
                    func(town : Town.Town) : Nat = town.id,
                )
                |> Iter.toArray(_)
                |> prng.nextArrayElement(_);
            };
        };
        let votingPower = 1; // TODO get voting power from token
        userHandler.addWorldMember(caller, randomTownId, votingPower);
    };

    public query func getProgenitor() : async ?Principal {
        let ?worldHandler = worldHandlerOrNull else return null; // Skip if no world
        ?worldHandler.progenitor;
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
        if (not isWorldOrProgenitor(caller)) {
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
        let ?worldHandler = worldHandlerOrNull else return #err(#worldNotInitialized);
        let worldLocations = worldHandler.getLocations();
        let { days; nextDayStartTime } = TimeUtil.getAge(genesisTime);
        #ok({
            progenitor = worldHandler.progenitor;
            age = days;
            nextDayStartTime = nextDayStartTime;
            locations = worldLocations.vals() |> Iter.toArray(_);
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
        if (not isWorldOrProgenitor(caller)) {
            return #err(#notAuthorized);
        };
        let ?_ = townsHandler.get(request.townId) else return #err(#townNotFound);
        userHandler.changeTown(request.userId, request.townId);
    };

    // Private Methods ---------------------------------------------------------

    private func buildNewWorld(progenitor : Principal) : async* Nat {
        let seedBlob = await Random.blob();
        let prng = PseudoRandomX.fromBlob(seedBlob);
        let newWorld : WorldHandler.StableData = {
            progenitor = progenitor;
            locations = WorldGenerator.generateWorld(prng);
        };
        let worldHandler = WorldHandler.Handler(newWorld);
        worldHandlerOrNull := ?worldHandler;

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
            gold = 0;
            wood = 0;
            food = 1000;
            stone = 0;
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
        let locationId = 0; // Start in middle
        switch (worldHandler.addTown(locationId, townId)) {
            case (#ok) ();
            case (#err(#locationNotFound)) Debug.trap("Location not found: " # Nat.toText(locationId));
            case (#err(#otherTownAtLocation(townId))) Debug.trap("Town '" #Nat.toText(townId) # "' already at location: " # Nat.toText(locationId));
        };
        townId;
    };

    private func processDays() : async* () {
        let ?worldHandler = worldHandlerOrNull else return; // Skip if no world
        Debug.print("Processing days");
        let { days } = TimeUtil.getAge(genesisTime);
        label l loop {
            if (days <= daysProcessed) {
                break l;
            };
            Debug.print("Processing day " # Nat.toText(daysProcessed));
            processResourceGathering(worldHandler);
            processTownTradeResources();
            processTownConsumeResources();
            processRegenResources(worldHandler);
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
            } else if (town.health >= 100) {
                // TODO randomly trigger/random amounts
                // Growing town
                let onePercentPop : Nat = Nat.max(1, town.population / 100); // TODO 1%?
                Debug.print("Town's population " # Nat.toText(town.id) # " is growing. Growth count: " # Nat.toText(onePercentPop));
                switch (townsHandler.addPopulation(town.id, onePercentPop)) {
                    case (#ok) ();
                    case (#err(#townNotFound)) Debug.trap("Town not found: " # Nat.toText(town.id));
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

    private func processRegenResources(worldHandler : WorldHandler.Handler) {
        for ((locationId, location) in IterTools.enumerate(worldHandler.getLocations().vals())) {
            let foodRegenAmount = calculateRegeneration(location.resources.food.amount);
            if (foodRegenAmount > 0) {
                switch (worldHandler.addResource(locationId, #food, foodRegenAmount)) {
                    case (#ok(_)) ();
                    case (#err(#locationNotFound)) Debug.trap("Location not found: " # Nat.toText(locationId));
                };
                Debug.print("Food regeneration amount for location " # Nat.toText(locationId) # ": " # Nat.toText(foodRegenAmount));
            };

            let woodRegenAmount = calculateRegeneration(location.resources.wood.amount);
            if (woodRegenAmount > 0) {
                switch (worldHandler.addResource(locationId, #wood, woodRegenAmount)) {
                    case (#ok(_)) ();
                    case (#err(#locationNotFound)) Debug.trap("Location not found: " # Nat.toText(locationId));
                };
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

    private func processResourceGathering((worldHandler : WorldHandler.Handler)) {
        Debug.print("Processing resource gathering");
        let locations = worldHandler.getLocations();
        let locationJobsMap = JobCoordinator.buildLocationJobs(townsHandler.getAll(), locations);
        for ((locationId, townWorkMap) in locationJobsMap.entries()) {
            let addTownResource = func(townId : Nat, amount : Nat, resource : World.ResourceKind) {
                switch (townsHandler.addResource(townId, resource, amount)) {
                    case (#ok) {};
                    case (#err(#townNotFound)) Debug.trap("Town not found: " # Nat.toText(townId));
                };
            };
            let removeLocationResource = func(resource : World.ResourceKind, amount : Nat) {
                switch (worldHandler.updateResource(locationId, resource, -amount, false)) {
                    case (#ok(_)) ();
                    case (#err(#locationNotFound)) Debug.trap("Location not found: " # Nat.toText(locationId));
                    case (#err(#notEnoughResource(r))) Debug.trap("Not enough resource in location. Failed to properly calculate amount: " # debug_show (r));
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
                removeLocationResource(#wood, townWork.woodCanHarvest);
                addTownResource(townId, townWork.woodCanHarvest, #wood);
                // addProficiencyExperience(townId, #wood, townWork.wood.workers);

                // Adjust food harvesting
                removeLocationResource(#food, townWork.foodCanHarvest);
                addTownResource(townId, townWork.foodCanHarvest, #food);
                // addProficiencyExperience(townId, #food, townWork.food.workers);

                // Stone difficulty increases regardless of proportion
                removeLocationResource(#stone, townWork.stoneCanHarvest);
                removeLocationResource(#wood, townWork.woodCanHarvest);

                addTownResource(townId, townWork.stoneCanHarvest, #stone);
                // addProficiencyExperience(townId, #stone, townWork.stone.workers);

                // Gold difficulty increases regardless of proportion
                removeLocationResource(#gold, townWork.goldCanHarvest);
                addTownResource(townId, townWork.goldCanHarvest, #gold);
                // addProficiencyExperience(townId, #gold, townWork.gold.workers);
            };
        };
    };

    private func isWorldOrProgenitor(id : Principal) : Bool {
        if (id == Principal.fromActor(MainActor)) {
            // World is admin
            return true;
        };
        switch (worldHandlerOrNull) {
            case (null) false;
            case (?worldHandler) worldHandler.progenitor == id;
        };
    };

    // Intialization ---------------------------------------------------------
    resetDayTimer<system>(true);
};
