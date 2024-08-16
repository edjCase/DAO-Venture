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
import Character "../models/Character";

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

        getGameState : query () -> async GetGameStateResult;

        getUser : query (userId : Principal) -> async GetUserResult;
        getUserStats : query () -> async GetUserStatsResult;
        getTopUsers : query (request : GetTopUsersRequest) -> async GetTopUsersResult;
        getUsers : query (request : GetUsersRequest) -> async GetUsersResult;

        startGame : () -> async StartGameResult;
        join : () -> async JoinResult;

        nextTurn : () -> async NextTurnResult;
    };

    public type StartGameError = {
        #alreadyStarted;
    };

    public type StartGameResult = Result.Result<(), StartGameError>;

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

    public type NextTurnResult = Result.Result<(), { #noActiveInstance }>;

    public type Scenario = {
        id : Nat;
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

    public type GetGameStateError = { #noActiveGame };

    public type GetGameStateResult = Result.Result<GameState, GetGameStateError>;

    public type GameState = {
        locations : [Location.Location];
        turn : Nat;
        characterLocationId : Nat;
        character : Character;
    };

    public type Character = {
        gold : Nat;
        health : Nat;
        stats : Character.CharacterStats;
        items : [Item];
        traits : [Trait];
    };

    public type Item = {
        id : Text;
        name : Text;
        description : Text;
    };

    public type Trait = {
        id : Text;
        name : Text;
        description : Text;
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
        #noActiveGame;
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
