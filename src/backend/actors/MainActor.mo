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
import UserHandler "../handlers/UserHandler";
import BinaryProposalEngine "mo:dao-proposal-engine/BinaryProposalEngine";
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
import Flag "../models/Flag";
import World "../models/World";
import WorldGenerator "../WorldGenerator";
import WorldHandler "../handlers/WorldHandler";
import HexGrid "../models/HexGrid";
import TimeUtil "../TimeUtil";
import ScenarioHandler "../handlers/ScenarioHandler";

actor MainActor : Types.Actor {
    // Types  ---------------------------------------------------------
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    type Duration = {
        #days : Nat;
    };

    // Stables ---------------------------------------------------------

    stable var daysProcessed : Nat = 0;
    var dayTimerId : ?Timer.TimerId = null;

    stable var worldStableData : ?WorldHandler.StableData = null;

    stable var scenarioStableData : ScenarioHandler.StableData = {
        scenarios = [];
    };
    stable var worldDaoStableData : BinaryProposalEngine.StableData<WorldDao.ProposalContent> = {
        proposalDuration = ? #days(3);
        proposals = [];
        votingThreshold = #percent({
            percent = 50;
            quorum = ?20;
        });
    };

    stable var userStableData : UserHandler.StableData = {
        users = [];
    };

    // Unstables ---------------------------------------------------------

    var worldHandlerOrNull : ?WorldHandler.Handler = switch (worldStableData) {
        case (null) null;
        case (?worldStableData) ?WorldHandler.Handler(worldStableData);
    };

    var scenarioHandler = ScenarioHandler.Handler<system>(scenarioStableData);

    var userHandler = UserHandler.UserHandler(userStableData);

    func onWorldProposalExecute(proposal : BinaryProposalEngine.Proposal<WorldDao.ProposalContent>) : async* Result.Result<(), Text> {
        // TODO change world proposal for town data to be a simple approve w/ callback. Dont need to expose all the update routes
        switch (proposal.content) {
            case (#motion(_)) {
                // Do nothing
                #ok;
            };
        };
    };
    func onWorldProposalReject(_ : BinaryProposalEngine.Proposal<WorldDao.ProposalContent>) : async* () {}; // TODO
    func onWorldProposalValidate(_ : WorldDao.ProposalContent) : async* Result.Result<(), [Text]> {
        #ok; // TODO
    };
    var worldDao = BinaryProposalEngine.ProposalEngine<system, WorldDao.ProposalContent>(
        worldDaoStableData,
        onWorldProposalExecute,
        onWorldProposalReject,
        onWorldProposalValidate,
    );

    // System Methods ---------------------------------------------------------

    system func preupgrade() {
        scenarioStableData := scenarioHandler.toStableData();
        worldDaoStableData := worldDao.toStableData();
        userStableData := userHandler.toStableData();
        worldStableData := switch (worldHandlerOrNull) {
            case (null) null;
            case (?worldStableData) ?worldStableData.toStableData();
        };
    };

    system func postupgrade() {
        scenarioHandler := ScenarioHandler.Handler<system>(scenarioStableData);
        worldDao := BinaryProposalEngine.ProposalEngine<system, WorldDao.ProposalContent>(
            worldDaoStableData,
            onWorldProposalExecute,
            onWorldProposalReject,
            onWorldProposalValidate,
        );
        userHandler := UserHandler.UserHandler(userStableData);
        worldHandlerOrNull := switch (worldStableData) {
            case (null) null;
            case (?worldStableData) ?WorldHandler.Handler(worldStableData);
        };
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
            daoResources = {
                gold = 0;
                wood = 0;
                food = 0;
                stone = 0;
            };
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
        switch (userHandler.addWorldMember(caller)) {
            case (#ok) ();
            case (#err(#alreadyWorldMember)) Prelude.unreachable();
        };
        #ok;
    };

    public shared ({ caller }) func joinWorld(request : Types.JoinWorldRequest) : async Result.Result<(), Types.JoinWorldError> {
        // TODO restrict to NFT?/TOken holders
        userHandler.addWorldMember(caller, request.townId);
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
            func(user : UserHandler.User) : BinaryProposalEngine.Member = {
                id = user.id;
                votingPower = calculateVotingPower(user);
            },
        )
        |> Iter.toArray(_);

        let isAMember = members.vals()
        |> Iter.filter(
            _,
            func(member : ProposalEngine.Member) : Bool = member.id == caller,
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

    public query func getScenario(scenarioId : Nat) : async Types.GetScenarioResult {
        let ?scenario = scenarioHandler.get(scenarioId) else return #err(#notFound);
        #ok(scenario);
    };

    public query func getScenarios() : async Types.GetScenariosResult {
        let openScenarios = scenarioHandler.getScenarios(false);
        #ok(openScenarios);
    };

    public shared query ({ caller }) func getScenarioVote(request : Types.GetScenarioVoteRequest) : async Types.GetScenarioVoteResult {
        scenarioHandler.getVote(request.scenarioId, caller);
    };

    public shared ({ caller }) func voteOnScenario(request : Types.VoteOnScenarioRequest) : async Types.VoteOnScenarioResult {
        await* scenarioHandler.vote<system>(request.scenarioId, caller, request.value);
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
};
