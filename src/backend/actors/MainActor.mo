import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Bool "mo:base/Bool";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Types "MainActorTypes";
import UserHandler "../handlers/UserHandler";
import ProposalEngine "mo:dao-proposal-engine/ProposalEngine";
import Proposal "mo:dao-proposal-engine/Proposal";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Float "mo:base/Float";
import Prelude "mo:base/Prelude";
import WorldDao "../models/WorldDao";
import WorldHandler "../handlers/WorldHandler";
import ScenarioHandler "../handlers/ScenarioHandler";
import CommonTypes "../CommonTypes";
import CharacterHandler "../handlers/CharacterHandler";
import MysteriousStructure "../scenarios/MysteriousStructure";
import HexGrid "../models/HexGrid";

actor MainActor : Types.Actor {
    // Types  ---------------------------------------------------------
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    type Duration = {
        #days : Nat;
    };

    // Stables ---------------------------------------------------------

    stable var worldStableData : WorldHandler.StableData = {
        characterLocationId = 0;
        turn = 0;
        locations = [
            {
                id = 0;
                coordinate = { q = 0; r = 0 };
                kind = #home;
            },
            {
                id = HexGrid.axialCoordinateToIndex({ q = 1; r = 0 });
                coordinate = { q = 1; r = 0 };
                kind = #unexplored;
            },
        ];
    };

    stable var scenarioStableData : ScenarioHandler.StableData = {
        scenarios = [];
    };

    stable var characterStableData : CharacterHandler.StableData = {
        character = {
            gold = 0;
            health = 100;
            traits = [];
            items = [];
        };
    };

    stable var worldDaoStableData : ProposalEngine.StableData<WorldDao.ProposalContent> = {
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

    var worldHandler = WorldHandler.Handler(worldStableData);

    var characterHandler = CharacterHandler.Handler(characterStableData);

    var scenarioHandler = ScenarioHandler.Handler<system>(scenarioStableData, characterHandler);

    var userHandler = UserHandler.UserHandler(userStableData);

    func onWorldProposalExecute(proposal : ProposalEngine.Proposal<WorldDao.ProposalContent>) : async* Result.Result<(), Text> {
        // TODO change world proposal for town data to be a simple approve w/ callback. Dont need to expose all the update routes
        switch (proposal.content) {
            case (#motion(_)) {
                // Do nothing
                #ok;
            };
        };
    };
    func onWorldProposalReject(_ : ProposalEngine.Proposal<WorldDao.ProposalContent>) : async* () {}; // TODO
    func onWorldProposalValidate(_ : WorldDao.ProposalContent) : async* Result.Result<(), [Text]> {
        #ok; // TODO
    };
    var worldDao = ProposalEngine.ProposalEngine<system, WorldDao.ProposalContent>(
        worldDaoStableData,
        onWorldProposalExecute,
        onWorldProposalReject,
        onWorldProposalValidate,
    );

    // System Methods ---------------------------------------------------------

    system func preupgrade() {
        characterStableData := characterHandler.toStableData();
        scenarioStableData := scenarioHandler.toStableData();
        worldDaoStableData := worldDao.toStableData();
        userStableData := userHandler.toStableData();
        worldStableData := worldHandler.toStableData();
    };

    system func postupgrade() {
        characterHandler := CharacterHandler.Handler(characterStableData);
        scenarioHandler := ScenarioHandler.Handler<system>(scenarioStableData, characterHandler);
        worldDao := ProposalEngine.ProposalEngine<system, WorldDao.ProposalContent>(
            worldDaoStableData,
            onWorldProposalExecute,
            onWorldProposalReject,
            onWorldProposalValidate,
        );
        userHandler := UserHandler.UserHandler(userStableData);
        worldHandler := WorldHandler.Handler(worldStableData);
    };

    // Public Methods ---------------------------------------------------------

    public shared ({ caller }) func joinWorld() : async Result.Result<(), Types.JoinWorldError> {
        // TODO restrict to NFT?/TOken holders
        userHandler.addWorldMember(caller);
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
            func(user : UserHandler.User) : Proposal.Member = {
                id = user.id;
                votingPower = calculateVotingPower(user);
            },
        )
        |> Iter.toArray(_);

        let isAMember = members.vals()
        |> Iter.filter(
            _,
            func(member : Proposal.Member) : Bool = member.id == caller,
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

    public query ({ caller }) func getScenario(scenarioId : Nat) : async ?Types.Scenario {
        let ?scenario = scenarioHandler.get(scenarioId) else return null;
        let (title, description, options) = switch (scenario.kind) {
            case (#mysteriousStructure(mysteriousStructure)) {
                let title = MysteriousStructure.getTitle();
                let description = MysteriousStructure.getDescription(mysteriousStructure);
                let options = MysteriousStructure.getOptions();
                (title, description, options);
            };
        };
        let voteData = switch (getScenarioVoteInternal(caller, scenarioId)) {
            case (#ok(voteData)) voteData;
            case (#err(#scenarioNotFound)) Prelude.unreachable();
        };
        ?{
            scenario with
            title = title;
            description = description;
            options = options;
            voteData = voteData;
        };
    };

    public shared query ({ caller }) func getScenarioVote(request : Types.GetScenarioVoteRequest) : async Types.GetScenarioVoteResult {
        getScenarioVoteInternal(caller, request.scenarioId);
    };

    public shared ({ caller }) func voteOnScenario(request : Types.VoteOnScenarioRequest) : async Types.VoteOnScenarioResult {
        await* scenarioHandler.vote(request.scenarioId, caller, request.value);
    };

    public shared query func getWorld() : async Types.GetWorldResult {
        let worldLocations = worldHandler.getLocations();
        #ok({
            turn = worldHandler.getTurn();
            locations = worldLocations.vals() |> Iter.toArray(_);
            characterLocationId = worldHandler.getCharacterLocationId();
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

    private func getScenarioVoteInternal(voterId : Principal, scenarioId : Nat) : Types.GetScenarioVoteResult {
        let vote = switch (scenarioHandler.getVote(scenarioId, voterId)) {
            case (#ok(vote)) ?vote;
            case (#err(#notEligible)) null;
            case (#err(#scenarioNotFound)) return #err(#scenarioNotFound);
        };
        let { totalVotingPower; undecidedVotingPower; votingPowerByChoice } = switch (scenarioHandler.getVoteSummary(scenarioId)) {
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
