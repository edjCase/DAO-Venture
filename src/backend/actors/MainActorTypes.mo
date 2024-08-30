import Nat "mo:base/Nat";
import Scenario "../models/entities/Scenario";
import ProposalEngine "mo:dao-proposal-engine/ProposalEngine";
import ExtendedProposal "mo:dao-proposal-engine/ExtendedProposal";
import CommonTypes "../CommonTypes";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import UserHandler "../handlers/UserHandler";
import WorldDao "../models/WorldDao";
import GameHandler "../handlers/GameHandler";
import Item "../models/entities/Item";
import Trait "../models/entities/Trait";
import Race "../models/entities/Race";
import Class "../models/entities/Class";

module {
    public type Actor = actor {
        register : () -> async RegisterResult;

        getWorldProposal : query (Nat) -> async GetWorldProposalResult;
        getWorldProposals : query (count : Nat, offset : Nat) -> async CommonTypes.PagedResult<WorldProposal>;
        createWorldProposal : (request : CreateWorldProposalRequest) -> async CreateWorldProposalResult;
        getScenario : query (request : GetScenarioRequest) -> async GetScenarioResult;
        getScenarios : query (request : GetScenariosRequest) -> async GetScenariosResult;
        voteOnWorldProposal : VoteOnWorldProposalRequest -> async VoteOnWorldProposalResult;

        getScenarioVote : query (request : GetScenarioVoteRequest) -> async GetScenarioVoteResult;
        voteOnScenario : (request : VoteOnScenarioRequest) -> async VoteOnScenarioResult;

        getGame : query (request : GetGameRequest) -> async GetGameResult;
        getCurrentGame : query () -> async GetCurrentGameResult;
        getCompletedGames : query () -> async [GameHandler.CompletedGameWithMetaData];

        getUser : query (userId : Principal) -> async GetUserResult;
        getUserStats : query () -> async GetUserStatsResult;
        getTopUsers : query (request : GetTopUsersRequest) -> async GetTopUsersResult;
        getUsers : query (request : GetUsersRequest) -> async GetUsersResult;

        createGame : () -> async CreateGameResult;
        abandonGame : (gameId : Nat) -> async AbandonGameResult;
        joinGame : (request : JoinGameRequest) -> async JoinGameResult;
        kickPlayer : (request : KickPlayerRequest) -> async KickPlayerResult;
        changeGameDifficulty : (difficulty : GameHandler.Difficulty) -> async ChangeGameDifficultyResult;
        startGameVote : (request : StartGameVoteRequest) -> async StartGameVoteResult;
        voteOnNewGame : (request : VoteOnNewGameRequest) -> async VoteOnNewGameResult;

        getScenarioMetaDataList : query () -> async [Scenario.ScenarioMetaData];

        getTraits : query () -> async [Trait.Trait];

        getClasses : query () -> async [Class.Class];

        getRaces : query () -> async [Race.Race];

        getItems : query () -> async [Item.Item];
    };

    public type AbandonGameResult = Result.Result<(), { #gameNotFound; #notAuthorized; #gameComplete }>;

    public type ChangeGameDifficultyResult = Result.Result<(), { #gameNotFound; #notAuthorized; #gameStarted }>;

    public type KickPlayerRequest = {
        gameId : Nat;
        playerId : Principal;
    };

    public type KickPlayerResult = Result.Result<(), { #gameNotFound; #notAuthorized; #playerNotInGame; #kickHostForbidden }>;

    public type JoinGameRequest = {
        gameId : Nat;
    };

    public type JoinGameResult = Result.Result<(), { #gameNotFound; #lobbyClosed; #alreadyJoined; #notRegistered }>;

    public type StartGameVoteRequest = {
        gameId : Nat;
    };

    public type StartGameVoteResult = Result.Result<(), { #gameNotFound; #gameAlreadyStarted; #notAuthorized }>;

    public type GetGameRequest = {
        gameId : Nat;
    };

    public type GetCurrentGameResult = Result.Result<?GameHandler.GameWithMetaData, { #notAuthenticated }>;

    public type GetGameResult = Result.Result<GameHandler.GameWithMetaData, { #gameNotFound }>;

    public type CreateGameResult = Result.Result<Nat, GameHandler.CreateGameError>;

    public type VoteOnNewGameRequest = {
        gameId : Nat;
        characterId : Text;
    };

    public type VoteOnNewGameError = ExtendedProposal.VoteError or {
        #gameNotFound;
        #gameNotActive;
        #invalidCharacterId;
        #alreadyStarted;
    };

    public type VoteOnNewGameResult = Result.Result<(), VoteOnNewGameError>;

    public type RegisterResult = Result.Result<UserHandler.User, RegisterError>;

    public type GetScenariosRequest = {
        gameId : Nat;
    };

    public type GetScenariosResult = Result.Result<[Scenario], GetScenariosError>;

    public type GetScenariosError = {
        #gameNotFound;
        #gameNotActive;
    };

    public type GetScenarioRequest = {
        gameId : Nat;
        scenarioId : Nat;
    };

    public type GetScenarioResult = Result.Result<Scenario, GetScenarioError>;

    public type GetScenarioError = {
        #notFound;
        #gameNotFound;
        #gameNotActive;
    };

    public type Scenario = Scenario.Scenario and {
        metaData : Scenario.ScenarioMetaData;
        voteData : ScenarioVote;
        availableChoiceIds : [Text];
    };

    public type CreateWorldProposalRequest = {
        #motion : WorldDao.MotionContent;
        #modifyGameContent : WorldDao.ModifyGameContent;
    };

    public type CreateWorldProposalError = {
        #notEligible;
        #invalid : [Text];
    };

    public type CreateWorldProposalResult = Result.Result<Nat, CreateWorldProposalError>;

    public type RegisterError = {
        #alreadyMember;
    };

    public type GetPositionError = {};

    public type GetScenarioVoteRequest = {
        gameId : Nat;
        scenarioId : Nat;
    };

    public type GetScenarioVoteError = {
        #scenarioNotFound;
        #gameNotFound;
        #gameNotActive;
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
        gameId : Nat;
        scenarioId : Nat;
        value : Text;
    };

    public type VoteOnScenarioError = ExtendedProposal.VoteError or {
        #scenarioNotFound;
        #invalidChoice;
        #gameNotFound;
        #gameNotActive;
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
