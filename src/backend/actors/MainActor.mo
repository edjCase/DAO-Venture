import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Random "mo:base/Random";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Bool "mo:base/Bool";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Types "MainActorTypes";
import UserHandler "../handlers/UserHandler";
import BinaryProposalEngine "mo:dao-proposal-engine/BinaryProposalEngine";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Float "mo:base/Float";
import Prelude "mo:base/Prelude";
import WorldDao "../models/WorldDao";
import WorldGenerator "../WorldGenerator";
import WorldHandler "../handlers/WorldHandler";
import ScenarioHandler "../handlers/ScenarioHandler";
import CommonTypes "../CommonTypes";

actor MainActor : Types.Actor {
    // Types  ---------------------------------------------------------
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    type Duration = {
        #days : Nat;
    };

    // Stables ---------------------------------------------------------

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

    public shared ({ caller }) func intializeWorld() : async Result.Result<(), Types.InitializeWorldError> {
        let null = worldHandlerOrNull else return #err(#alreadyInitialized);

        let seedBlob = await Random.blob();
        let prng = PseudoRandomX.fromBlob(seedBlob, #xorshift32);

        let worldRadius = 20;
        let newWorld : WorldHandler.StableData = {
            turn = 0;
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

        switch (userHandler.addWorldMember(caller)) {
            case (#ok) ();
            case (#err(#alreadyWorldMember)) Prelude.unreachable();
        };
        #ok;
    };

    public shared ({ caller }) func joinWorld() : async Result.Result<(), Types.JoinWorldError> {
        // TODO restrict to NFT?/TOken holders
        userHandler.addWorldMember(caller);
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

    public shared query func getWorldProposals(count : Nat, offset : Nat) : async CommonTypes.PagedResult<Types.WorldProposal> {
        worldDao.getProposals(count, offset);
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
            func(member : BinaryProposalEngine.Member) : Bool = member.id == caller,
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

    public query func getAllScenarios(request : Types.GetAllScenariosRequest) : async Types.GetAllScenariosResult {
        scenarioHandler.getAll(request.count, request.offset);
    };

    public shared query ({ caller }) func getScenarioVote(request : Types.GetScenarioVoteRequest) : async Types.GetScenarioVoteResult {
        let vote = switch (scenarioHandler.getVote(request.scenarioId, caller)) {
            case (#ok(vote)) ?vote;
            case (#err(#notEligible)) null;
            case (#err(#scenarioNotFound)) return #err(#scenarioNotFound);
        };
        let { totalVotingPower; undecidedVotingPower; votingPowerByChoice } = switch (scenarioHandler.getVoteSummary(request.scenarioId)) {
            case (#err(#scenarioNotFound)) return #err(#scenarioNotFound);
            case (#ok(summary)) summary;
        };
        #ok({
            yourVote = vote;
            totalVotingPower = totalVotingPower;
            undecidedVotingPower = undecidedVotingPower;
            votingPowerByChoice = votingPowerByChoice;
        });
    };

    public shared ({ caller }) func voteOnScenario(request : Types.VoteOnScenarioRequest) : async Types.VoteOnScenarioResult {
        await* scenarioHandler.vote<system>(request.scenarioId, caller, request.value);
    };

    public shared query func getWorld() : async Types.GetWorldResult {
        let ?worldHandler = worldHandlerOrNull else return #err(#worldNotInitialized);
        let worldLocations = worldHandler.getLocations();
        #ok({
            progenitor = worldHandler.progenitor;
            turn = worldHandler.getTurn();
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
        votingPower : Nat;
    };

    // Private Methods ---------------------------------------------------------

    private func calculateVotingPower(user : UserHandler.User) : Nat {
        let basePower : Nat = 10;
        let levelMultiplier : Nat = 5;
        let timeMultiplier : Nat = 2;
        let maxTimePower : Nat = 100;
        let timeCap : Nat = 30 * 24 * 60 * 60 * 1_000_000_000; // 30 days in nanoseconds

        // Power from level
        let powerFromLevel : Nat = user.level * levelMultiplier;

        let timeInWorld : Nat = Int.abs(Time.now() - user.inWorldSince);

        // Power from time in world
        let worldTime : Nat = Nat.min(timeInWorld, timeCap);
        let worldTimePower : Nat = Int.abs(
            Float.toInt(
                Float.log(Float.fromInt(worldTime + 1)) / Float.log(Float.fromInt(timeCap)) * Float.fromInt(maxTimePower)
            )
        );

        // Combine powers
        basePower + powerFromLevel + worldTimePower * timeMultiplier;
    };

};
