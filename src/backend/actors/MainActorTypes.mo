import Nat "mo:base/Nat";
import ProposalEngine "mo:dao-proposal-engine/ProposalEngine";
import ExtendedProposal "mo:dao-proposal-engine/ExtendedProposal";
import CommonTypes "../CommonTypes";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import UserHandler "../handlers/UserHandler";
import WorldDao "../models/WorldDao";
import GameHandler "../handlers/GameHandler";
import Item "../models/entities/Item";
import Race "../models/entities/Race";
import Class "../models/entities/Class";
import ScenarioMetaData "../models/entities/ScenarioMetaData";
import ScenarioSimulator "../ScenarioSimulator";
import Action "../models/entities/Action";
import Weapon "../models/entities/Weapon";
import Zone "../models/entities/Zone";
import Achievement "../models/entities/Achievement";
import Creature "../models/entities/Creature";

module {
    public type Actor = actor {
        register : () -> async RegisterResult;

        getWorldProposal : query (Nat) -> async GetWorldProposalResult;
        getWorldProposals : query (count : Nat, offset : Nat) -> async CommonTypes.PagedResult<WorldProposal>;
        createWorldProposal : (request : CreateWorldProposalRequest) -> async CreateWorldProposalResult;
        voteOnWorldProposal : VoteOnWorldProposalRequest -> async VoteOnWorldProposalResult;

        createGame : (request : CreateGameRequest) -> async CreateGameResult;
        startGame : (request : StartGameRequest) -> async StartGameResult;
        selectScenarioChoice : (request : SelectScenarioChoiceRequest) -> async SelectScenarioChoiceResult;
        abandonGame : () -> async AbandonGameResult;
        getCurrentGame : query () -> async GetCurrentGameResult;
        getCompletedGames : query (request : GetCompletedGamesRequest) -> async CommonTypes.PagedResult<GameHandler.CompletedGameWithMetaData>;

        getUser : query (userId : Principal) -> async GetUserResult;
        getUserStats : query () -> async GetUserStatsResult;
        getTopUsers : query (request : GetTopUsersRequest) -> async GetTopUsersResult;
        getUsers : query (request : GetUsersRequest) -> async GetUsersResult;

        getScenarioMetaDataList : query () -> async [ScenarioMetaData.ScenarioMetaData];
        getClasses : query () -> async [Class.Class];
        getRaces : query () -> async [Race.Race];
        getItems : query () -> async [Item.Item];
        getActions : query () -> async [Action.Action];
        getWeapons : query () -> async [Weapon.Weapon];
        getZones : query () -> async [Zone.Zone];
        getAchievements : query () -> async [Achievement.Achievement];
        getCreatures : query () -> async [Creature.Creature];
    };

    public type StartGameRequest = {
        characterId : Nat;
    };

    public type StartGameResult = Result.Result<(), { #alreadyStarted; #gameNotFound; #invalidCharacterId }>;

    public type GetCompletedGamesRequest = {
        count : Nat;
        offset : Nat;
    };

    public type AbandonGameResult = Result.Result<(), { #noActiveGame }>;
    public type GetGameRequest = {
        gameId : Nat;
    };
    public type GetCurrentGameResult = Result.Result<?GameHandler.GameWithMetaData, { #notAuthenticated }>;

    public type GetGameResult = Result.Result<GameHandler.GameWithMetaData, { #gameNotFound }>;

    public type CreateGameRequest = {};
    public type CreateGameResult = Result.Result<(), GameHandler.CreateGameError>;

    public type VoteOnNewGameRequest = {
        playerId : Principal;
        characterId : Text;
    };

    public type VoteOnNewGameError = ExtendedProposal.VoteError or {
        #gameNotFound;
        #gameNotActive;
        #invalidCharacterId;
        #alreadyStarted;
    };

    public type RegisterResult = Result.Result<UserHandler.User, RegisterError>;

    public type GetScenariosResult = Result.Result<[GameHandler.ScenarioWithMetaData], GetScenariosError>;

    public type GetScenariosError = {
        #gameNotFound;
        #gameNotActive;
    };

    public type GetScenarioRequest = {
        scenarioId : Nat;
    };

    public type GetScenarioResult = Result.Result<GameHandler.ScenarioWithMetaData, GetScenarioError>;

    public type GetScenarioError = {
        #notFound;
        #gameNotFound;
        #gameNotActive;
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

    public type SelectScenarioChoiceRequest = {
        choice : ScenarioSimulator.StageChoiceKind;
    };

    public type SelectScenarioChoiceError = {
        #gameNotFound;
        #gameNotActive;
        #invalidChoice : Text;
        #notScenarioTurn;
        #invalidTarget;
        #targetRequired;
    };

    public type SelectScenarioChoiceResult = Result.Result<(), SelectScenarioChoiceError>;

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
