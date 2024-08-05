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
import Int "mo:base/Int";
import Float "mo:base/Float";
import Option "mo:base/Option";
import Prelude "mo:base/Prelude";
import IterTools "mo:itertools/Iter";
import WorldDao "../models/WorldDao";
import TownDao "../models/TownDao";
import TownsHandler "../handlers/TownsHandler";
import Town "../models/Town";
import Flag "../models/Flag";
import World "../models/World";
import JobAllocator "../JobAllocator";
import WorldGenerator "../WorldGenerator";
import WorldHandler "../handlers/WorldHandler";
import HexGrid "../models/HexGrid";
import ColorUtil "../ColorUtil";

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

    private func processEffectOutcome<system>(
        effectOutcome : Scenario.EffectOutcome
    ) : () {
        let reverseEffectOrNull : ?ReverseEffectWithDuration = switch (effectOutcome) {
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

    // Initialize town daos here to be used in buildTownDao
    var townDaos = HashMap.HashMap<Nat, ProposalEngine.ProposalEngine<TownDao.ProposalContent>>(townDaoStableData.size(), Nat.equal, Nat32.fromNat);

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
                        case (#err(#townNotFound)) "Town not found: " # Nat.toText(townId);
                    };
                    #err("Failed to update name: " # error);
                };
                case (#changeFlag(c)) {
                    let result = townsHandler.updateFlag(townId, c.image);
                    let error = switch (result) {
                        case (#ok) return #ok;
                        case (#err(#townNotFound)) "Town not found: " # Nat.toText(townId);
                    };
                    #err("Failed to update flag: " # error);
                };
                case (#changeMotto(c)) {
                    let result = townsHandler.updateMotto(townId, c.motto);
                    let error = switch (result) {
                        case (#ok) return #ok;
                        case (#err(#townNotFound)) "Town not found: " # Nat.toText(townId);
                    };
                    #err("Failed to update motto: " # error);
                };
                case (#addJob(addJob)) {
                    let error = switch (townsHandler.addJob(townId, addJob.job)) {
                        case (#ok(_)) return #ok;
                        case (#err(#townNotFound)) "Town not found: " # Nat.toText(townId);
                        case (#err(#invalid(invalid))) "Invalid job: " # debug_show (invalid); // TODO format
                    };
                    #err("Failed to add job:" # error);
                };
                case (#updateJob(updateJob)) {
                    let error = switch (townsHandler.updateJob(townId, updateJob.jobId, updateJob.job)) {
                        case (#ok(_)) return #ok;
                        case (#err(#townNotFound)) "Town not found: " # Nat.toText(townId);
                        case (#err(#jobNotFound)) "Job not found: " # Nat.toText(updateJob.jobId);
                        case (#err(#invalid(invalid))) "Invalid job: " # debug_show (invalid); // TODO format
                    };
                    #err("Failed to update job:" # error);
                };
                case (#removeJob(removeJob)) {
                    let error = switch (townsHandler.removeJob(townId, removeJob.jobId)) {
                        case (#ok) return #ok;
                        case (#err(#townNotFound)) "Town not found: " # Nat.toText(townId);
                        case (#err(#jobNotFound)) "Job not found: " # Nat.toText(removeJob.jobId);
                    };
                    #err("Failed to remove job:" # error);
                };
                case (#foundTown(foundTown)) {
                    let prng = PseudoRandomX.fromBlob(await Random.blob(), #xorshift32);
                    let foundingResourceCosts = [
                        {
                            kind = #wood;
                            delta = -100; // TODO
                        },
                        {
                            kind = #stone;
                            delta = -100; // TODO
                        },
                        {
                            kind = #food;
                            delta = -100; // TODO
                        },
                    ];
                    let error : Text = switch (townsHandler.updateResourceBulk(townId, foundingResourceCosts, false)) {
                        case (#ok) {
                            let _ = createTown<system>(
                                prng,
                                foundTown.name,
                                foundTown.flag,
                                foundTown.motto,
                                {
                                    wood = 0;
                                    stone = 0;
                                    gold = 0;
                                    food = 100; // TODO
                                },
                                foundTown.locationId,
                                buildTownDao,
                            );
                            return #ok;
                        };
                        case (#err(#townNotFound)) "Town not found: " # Nat.toText(townId);
                        case (#err(#notEnoughResources(r))) "Not enough resources: " # debug_show (r);
                    };
                    #err("Failed to found town: " # error);
                };
                case (#updateWorkPlan(updateWorkPlan)) {
                    let error = switch (townsHandler.updateWorkPlan(townId, updateWorkPlan.workPlan)) {
                        case (#ok) return #ok;
                        case (#err(#townNotFound)) "Town not found: " # Nat.toText(townId);
                    };
                    #err("Failed to update work plan: " # error);
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

    private func createTown<system>(
        prng : Prng,
        name : Text,
        image : Flag.FlagImage,
        motto : Text,
        resources : Town.ResourceList,
        locationId : Nat,
        buildTownDao : <system>(Nat, ProposalTypes.StableData<TownDao.ProposalContent>) -> ProposalEngine.ProposalEngine<TownDao.ProposalContent>,
    ) : Nat {
        let ?worldHandler = worldHandlerOrNull else Debug.trap("Cannot create town if world is not initialized");

        let townId = townsHandler.create<system>(name, image, motto, resources);
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
        switch (worldHandler.addTown(prng, locationId, townId)) {
            case (#ok) ();
            case (#err(#locationNotFound)) Debug.trap("Location not found: " # Nat.toText(locationId));
            case (#err(#otherTownAtLocation(townId))) Debug.trap("Town '" #Nat.toText(townId) # "' already at location: " # Nat.toText(locationId));
        };
        Debug.print("Created town " # Nat.toText(townId) # " at location " # Nat.toText(locationId));
        townId;
    };

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

    public shared ({ caller }) func joinWorld() : async Result.Result<(), Types.JoinWorldError> {
        // TODO restrict to NFT?/TOken holders
        let seedBlob = await Random.blob();
        let prng = PseudoRandomX.fromBlob(seedBlob, #xorshift32);
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
        userHandler.addWorldMember(caller, randomTownId);
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

    private func buildNewWorld<system>(progenitor : Principal) : async* Nat {
        let seedBlob = await Random.blob();
        let prng = PseudoRandomX.fromBlob(seedBlob, #xorshift32);
        let newWorld : WorldHandler.StableData = {
            genesisTime = Time.now();
            progenitor = progenitor;
            locations = WorldGenerator.generateWorld(prng, 20);
        };
        let worldHandler = WorldHandler.Handler(newWorld);
        worldHandlerOrNull := ?worldHandler;

        // TODO better initialization
        let height : Nat = 12;
        let width : Nat = 16;

        let image = {
            pixels = Array.tabulate<[Flag.Pixel]>(
                height,
                func(j : Nat) : [Flag.Pixel] {
                    Array.tabulate<Flag.Pixel>(
                        width,
                        func(i : Nat) : Flag.Pixel {
                            let w : Float = Float.fromInt(i) / Float.fromInt(width);
                            let h : Float = Float.fromInt(j) / Float.fromInt(height);
                            // Create a checkered pattern
                            let checker = (i / 4 + j / 4) % 2 == 0;

                            // Base hue changes across the width
                            let hue : Float = w * 360.0;

                            // Saturation varies in a wave pattern
                            let sat : Float = 0.8 + 0.2 * Float.sin(w * 6.28318);

                            // Value is higher for checker squares and varies with height
                            let val : Float = if (checker) 0.8 - 0.6 * h else 0.5 - 0.3 * h;
                            let (r, g, b) = ColorUtil.hsvToRgb(hue, sat, val);
                            {
                                red = r;
                                green = g;
                                blue = b;
                            };
                        },
                    );
                },
            );
        };

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
            "First Town",
            image,
            "First Town Motto",
            resources,
            locationId,
            buildTownDao,
        );
        resetDayTimer<system>(false);
        townId;
    };

    private func processDays() : async* () {
        switch (worldHandlerOrNull) {
            case (null) (); // Skip if no world
            case (?worldHandler) {
                Debug.print("Processing days");
                let { daysElapsed } = worldHandler.getAgeInfo();
                label l loop {
                    if (daysElapsed <= daysProcessed) {
                        break l;
                    };
                    Debug.print("Processing day " # Nat.toText(daysProcessed));
                    processTownWork(worldHandler);
                    processTownTradeResources();
                    processTownConsumeResources();
                    processRegenResources(worldHandler);
                    processPopulationGrowth();
                    processTownChanges();
                    // TODO
                    // TODO reverse effects
                    daysProcessed := daysProcessed + 1;
                };
                Debug.print("All days processed");
            };
        };
        resetDayTimer<system>(false);
    };

    private func processTownChanges() {
        for (town in townsHandler.getAll().vals()) {
            // TODO
            let totalUserLevel : ?Nat = userHandler.getByTownId(town.id).vals()
            |> Iter.map<UserHandler.User, Nat>(
                _,
                func(user : UserHandler.User) : Nat = user.level,
            )
            |> IterTools.sum<Nat>(_, Nat.add);
            let newPopulationMax = Option.get(totalUserLevel, 0) * 10 + 100; // TODO
            switch (townsHandler.setPopulationMax(town.id, newPopulationMax)) {
                case (#ok) ();
                case (#err(#townNotFound)) Debug.trap("Town not found: " # Nat.toText(town.id));
            };
        };
    };

    private func processPopulationGrowth() {
        // TODO ability to pause growth or should excess food be required???
        Debug.print("Processing population growth");
        for (town in townsHandler.getAll().vals()) {
            if (town.health <= 0) {
                // Dying town
                let tenPercentPop : Nat = Nat.max(1, town.population / 10); // TODO 10%?
                Debug.print("Town " # Nat.toText(town.id) # "'s population is dying from lack of health. Death count: " # Nat.toText(tenPercentPop));
                switch (townsHandler.updatePopulation(town.id, -tenPercentPop)) {
                    case (#ok(newPopulation)) {
                        if (newPopulation == 0) {
                            // TODO
                            Debug.print("Town " # Nat.toText(town.id) # " has died out");
                        };
                    };
                    case (#err(#townNotFound)) Debug.trap("Town not found: " # Nat.toText(town.id));
                };
            } else if (town.health >= 100) {
                // TODO randomly trigger/random amounts
                // Growing town
                let onePercentPop : Nat = Nat.max(1, town.population / 100); // TODO 1%?
                Debug.print("Town " # Nat.toText(town.id) # "'s population  is growing. Growth count: " # Nat.toText(onePercentPop));
                switch (townsHandler.addPopulation(town.id, onePercentPop)) {
                    case (#ok(newPopulation)) {
                        if (newPopulation == town.populationMax) {
                            // TODO
                            Debug.print("Town " # Nat.toText(town.id) # " has reached max population of " # Nat.toText(town.populationMax));
                        };
                    };
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
        let regen = func(locationId : Nat, kind : { #wood; #food }, amount : Nat) {
            let regenAmount = calculateRegeneration(amount);
            if (regenAmount > 0) {
                switch (worldHandler.updateDeterminateResource(locationId, regenAmount, #ignoreNegative)) {
                    case (#ok(_)) ();
                    case (#err(#locationNotFound)) Debug.trap("Location not found: " # Nat.toText(locationId));
                    case (#err(#notEnoughResource(_))) Prelude.unreachable();
                };
                Debug.print(debug_show (kind) # " regeneration amount for location " # Nat.toText(locationId) # ": " # Nat.toText(regenAmount));
            };
        };

        label f for ((locationId, location) in IterTools.enumerate(worldHandler.getLocations().vals())) {
            switch (location.kind) {
                case (#unexplored(_) or #town(_) or #gold(_) or #stone(_)) continue f;
                case (#wood(woodLocation)) regen(locationId, #wood, woodLocation.amount);
                case (#food(foodLocation)) regen(locationId, #food, foodLocation.amount);
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
            // Slow regeneration below depletion threshold
            if (currentAmountFloat <= 0.0) {
                0; // Base regeneration when completely depleted
            } else {
                regenRate * Float.min(optimalResourceLevel / currentAmountFloat, 2.0) * currentAmountFloat;
            };
        };
        if (amountFloat <= 0) {
            0;
        } else {
            Int.abs(Float.toInt(amountFloat));
        };
    };

    private func processTownWork(
        worldHandler : WorldHandler.Handler
    ) {
        Debug.print("Processing town work");
        let locations = worldHandler.getLocations();

        let townLocationMap = locations.vals()
        |> IterTools.mapFilter(
            _,
            func(location : World.WorldLocation) : ?(Nat, World.WorldLocation) {
                let #town(townLocation) = location.kind else return null;
                ?(townLocation.townId, location);
            },
        )
        |> HashMap.fromIter<Nat, World.WorldLocation>(_, locations.size(), Nat.equal, Nat32.fromNat);

        for (town in townsHandler.getAll().vals()) {
            let ?townLocation = townLocationMap.get(town.id) else Debug.trap("Town location not found: " # Nat.toText(town.id));
            let accessableLocations = locations.vals()
            |> Iter.filter(
                _,
                func(location : World.WorldLocation) : Bool {
                    let distance = HexGrid.distanceBetween(location.coordinate, townLocation.coordinate);
                    distance <= 2 and distance != 0; // TODO
                },
            )
            |> Iter.toArray(_);
            let townAllocation = JobAllocator.allocateWorkInTown(town);
            let locationAllocations = JobAllocator.allocateWorkToResourceLocations(townAllocation, accessableLocations);
            let gatherWork = processLocationResourceWork(worldHandler, town.id, locationAllocations);

            // TODO process process resource

            let snapshot : TownsHandler.DaySnapshot = {
                day = worldHandler.getAgeInfo().daysElapsed;
                work = {
                    gatherWork with
                    processWood = { workers = 0; units = 0 };
                    processStone = { workers = 0; units = 0 };
                };
            };
            switch (townsHandler.addDaySnapshot(town.id, snapshot)) {
                case (#ok) ();
                case (#err(#townNotFound)) Debug.trap("Town not found: " # Nat.toText(town.id));
            };
        };
    };

    // private func processExploreJob(
    //     prng : Prng,
    //     worldHandler : WorldHandler.Handler,
    //     townsHandler : TownsHandler.Handler,
    //     job : Town.ExploreJob,
    //     jobId : Nat,
    //     townId : Nat,
    //     amount : Nat,
    // ) {
    //     Debug.print("Processing explore job " # Nat.toText(jobId) # " for town " # Nat.toText(townId) # " at location " # Nat.toText(job.locationId) # " with amount " # Nat.toText(amount));
    //     // TODO
    //     let complete = switch (worldHandler.exploreLocation(prng, job.locationId, amount)) {
    //         case (#ok(state)) state == #complete;
    //         case (#err(#locationAlreadyExplored)) true;
    //         case (#err(#locationNotFound)) Debug.trap("Location not found: " # Nat.toText(job.locationId));
    //     };
    //     Debug.print("Explore job " # Nat.toText(jobId) # " for town " # Nat.toText(townId) # " at location " # Nat.toText(job.locationId) # " is complete: " # Bool.toText(complete));
    //     if (complete) {
    //         // Cancel job if complete
    //         switch (townsHandler.removeJob(townId, jobId)) {
    //             case (#ok) {};
    //             case (#err(#townNotFound)) Debug.trap("Town not found: " # Nat.toText(townId));
    //             case (#err(#jobNotFound)) Debug.trap("Job not found: " # Nat.toText(jobId));
    //         };
    //     };
    // };

    private func processLocationResourceWork(
        worldHandler : WorldHandler.Handler,
        townId : Nat,
        resourceLocations : [JobAllocator.ResourceLocationWorkAllocation],
    ) : TownsHandler.DaySnapshotGatherWork {
        let work = {
            gatherWood = {
                var workers = 0;
                var units = 0;
            };
            gatherFood = {
                var workers = 0;
                var units = 0;
            };
            gatherGold = {
                var workers = 0;
                var units = 0;
            };
            gatherStone = {
                var workers = 0;
                var units = 0;
            };
        };

        let addTownResource = func(townId : Nat, amount : Nat, resource : World.ResourceKind) {
            switch (townsHandler.addResource(townId, resource, amount)) {
                case (#ok) {};
                case (#err(#townNotFound)) Debug.trap("Town not found: " # Nat.toText(townId));
            };
        };

        let addProficiencyExperience = func(townId : Nat, resource : World.ResourceKind, value : Nat) {
            let skill : Town.SkillKind = switch (resource) {
                case (#wood) #woodCutting;
                case (#food) #farming;
                case (#gold) #mining;
                case (#stone) #mining;
            };

            switch (townsHandler.updateProficiency(townId, skill, value)) {
                case (#ok(_)) ();
                case (#err(#townNotFound)) Debug.trap("Town not found: " # Nat.toText(townId));
            };
        };

        let updateDeterminateResource = func(
            locationId : Nat,
            amount : Nat,
        ) : Nat {
            let result = worldHandler.updateDeterminateResource(
                locationId,
                -amount,
                #errorOnNegative({ setToZero = true }),
            );
            switch (result) {
                case (#ok(_)) amount;
                case (#err(#locationNotFound)) Debug.trap("Location not found: " # Nat.toText(locationId));
                case (#err(#notEnoughResource(r))) amount - r.missing; // TODO handle this better vs first come first serve
            };
        };

        let updateEfficiencyResource = func(
            locationId : Nat,
            amount : Nat,
        ) : Nat {
            switch (worldHandler.updateEfficiencyResource(locationId, amount)) {
                case (#ok(_)) amount;
                case (#err(#locationNotFound)) Debug.trap("Location not found: " # Nat.toText(locationId));
            };
        };

        for (loc in resourceLocations.vals()) {
            let (kind, trueAmount) : (World.ResourceKind, Nat) = switch (loc.kind) {
                case (#wood(_)) (#wood, updateDeterminateResource(loc.locationId, loc.workers));
                case (#food(_)) (#food, updateDeterminateResource(loc.locationId, loc.workers));
                case (#gold(_)) (#gold, updateEfficiencyResource(loc.locationId, loc.workers));
                case (#stone(_)) (#stone, updateEfficiencyResource(loc.locationId, loc.workers));
            };

            switch (kind) {
                case (#wood) {
                    work.gatherWood.workers += loc.workers;
                    work.gatherWood.units += trueAmount;
                };
                case (#food) {
                    work.gatherFood.workers += loc.workers;
                    work.gatherFood.units += trueAmount;
                };
                case (#gold) {
                    work.gatherGold.workers += loc.workers;
                    work.gatherGold.units += trueAmount;
                };
                case (#stone) {
                    work.gatherStone.workers += loc.workers;
                    work.gatherStone.units += trueAmount;
                };
            };

            addTownResource(townId, trueAmount, kind);
            addProficiencyExperience(townId, kind, trueAmount);
        };

        let mapWork = func(w : { var workers : Nat; var units : Nat }) : TownsHandler.Work = {
            workers = w.workers;
            units = w.units;
        };
        {
            gatherWood = mapWork(work.gatherWood);
            gatherFood = mapWork(work.gatherFood);
            gatherGold = mapWork(work.gatherGold);
            gatherStone = mapWork(work.gatherStone);
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
