import Nat "mo:base/Nat";
import Scenario "../models/Scenario";
import ProposalEngine "mo:dao-proposal-engine/ProposalEngine";
import ExtendedProposalEngine "mo:dao-proposal-engine/ExtendedProposalEngine";
import CommonTypes "../CommonTypes";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import UserHandler "../handlers/UserHandler";
import WorldDao "../models/WorldDao";
import Location "../models/Location";
import Outcome "../models/Outcome";

module {
    public type Actor = actor {
        getWorldProposal : query (Nat) -> async GetWorldProposalResult;
        getWorldProposals : query (count : Nat, offset : Nat) -> async CommonTypes.PagedResult<WorldProposal>;
        createWorldProposal : (request : CreateWorldProposalRequest) -> async CreateWorldProposalResult;
        getScenario : query (id : Nat) -> async ?Scenario;
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

    public type Scenario = {
        id : Nat;
        turn : Nat;
        kind : Scenario.ScenarioKind;
        outcome : ?Outcome.Outcome;
        title : Text;
        description : Text;
        options : [ScenarioOption];
        voteData : ScenarioVote;
    };

    public type ScenarioOption = {
        id : Text;
        description : Text;
    };

    public type InitializeWorldError = {
        #alreadyInitialized;
    };

    public type GetWorldError = { #worldNotInitialized };

    public type GetWorldResult = Result.Result<World, GetWorldError>;

    public type World = {
        progenitor : Principal;
        locations : [Location.Location];
        turn : Nat;
        characterLocation : Nat;
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
    };

    public type ScenarioVote = {
        yourVote : ?ScenarioVoteChoice;
        totalVotingPower : Nat;
        undecidedVotingPower : Nat;
        votingPowerByChoice : [ExtendedProposalEngine.ChoiceVotingPower<Text>];
    };

    public type ScenarioVoteChoice = {
        choice : ?Text;
        votingPower : Nat;
    };

    public type GetScenarioVoteResult = Result.Result<ScenarioVote, GetScenarioVoteError>;

    public type VoteOnScenarioRequest = {
        scenarioId : Nat;
        value : Text;
    };

    public type VoteOnScenarioError = ExtendedProposalEngine.VoteError or {
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
