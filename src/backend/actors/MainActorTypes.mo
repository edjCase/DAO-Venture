import Nat "mo:base/Nat";
import Scenario "../models/Scenario";
import ProposalEngine "mo:dao-proposal-engine/BinaryProposalEngine";
import CommonTypes "../CommonTypes";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import UserHandler "../handlers/UserHandler";
import WorldDao "../models/WorldDao";
import World "../models/World";
import Flag "../models/Flag";

module {
    public type Actor = actor {
        getWorldProposal : query (Nat) -> async GetWorldProposalResult;
        getWorldProposals : query (count : Nat, offset : Nat) -> async GetWorldProposalsResult;
        createWorldProposal : (request : CreateWorldProposalRequest) -> async CreateWorldProposalResult;
        getScenario : query (Nat) -> async GetScenarioResult;
        getScenarios : query () -> async GetScenariosResult;
        voteOnWorldProposal : VoteOnWorldProposalRequest -> async VoteOnWorldProposalResult;

        getScenarioVote : query (request : GetScenarioVoteRequest) -> async GetScenarioVoteResult;
        voteOnScenario : (request : VoteOnScenarioRequest) -> async VoteOnScenarioResult;

        getProgenitor : query () -> async ?Principal;

        getWorld : query () -> async GetWorldResult;

        getUser : query (userId : Principal) -> async GetUserResult;
        getUserStats : query () -> async GetUserStatsResult;
        getTopUsers : query (request : GetTopUsersRequest) -> async GetTopUsersResult;
        getUsers : query (request : GetUsersRequest) -> async GetUsersResult;

        intializeWorld : (request : InitializeWorldRequest) -> async Result.Result<(), InitializeWorldError>;
        joinWorld : (request : JoinWorldRequest) -> async Result.Result<(), JoinWorldError>;
    };

    public type InitializeWorldRequest = {
        town : InitializeTownRequest;
    };

    public type InitializeTownRequest = {
        name : Text;
        motto : Text;
        flag : Flag.FlagImage;
        color : (Nat8, Nat8, Nat8);
    };

    public type InitializeWorldError = {
        #alreadyInitialized;
    };

    public type GetTownHistoryError = {
        #townNotFound;
    };

    public type GetWorldError = { #worldNotInitialized };

    public type GetWorldResult = Result.Result<World, GetWorldError>;

    public type World = {
        progenitor : Principal;
        locations : [World.WorldLocation];
        daysElapsed : Nat;
        nextDayStartTime : Nat;
    };

    public type CreateWorldProposalRequest = {
        #motion : WorldDao.MotionContent;
    };

    public type CreateWorldProposalError = {
        #notAuthorized;
        #invalid : [Text];
    };

    public type CreateWorldProposalResult = Result.Result<Nat, CreateWorldProposalError>;

    public type JoinWorldRequest = {
        townId : Nat;
    };

    public type JoinWorldError = {
        #notAuthorized;
        #alreadyWorldMember;
        #noTowns;
    };

    public type GetPositionError = {
        #townNotFound;
    };

    public type GetScenarioVoteRequest = {
        scenarioId : Nat;
    };

    public type GetScenarioVoteError = {
        #scenarioNotFound;
        #notEligible;
    };

    public type VotingData = {
        yourData : ?ScenarioVote;
    };

    public type ScenarioVote = {
        value : ?Nat;
        votingPower : Nat;
    };

    public type GetScenarioVoteResult = Result.Result<VotingData, GetScenarioVoteError>;

    public type VoteOnScenarioRequest = {
        scenarioId : Nat;
        value : Nat;
    };

    public type VoteOnScenarioError = {
        #notEligible;
        #scenarioNotFound;
        #votingNotOpen;
        #invalidValue;
    };

    public type VoteOnScenarioResult = Result.Result<(), VoteOnScenarioError>;

    public type GetWorldProposalError = {
        #proposalNotFound;
    };

    public type GetWorldProposalResult = Result.Result<WorldProposal, GetWorldProposalError>;

    public type GetWorldProposalsResult = {
        #ok : CommonTypes.PagedResult<WorldProposal>;
    };

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

    public type GetScenariosResult = {
        #ok : [Scenario.Scenario];
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
        #town : Nat;
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
