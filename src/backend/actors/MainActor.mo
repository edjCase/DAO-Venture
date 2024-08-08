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
import Time "mo:base/Time";
import Timer "mo:base/Timer";
import Int "mo:base/Int";
import Float "mo:base/Float";
import Option "mo:base/Option";
import Prelude "mo:base/Prelude";
import IterTools "mo:itertools/Iter";
import WorldDao "../models/WorldDao";
import TownsHandler "../handlers/TownsHandler";
import Town "../models/Town";
import Flag "../models/Flag";
import World "../models/World";
import WorldGenerator "../WorldGenerator";
import WorldHandler "../handlers/WorldHandler";
import HexGrid "../models/HexGrid";
import TimeUtil "../TimeUtil";

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

    private func chargeResources(resoureCosts : [Scenario.ResourceCost]) : Result.Result<(), { #notEnoughResources : [{ defecit : Nat; kind : World.ResourceKind }] }> {
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

    var scenarioHandler = ScenarioHandler.Handler<system>(scenarioStableData, processEffectOutcome, chargeResources);

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

    private func populateTownDaosFromStable<system>() {
        for ((townId, data) in townDaoStableData.vals()) {
            let townDao = buildTownDao<system>(townId, data);
            townDaos.put(townId, townDao);
        };
    };

    // Populate town daos from stable data
    populateTownDaosFromStable<system>();

    private func resetDayTimer<system>(runImmediately : Bool) {
        let ?worldHandler = worldHandlerOrNull else return; // Skip if no world
        let timeTillNextDay : Nat = if (runImmediately) {
            0;
        } else {
            let { nextDayStartTime } = worldHandler.getAgeInfo();
            // TODO better way to handle getting Nat value?
            nextDayStartTime - Int.abs(Time.now());
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
        townDaos := HashMap.HashMap<Nat, ProposalEngine.ProposalEngine<TownDao.ProposalContent>>(townDaoStableData.size(), Nat.equal, Nat32.fromNat);
        populateTownDaosFromStable<system>();
        resetDayTimer<system>(true); // TODO is this sufficient if there is any weird down time?
    };

    // Public Methods ---------------------------------------------------------

    public shared ({ caller }) func intializeWorld(
        request : Types.InitializeWorldRequest
    ) : async Result.Result<(), Types.InitializeWorldError> {
        let null = worldHandlerOrNull else return #err(#alreadyInitialized);

        let seedBlob = await Random.blob();
        let prng = PseudoRandomX.fromBlob(seedBlob, #xorshift32);

        let worldRadius = 20;
        let newWorld : WorldHandler.StableData = {
            genesisTime = Time.now();
            progenitor = caller;
            locations = WorldGenerator.generateWorld(prng, worldRadius);
        };
        let worldHandler = WorldHandler.Handler(newWorld);
        worldHandlerOrNull := ?worldHandler;

        // TODO dont randomize on edge of world, better procedural generation
        let locationId = prng.nextNat(0, worldHandler.getLocations().size()); // TODO
        let resources = {
            gold = 0;
            wood = 0;
            food = 1000;
            stone = 0;
        };
        let townId = createTown<system>(
            prng,
            request.town.name,
            request.town.flag,
            request.town.color,
            request.town.motto,
            resources,
            locationId,
            buildTownDao,
        );
        switch (userHandler.addWorldMember(caller, townId)) {
            case (#ok) ();
            case (#err(#alreadyWorldMember)) Prelude.unreachable();
        };
        resetDayTimer<system>(true);
        #ok;
    };

    public shared ({ caller }) func joinWorld(request : Types.JoinWorldRequest) : async Result.Result<(), Types.JoinWorldError> {
        // TODO restrict to NFT?/TOken holders
        userHandler.addWorldMember(caller, request.townId);
    };

    public func resetTimer() : async () {
        resetDayTimer<system>(true);
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
        let members = userHandler.getAll().vals()
        |> Iter.map(
            _,
            func(user : UserHandler.User) : ProposalTypes.Member = {
                id = user.id;
                votingPower = calculateVotingPower(user);
            },
        )
        |> Iter.toArray(_);

        let isAMember = members.vals()
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
        let members = buildVotingMembers(?townId);
        let isAMember = members.vals()
        |> IterTools.any(
            _,
            func(member : ProposalTypes.Member) : Bool = member.id == caller,
        );
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
        let members = buildVotingMembers(null);
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
        let { daysElapsed; nextDayStartTime } = worldHandler.getAgeInfo();
        #ok({
            progenitor = worldHandler.progenitor;
            daysElapsed = daysElapsed;
            nextDayStartTime = nextDayStartTime;
            locations = worldLocations.vals() |> Iter.toArray(_);
        });
    };

    public shared query func getTowns() : async [Town.Town] {
        townsHandler.getAll();
    };

    public shared query func getTownHistory(townId : Nat, count : Nat, offset : Nat) : async Types.GetTownHistoryResult {
        townsHandler.getHistory(townId, count, offset);
    };

    public shared query func getUser(userId : Principal) : async Types.GetUserResult {
        let ?user = userHandler.get(userId) else return #err(#notFound);
        #ok(user);
    };

    public shared query func getUsers(request : Types.GetUsersRequest) : async Types.GetUsersResult {
        let users = switch (request) {
            case (#all) userHandler.getAll();
            case (#town(townId)) userHandler.getByTownId(townId);
        };
        #ok(users);
    };

    public shared query func getUserStats() : async Types.GetUserStatsResult {
        let stats = userHandler.getStats();
        #ok(stats);
    };

    public shared query func getTopUsers(request : Types.GetTopUsersRequest) : async Types.GetTopUsersResult {
        let result = userHandler.getTopUsers(request.count, request.offset);
        #ok(result);
    };

    public shared ({ caller }) func assignUserToTown(request : Types.AssignUserToTownRequest) : async Result.Result<(), Types.AssignUserToTownError> {
        if (not isWorldOrProgenitor(caller)) {
            return #err(#notAuthorized);
        };
        let ?_ = townsHandler.get(request.townId) else return #err(#townNotFound);
        userHandler.changeTown(request.userId, request.townId);
    };

    type VotingMemberInfo = {
        id : Principal;
        townId : Nat;
        votingPower : Nat;
    };

    // Private Methods ---------------------------------------------------------
    private func buildVotingMembers(townId : ?Nat) : [VotingMemberInfo] {
        let users = switch (townId) {
            case (?id) userHandler.getByTownId(id);
            case (null) userHandler.getAll();
        };
        users.vals()
        |> Iter.map<UserHandler.User, VotingMemberInfo>(
            _,
            func(user : UserHandler.User) : VotingMemberInfo = {
                id = user.id;
                townId = user.townId;
                votingPower = calculateVotingPower(user);
            },
        )
        |> Iter.toArray(_);
    };

    private func calculateVotingPower(user : UserHandler.User) : Nat {
        let basePower : Nat = 10;
        let levelMultiplier : Nat = 5;
        let timeMultiplier : Nat = 2;
        let maxTimePower : Nat = 100;
        let timeCap : Nat = 30 * 24 * 60 * 60 * 1_000_000_000; // 30 days in nanoseconds

        // Power from level
        let powerFromLevel : Nat = user.level * levelMultiplier;

        let timeAtTown : Nat = Int.abs(Time.now() - user.atTownSince);

        // Power from time in town
        let townTime : Nat = Nat.min(timeAtTown, timeCap);
        let townTimePower : Nat = Int.abs(
            Float.toInt(
                Float.log(Float.fromInt(townTime + 1)) / Float.log(Float.fromInt(timeCap)) * Float.fromInt(maxTimePower)
            )
        );

        let timeInWorld : Nat = Int.abs(Time.now() - user.inWorldSince);

        // Power from time in world
        let worldTime : Nat = Nat.min(timeInWorld, timeCap);
        let worldTimePower : Nat = Int.abs(
            Float.toInt(
                Float.log(Float.fromInt(worldTime + 1)) / Float.log(Float.fromInt(timeCap)) * Float.fromInt(maxTimePower)
            )
        );

        // Combine powers
        basePower + powerFromLevel + (townTimePower + worldTimePower) * timeMultiplier;
    };

    private func processDays() : async* () {
        switch (worldHandlerOrNull) {
            case (null) (); // Skip if no world
            case (?worldHandler) {
                Debug.print("Processing days");
                let { daysElapsed } = worldHandler.getAgeInfo();
                if (daysElapsed <= daysProcessed) {
                    Debug.print("No days to process");
                    return;
                };
                let prng = PseudoRandomX.fromBlob(await Random.blob(), #xorshift32);
                label l loop {
                    if (daysElapsed <= daysProcessed) {
                        break l;
                    };
                    Debug.print("Processing day " # Nat.toText(daysProcessed));
                    processTownWork(worldHandler);
                    processTownJobs(prng, worldHandler);
                    processTownTradeResources();
                    processTownConsumeResources();
                    processUpdateTownSizeLimit();
                    // TODO reduce size if town is 'unhealthy'?
                    // TODO
                    // TODO reverse effects
                    daysProcessed := daysProcessed + 1;
                };
                Debug.print("All days processed");
            };
        };
        resetDayTimer<system>(false);
    };

    private func processUpdateTownSizeLimit() {
        for (town in townsHandler.getAll().vals()) {
            let totalUserLevel : Nat = userHandler.getByTownId(town.id).vals()
            |> Iter.map(
                _,
                func(user : UserHandler.User) : Nat = user.level,
            )
            |> IterTools.sum(_, func(a : Nat, b : Nat) : Nat = a + b)
            |> Option.get(_, 0); // TODO

            // Age bonus that slows over time
            let daysSinceGenesis = TimeUtil.getAge(town.genesisTime).daysElapsed;
            let baseBonus = 2.0; // Adjust this value to control the overall bonus scale
            let scaleFactor = 5.0; // Adjust this to control how quickly the bonus growth slows down

            let ageBonus : Nat = Int.abs(Float.toInt(baseBonus * Float.log(1.0 + Float.fromInt(daysSinceGenesis) / scaleFactor)));

            let newSizeLimit : Nat = 6 + totalUserLevel + ageBonus;
            switch (townsHandler.setSizeLimit(town.id, newSizeLimit)) {
                case (#ok) ();
                case (#err(#townNotFound)) Debug.trap("Town not found: " # Nat.toText(town.id));
                case (#err(#cantBeZero)) Debug.trap("Size limit cannot be zero");
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
            let foodConsumption = town.size * 10; // TODO
            switch (townsHandler.updateResource(town.id, #food, -foodConsumption, false)) {
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

    private func processTownWork(
        worldHandler : WorldHandler.Handler
    ) {
        Debug.print("Processing town work");
        let locations = worldHandler.getLocations();

        for (town in townsHandler.getAll().vals()) {
            let townResourceLocations = locations.vals()
            |> IterTools.mapFilter(
                _,
                func(location : World.WorldLocation) : ?World.ResourceLocation {
                    let #resource(resource) = location.kind else return null;
                    ?resource;
                },
            );

            for (resourceLocation in townResourceLocations) {
                // TODO rarity values
                let amount = switch (resourceLocation.rarity) {
                    case (#common) 10;
                    case (#uncommon) 12;
                    case (#rare) 15;
                };
                switch (townsHandler.addResource(town.id, resourceLocation.kind, amount)) {
                    case (#ok) ();
                    case (#err(#townNotFound)) Debug.trap("Town not found: " # Nat.toText(town.id));
                };
            };

        };
    };

    private func processTownJobs(prng : Prng, worldHandler : WorldHandler.Handler) {
        Debug.print("Processing town jobs");
        for (town in townsHandler.getAll().vals()) {
            for ((jobId, job) in IterTools.enumerate(town.jobs.vals())) {
                switch (job) {
                    case (#explore(exploreJob)) {
                        processExploreJob(
                            prng,
                            worldHandler,
                            exploreJob,
                            jobId,
                            town.id,
                        );
                    };
                };
            };
        };
    };

    private func processExploreJob(
        prng : Prng,
        worldHandler : WorldHandler.Handler,
        job : Town.ExploreJob,
        jobId : Nat,
        townId : Nat,
    ) {
        let amount = 10; // TODO
        Debug.print("Processing explore job " # Nat.toText(jobId) # " for town " # Nat.toText(townId) # " at location " # Nat.toText(job.locationId) # " with amount " # Nat.toText(amount));

        let complete = switch (worldHandler.exploreLocation(prng, job.locationId, amount)) {
            case (#ok(state)) state == #complete;
            case (#err(#locationAlreadyExplored)) true;
            case (#err(#locationNotFound)) Debug.trap("Location not found: " # Nat.toText(job.locationId));
        };
        Debug.print("Explore job " # Nat.toText(jobId) # " for town " # Nat.toText(townId) # " at location " # Nat.toText(job.locationId) # " is complete: " # Bool.toText(complete));
        if (complete) {
            // Cancel job if complete
            switch (townsHandler.removeJob(townId, jobId)) {
                case (#ok) {};
                case (#err(#townNotFound)) Debug.trap("Town not found: " # Nat.toText(townId));
                case (#err(#jobNotFound)) Debug.trap("Job not found: " # Nat.toText(jobId));
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
