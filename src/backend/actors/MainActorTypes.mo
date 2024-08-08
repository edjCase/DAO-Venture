import Nat "mo:base/Nat";
import Scenario "../models/Scenario";
import ProposalTypes "mo:dao-proposal-engine/Types";
import CommonTypes "../CommonTypes";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import ScenarioHandler "../handlers/ScenarioHandler";
import UserHandler "../handlers/UserHandler";
import WorldDao "../models/WorldDao";
import Town "../models/Town";
import World "../models/World";
import TownsHandler "../handlers/TownsHandler";
import Flag "../models/Flag";

module {
    public type Actor = actor {
        getWorldProposal : query (Nat) -> async GetWorldProposalResult;
        getWorldProposals : query (count : Nat, offset : Nat) -> async GetWorldProposalsResult;
        createWorldProposal : (request : CreateWorldProposalRequest) -> async CreateWorldProposalResult;
        getScenario : query (Nat) -> async GetScenarioResult;
        getScenarios : query () -> async GetScenariosResult;
        voteOnWorldProposal : VoteOnWorldProposalRequest -> async VoteOnWorldProposalResult;
        addScenario : (scenario : AddScenarioRequest) -> async AddScenarioResult;

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

    public type GetTownHistoryResult = Result.Result<CommonTypes.PagedResult<TownsHandler.DaySnapshot>, GetTownHistoryError>;

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

    public type GetScenarioVoteResult = Result.Result<ScenarioHandler.VotingData, GetScenarioVoteError>;

    public type VoteOnScenarioRequest = {
        scenarioId : Nat;
        value : Scenario.ScenarioOptionValue;
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

    public type WorldProposal = ProposalTypes.Proposal<WorldDao.ProposalContent>;

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

    public type AddScenarioRequest = ScenarioHandler.AddScenarioRequest;

    public type AddScenarioError = {
        #invalid : [Text];
        #notAuthorized;
    };

    public type AddScenarioResult = Result.Result<(), AddScenarioError>;

    public type CreatePlayerFluffRequest = {
        name : Text;
        title : Text;
        description : Text;
        quirks : [Text];
        likes : [Text];
        dislikes : [Text];
    };

    public type InvalidError = {
        #nameTaken;
        #nameNotSpecified;
    };

    public type CreatePlayerFluffError = {
        #notAuthorized;
        #invalid : [InvalidError];
    };

    public type CreatePlayerFluffResult = Result.Result<(), CreatePlayerFluffError>;

    public type GetPlayerError = {
        #notFound;
    };

    public type TownProposal = ProposalTypes.Proposal<TownDao.ProposalContent>;

    public type GetTownProposalResult = Result.Result<TownProposal, GetTownProposalError>;

    public type GetTownProposalError = {
        #proposalNotFound;
        #townNotFound;
    };

    public type GetTownProposalsResult = Result.Result<CommonTypes.PagedResult<ProposalTypes.Proposal<TownDao.ProposalContent>>, GetTownProposalsError>;

    public type GetTownProposalsError = {
        #townNotFound;
    };

    public type VoteOnTownProposalRequest = {
        proposalId : Nat;
        vote : Bool;
    };

    public type VoteOnTownProposalResult = Result.Result<(), VoteOnTownProposalError>;

    public type VoteOnTownProposalError = {
        #notAuthorized;
        #proposalNotFound;
        #alreadyVoted;
        #votingClosed;
        #townNotFound;
    };

    public type TownProposalContent = TownDao.ProposalContent;

    public type CreateTownProposalResult = Result.Result<Nat, CreateTownProposalError>;

    public type CreateTownProposalError = {
        #notAuthorized;
        #townNotFound;
        #invalid : [Text];
    };

    public type CreateTownResult = Result.Result<Nat, CreateTownError>;

    public type CreateTownError = {
        #nameTaken;
        #notAuthorized;
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

    public type AssignUserToTownRequest = {
        userId : Principal;
        townId : Nat;
    };

    public type AssignUserToTownError = {
        #townNotFound;
        #notAuthorized;
        #notWorldMember;
    };

    public type GetUserError = {
        #notFound;
        #notAuthorized;
    };

    public type GetUserResult = Result.Result<UserHandler.User, GetUserError>;
};
