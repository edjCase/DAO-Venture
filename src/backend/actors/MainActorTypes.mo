import Nat "mo:base/Nat";
import Scenario "../models/Scenario";
import ProposalEngine "mo:dao-proposal-engine/ProposalEngine";
import ExtendedProposal "mo:dao-proposal-engine/ExtendedProposal";
import CommonTypes "../CommonTypes";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import UserHandler "../handlers/UserHandler";
import WorldDao "../models/WorldDao";
import GameHandler "../handlers/GameHandler";

module {
    public type Actor = actor {
        getWorldProposal : query (Nat) -> async GetWorldProposalResult;
        getWorldProposals : query (count : Nat, offset : Nat) -> async CommonTypes.PagedResult<WorldProposal>;
        createWorldProposal : (request : CreateWorldProposalRequest) -> async CreateWorldProposalResult;
        getScenario : query (id : Nat) -> async GetScenarioResult;
        getScenarios : query () -> async GetScenariosResult;
        voteOnWorldProposal : VoteOnWorldProposalRequest -> async VoteOnWorldProposalResult;

        getScenarioVote : query (request : GetScenarioVoteRequest) -> async GetScenarioVoteResult;
        voteOnScenario : (request : VoteOnScenarioRequest) -> async VoteOnScenarioResult;

        getGameInstance : query () -> async GameHandler.GameInstanceWithMetaData;

        getUser : query (userId : Principal) -> async GetUserResult;
        getUserStats : query () -> async GetUserStatsResult;
        getTopUsers : query (request : GetTopUsersRequest) -> async GetTopUsersResult;
        getUsers : query (request : GetUsersRequest) -> async GetUsersResult;

        initialize : () -> async InitializeResult;
        voteOnNewGame : (request : VoteOnNewGameRequest) -> async VoteOnNewGameResult;
        join : () -> async JoinResult;
    };

    public type InitializeResult = Result.Result<(), { #alreadyInitialized }>;

    public type VoteOnNewGameRequest = {
        characterId : Nat;
        difficulty : GameHandler.Difficulty;
    };

    public type VoteOnNewGameError = ExtendedProposal.VoteError or {
        #noActiveGame;
        #invalidCharacterId;
        #alreadyStarted;
    };

    public type VoteOnNewGameResult = Result.Result<(), VoteOnNewGameError>;

    public type JoinResult = Result.Result<(), JoinError>;

    public type GetScenariosResult = Result.Result<[Scenario], GetScenariosError>;

    public type GetScenariosError = {
        #noActiveGame;
    };

    public type GetScenarioResult = Result.Result<Scenario, GetScenarioError>;

    public type GetScenarioError = {
        #notFound;
        #noActiveGame;
    };

    public type Scenario = Scenario.Scenario and {
        metaData : Scenario.ScenarioMetaData;
        voteData : ScenarioVote;
        availableChoiceIds : [Text];
    };

    public type CreateWorldProposalRequest = {
        #motion : WorldDao.MotionContent;
    };

    public type CreateWorldProposalError = {
        #notEligible;
        #invalid : [Text];
    };

    public type CreateWorldProposalResult = Result.Result<Nat, CreateWorldProposalError>;

    public type JoinError = {
        #alreadyMember;
    };

    public type GetPositionError = {};

    public type GetScenarioVoteRequest = {
        scenarioId : Nat;
    };

    public type GetScenarioVoteError = {
        #scenarioNotFound;
        #noActiveGame;
    };

    public type ScenarioVote = {
        yourVote : ?ScenarioVoteChoice;
        totalVotingPower : Nat;
        undecidedVotingPower : Nat;
        votingPowerByChoice : [ExtendedProposal.ChoiceVotingPower<Text>];
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

    public type VoteOnScenarioError = ExtendedProposal.VoteError or {
        #scenarioNotFound;
        #invalidChoice;
        #noActiveGame;
        #choiceRequirementNotMet;
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
        #notEligible;
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
    };

    public type GetUserResult = Result.Result<UserHandler.User, GetUserError>;
};
