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
import Random "mo:base/Random";
import WorldDao "../models/WorldDao";
import CommonTypes "../CommonTypes";
import GameHandler "../handlers/GameHandler";
import Scenario "../models/Scenario";
import ScenarioHelper "../ScenarioHelper";

actor MainActor : Types.Actor {
    // Types  ---------------------------------------------------------
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    type Duration = {
        #days : Nat;
    };

    // Stables ---------------------------------------------------------

    stable var gameStableData : GameHandler.StableData = #notInitialized;

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

    var gameHandler = GameHandler.Handler<system>(gameStableData);

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
        gameStableData := gameHandler.toStableData();
        worldDaoStableData := worldDao.toStableData();
        userStableData := userHandler.toStableData();
    };

    system func postupgrade() {
        gameHandler := GameHandler.Handler<system>(gameStableData);
        worldDao := ProposalEngine.ProposalEngine<system, WorldDao.ProposalContent>(
            worldDaoStableData,
            onWorldProposalExecute,
            onWorldProposalReject,
            onWorldProposalValidate,
        );
        userHandler := UserHandler.UserHandler(userStableData);
    };

    // Public Methods ---------------------------------------------------------

    public shared func initialize() : async Types.InitializeResult {
        // TODO is there a way to not have to intialize, or trigger immediately after creation
        let prng = PseudoRandomX.fromBlob(await Random.blob(), #xorshift32);
        let proposerId = Principal.fromActor(MainActor); // Canister will be proposer for the new game vote
        let members = buildVotingMembersList();
        gameHandler.initialize(
            prng,
            proposerId,
            members,
        );
    };

    public shared ({ caller }) func voteOnNewGame(request : Types.VoteOnNewGameRequest) : async Types.VoteOnNewGameResult {
        let { characterId; difficulty } = switch (gameHandler.voteOnNewGame(caller, request.characterId, request.difficulty)) {
            case (#ok(null)) return #ok; // no consensus yet
            case (#ok(?newGameChoice)) newGameChoice; // Concensus reached
            case (#err(err)) return #err(err);
        };
        // Start the game if consensus reached
        let prng = PseudoRandomX.fromBlob(await Random.blob(), #xorshift32);
        let members = buildVotingMembersList();
        let proposerId = Principal.fromActor(MainActor); // Canister will be proposer for the first scenario
        switch (gameHandler.startGame<system>(prng, characterId, proposerId, difficulty, members)) {
            case (#ok) #ok;
            case (#err(err)) #err(err);
        };
    };

    public shared ({ caller }) func join() : async Result.Result<(), Types.JoinError> {
        // TODO restrict to NFT?/TOken holders
        userHandler.add(caller);
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
        let members = buildVotingMembersList();

        let isAMember = members.vals()
        |> Iter.filter(
            _,
            func(member : Proposal.Member) : Bool = member.id == caller,
        )
        |> _.next() != null;
        if (not isAMember) {
            return #err(#notEligible);
        };
        Debug.print("Creating proposal for world with content: " # debug_show (request));
        await* worldDao.createProposal<system>(caller, request, members);
    };

    public shared ({ caller }) func voteOnWorldProposal(request : Types.VoteOnWorldProposalRequest) : async Types.VoteOnWorldProposalResult {
        await* worldDao.vote(request.proposalId, caller, request.vote);
    };

    public query ({ caller }) func getScenario(scenarioId : Nat) : async Types.GetScenarioResult {
        switch (gameHandler.getScenario(scenarioId)) {
            case (#ok(scenario)) #ok(mapScenario(caller, scenario));
            case (#err(err)) return #err(err);
        };
    };

    public query ({ caller }) func getScenarios() : async Types.GetScenariosResult {
        switch (gameHandler.getScenarios()) {
            case (#err(err)) return #err(err);
            case (#ok(scenarios)) {
                let mappedScenarios = scenarios.vals()
                |> Iter.map(
                    _,
                    func(scenario : Scenario.Scenario) : Types.Scenario = mapScenario(caller, scenario),
                )
                |> Iter.toArray(_);
                #ok(mappedScenarios);
            };
        };
    };

    public shared query ({ caller }) func getScenarioVote(request : Types.GetScenarioVoteRequest) : async Types.GetScenarioVoteResult {
        getScenarioVoteInternal(caller, request.scenarioId);
    };

    public shared ({ caller }) func voteOnScenario(request : Types.VoteOnScenarioRequest) : async Types.VoteOnScenarioResult {
        switch (gameHandler.voteOnScenario(request.scenarioId, caller, request.value)) {
            case (#ok(null)) ();
            case (#ok(?choice)) {
                let prng = PseudoRandomX.fromBlob(await Random.blob(), #xorshift32);
                let members = buildVotingMembersList();
                let proposerId = Principal.fromActor(MainActor); // Canister will be proposer for the next scenario
                switch (gameHandler.endTurn(prng, proposerId, members, ?choice)) {
                    case (#ok) ();
                    case (#err(#noActiveGame)) Prelude.unreachable();
                };
            };
            case (#err(error)) return #err(error);
        };
        #ok;
    };

    public shared query func getGameState() : async GameHandler.GameState {
        gameHandler.getState();
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

    private func mapScenario(
        voterId : Principal,
        scenario : Scenario.Scenario,
    ) : Types.Scenario {

        let helper = ScenarioHelper.fromKind(scenario.kind);
        let voteData = switch (getScenarioVoteInternal(voterId, scenario.id)) {
            case (#ok(voteData)) voteData;
            case (#err(#noActiveGame)) Prelude.unreachable();
            case (#err(#scenarioNotFound)) Prelude.unreachable();
        };
        {
            scenario with
            title = helper.getTitle();
            description = helper.getDescription();
            options = helper.getOptions();
            voteData = voteData;
        };
    };

    private func buildVotingMembersList() : [Proposal.Member] {
        userHandler.getAll().vals()
        |> Iter.map(
            _,
            func(user : UserHandler.User) : Proposal.Member = {
                id = user.id;
                votingPower = calculateVotingPower(user);
            },
        )
        |> Iter.toArray(_);
    };

    private func getScenarioVoteInternal(voterId : Principal, scenarioId : Nat) : Types.GetScenarioVoteResult {
        let vote = switch (gameHandler.getScenarioVote(scenarioId, voterId)) {
            case (#ok(vote)) ?vote;
            case (#err(#notEligible)) null;
            case (#err(#scenarioNotFound)) return #err(#scenarioNotFound);
            case (#err(#noActiveGame)) return #err(#noActiveGame);
        };
        let { totalVotingPower; undecidedVotingPower; votingPowerByChoice } = switch (gameHandler.getScenarioVoteSummary(scenarioId)) {
            case (#err(#scenarioNotFound)) return #err(#scenarioNotFound);
            case (#err(#noActiveGame)) Prelude.unreachable();
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

        let timeInWorld : Nat = Int.abs(Time.now() - user.inWorldSince) + 1;

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
