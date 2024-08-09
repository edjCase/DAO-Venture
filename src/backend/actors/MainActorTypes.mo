import Nat "mo:base/Nat";
import Scenario "../models/Scenario";
import ProposalEngine "mo:dao-proposal-engine/BinaryProposalEngine";
import GenericProposalEngine "mo:dao-proposal-engine/GenericProposalEngine";
import CommonTypes "../CommonTypes";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import UserHandler "../handlers/UserHandler";
import WorldDao "../models/WorldDao";
import World "../models/World";

module {
    public type Actor = actor {
        getWorldProposal : query (Nat) -> async GetWorldProposalResult;
        getWorldProposals : query (count : Nat, offset : Nat) -> async CommonTypes.PagedResult<WorldProposal>;
        createWorldProposal : (request : CreateWorldProposalRequest) -> async CreateWorldProposalResult;
        getScenario : query (Nat) -> async GetScenarioResult;
        getAllScenarios : query (request : GetAllScenariosRequest) -> async GetAllScenariosResult;
        voteOnWorldProposal : VoteOnWorldProposalRequest -> async VoteOnWorldProposalResult;

        getScenarioVote : query (request : GetScenarioVoteRequest) -> async GetScenarioVoteResult;
        voteOnScenario : (request : VoteOnScenarioRequest) -> async VoteOnScenarioResult;

        getProgenitor : query () -> async ?Principal;

        getWorld : query () -> async GetWorldResult;

        getUser : query (userId : Principal) -> async GetUserResult;
        getUserStats : query () -> async GetUserStatsResult;
        getTopUsers : query (request : GetTopUsersRequest) -> async GetTopUsersResult;
        getUsers : query (request : GetUsersRequest) -> async GetUsersResult;

        intializeWorld : () -> async Result.Result<(), InitializeWorldError>;
        joinWorld : () -> async Result.Result<(), JoinWorldError>;
    };

    public type InitializeWorldError = {
        #alreadyInitialized;
    };

    public type GetWorldError = { #worldNotInitialized };

    public type GetWorldResult = Result.Result<World, GetWorldError>;

    public type World = {
        progenitor : Principal;
        locations : [World.WorldLocation];
        turn : Nat;
    };

    public type CreateWorldProposalRequest = {
        #motion : WorldDao.MotionContent;
    };

    public type CreateWorldProposalError = {
        #notAuthorized;
        #invalid : [Text];
    };

    public type CreateWorldProposalResult = Result.Result<Nat, CreateWorldProposalError>;

    public type JoinWorldError = {
        #notAuthorized;
        #alreadyWorldMember;
    };

    public type GetPositionError = {};

    public type GetScenarioVoteRequest = {
        scenarioId : Nat;
    };

    public type GetScenarioVoteError = {
        #scenarioNotFound;
        #notEligible;
    };

    public type ScenarioVote = {
        yourVote : ?ScenarioVoteChoice;
        totalVotingPower : Nat;
        undecidedVotingPower : Nat;
        votingPowerByChoice : [GenericProposalEngine.ChoiceVotingPower<Scenario.ScenarioChoiceKind>];
    };

    public type ScenarioVoteChoice = {
        choice : ?Scenario.ScenarioChoiceKind;
        votingPower : Nat;
    };

    public type GetScenarioVoteResult = Result.Result<ScenarioVote, GetScenarioVoteError>;

    public type VoteOnScenarioRequest = {
        scenarioId : Nat;
        value : Scenario.ScenarioChoiceKind;
    };

    public type VoteOnScenarioError = GenericProposalEngine.VoteError or {
        #scenarioNotFound;
        #invalidChoice;
    };

    public type VoteOnScenarioResult = Result.Result<(), VoteOnScenarioError>;

    public type GetWorldProposalError = {
        #proposalNotFound;
    };

    public type GetWorldProposalResult = Result.Result<WorldProposal, GetWorldProposalError>;

    public type WorldProposal = ProposalEngine.Proposal<WorldDao.ProposalContent>;

    public type VoteOnWorldProposalRequest = {
        proposalId : Nat;
        vote : Bool;
    };

    public type VoteOnWorldProposalResult = Result.Result<(), VoteOnWorldProposalError>;

    public type VoteOnWorldProposalError = {
        #notAuthorized;
        #proposalNotFound;
        #alreadyVoted;
        #votingClosed;
    };

    public type GetScenarioError = {
        #notFound;
        #notStarted;
    };

    public type GetScenarioResult = Result.Result<Scenario.Scenario, GetScenarioError>;

    public type GetAllScenariosResult = CommonTypes.PagedResult<Scenario.Scenario>;

    public type GetAllScenariosRequest = {
        count : Nat;
        offset : Nat;
    };

    public type GetTopUsersRequest = {
        count : Nat;
        offset : Nat;
    };

    public type GetTopUsersResult = {
        #ok : CommonTypes.PagedResult<UserHandler.User>;
    };

    public type GetUserStatsResult = Result.Result<UserHandler.UserStats, ()>;

    public type GetUsersRequest = {
        #all;
    };

    public type GetUsersResult = {
        #ok : [UserHandler.User];
    };

    public type GetUserError = {
        #notFound;
        #notAuthorized;
    };

    public type GetUserResult = Result.Result<UserHandler.User, GetUserError>;
};
