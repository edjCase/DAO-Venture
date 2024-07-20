import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Scenario "../models/Scenario";
import ProposalTypes "mo:dao-proposal-engine/Types";
import CommonTypes "../CommonTypes";
import Components "mo:datetime/Components";
import Result "mo:base/Result";
import ScenarioHandler "../handlers/ScenarioHandler";
import UserHandler "../handlers/UserHandler";

module {
    public type Actor = actor {

        getLeagueProposal : query (Nat) -> async GetLeagueProposalResult;
        getLeagueProposals : query (count : Nat, offset : Nat) -> async GetLeagueProposalsResult;
        createLeagueProposal : (request : CreateLeagueProposalRequest) -> async CreateLeagueProposalResult;
        getScenario : query (Nat) -> async GetScenarioResult;
        getScenarios : query () -> async GetScenariosResult;
        voteOnLeagueProposal : VoteOnLeagueProposalRequest -> async VoteOnLeagueProposalResult;
        addScenario : (scenario : AddScenarioRequest) -> async AddScenarioResult;

        getScenarioVote : query (request : GetScenarioVoteRequest) -> async GetScenarioVoteResult;
        voteOnScenario : (request : VoteOnScenarioRequest) -> async VoteOnScenarioResult;

        claimBenevolentDictatorRole : () -> async ClaimBenevolentDictatorRoleResult;
        setBenevolentDictatorState : (state : BenevolentDictatorState) -> async SetBenevolentDictatorStateResult;
        getBenevolentDictatorState : query () -> async BenevolentDictatorState;

        addFluff : (request : CreatePlayerFluffRequest) -> async CreatePlayerFluffResult;
        getPlayer : query (id : Nat32) -> async GetPlayerResult;
        getPosition : query (townId : Nat, position : FieldPosition.FieldPosition) -> async Result.Result<Player.Player, GetPositionError>;
        getTownPlayers : query (townId : Nat) -> async [Player.Player];
        getAllPlayers : query () -> async [Player.Player];

        getLiveMatchGroupState : query () -> async ?LiveState.LiveMatchGroupState;
        startNextMatchGroup : () -> async StartMatchGroupResult;

        getLeagueData : query () -> async LeagueData;
        getTowns : query () -> async [Town];
        createTownProposal : (townId : Nat, request : TownProposalContent) -> async CreateTownProposalResult;
        getTownProposal : query (townId : Nat, id : Nat) -> async GetTownProposalResult;
        getTownProposals : query (townId : Nat, count : Nat, offset : Nat) -> async GetTownProposalsResult;
        voteOnTownProposal : (townId : Nat, request : VoteOnTownProposalRequest) -> async VoteOnTownProposalResult;
        createTownTrait : (request : CreateTownTraitRequest) -> async CreateTownTraitResult;

        getUser : query (userId : Principal) -> async GetUserResult;
        getUserStats : query () -> async GetUserStatsResult;
        getTownOwners : query (request : GetTownOwnersRequest) -> async GetTownOwnersResult;
        getUserLeaderboard : query (request : GetUserLeaderboardRequest) -> async GetUserLeaderboardResult;
        assignUserToTown : (request : AssignUserToTownRequest) -> async Result.Result<(), AssignUserToTownError>;
        joinLeague : () -> async Result.Result<(), JoinLeagueError>;
    };

    public type CreateLeagueProposalRequest = {
        #motion : LeagueDao.MotionContent;
    };

    public type CreateLeagueProposalError = {
        #notAuthorized;
        #invalid : [Text];
    };

    public type CreateLeagueProposalResult = Result.Result<Nat, CreateLeagueProposalError>;

    public type JoinLeagueError = {
        #notAuthorized;
        #alreadyLeagueMember;
        #noTowns;
    };

    public type LeagueData = {
        leagueIncome : Nat;
        entropyThreshold : Nat;
        currentEntropy : Nat;
    };

    public type FinishMatchGroupResult = Result.Result<(), FinishMatchGroupError>;

    public type FinishMatchGroupError = {
        #notAuthorized;
        #noLiveMatchGroup;
    };

    public type Town = {
        id : Nat;
        name : Text;
        logoUrl : Text;
        color : (Nat8, Nat8, Nat8);
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

    public type ClaimBenevolentDictatorRoleError = {
        #notOpenToClaim;
        #notAuthenticated;
    };

    public type ClaimBenevolentDictatorRoleResult = Result.Result<(), ClaimBenevolentDictatorRoleError>;

    public type SetBenevolentDictatorStateError = {
        #notAuthorized;
    };

    public type SetBenevolentDictatorStateResult = Result.Result<(), SetBenevolentDictatorStateError>;

    public type GetLeagueProposalError = {
        #proposalNotFound;
    };

    public type GetLeagueProposalResult = Result.Result<LeagueProposal, GetLeagueProposalError>;

    public type GetLeagueProposalsResult = {
        #ok : CommonTypes.PagedResult<LeagueProposal>;
    };

    public type LeagueProposal = ProposalTypes.Proposal<LeagueDao.ProposalContent>;

    public type VoteOnLeagueProposalRequest = {
        proposalId : Nat;
        vote : Bool;
    };

    public type VoteOnLeagueProposalResult = Result.Result<(), VoteOnLeagueProposalError>;

    public type VoteOnLeagueProposalError = {
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

    public type BenevolentDictatorState = {
        #open;
        #claimed : Principal;
        #disabled;
    };

    public type TownStandingInfo = {
        id : Nat;
        wins : Nat;
        losses : Nat;
        totalScore : Int;
    };

    public type GetTownStandingsError = {
        #notFound;
    };

    public type GetTownStandingsResult = Result.Result<[TownStandingInfo], GetTownStandingsError>;

    public type GetMatchGroupPredictionsError = {
        #notFound;
    };

    public type GetMatchGroupPredictionsResult = Result.Result<MatchGroupPredictionSummary, GetMatchGroupPredictionsError>;

    public type MatchGroupPredictionSummary = {
        matches : [MatchPredictionSummary];
    };

    public type MatchPredictionSummary = {
        town1 : Nat;
        town2 : Nat;
        yourVote : ?Town.TownId;
    };

    public type PredictMatchOutcomeRequest = {
        matchId : Nat;
        winner : ?Town.TownId;
    };

    public type PredictMatchOutcomeError = {
        #matchGroupNotFound;
        #matchNotFound;
        #predictionsClosed;
        #identityRequired;
    };

    public type PredictMatchOutcomeResult = Result.Result<(), PredictMatchOutcomeError>;

    public type StartMatchGroupError = {
        #matchGroupNotFound;
        #notAuthorized;
        #notScheduledYet;
        #alreadyStarted;
        #matchErrors : [{
            matchId : Nat;
            error : StartMatchError;
        }];
    };

    public type StartMatchGroupResult = Result.Result<(), StartMatchGroupError>;

    public type StartMatchError = {
        #notEnoughPlayers : Town.TownIdOrBoth;
    };

    public type StartSeasonRequest = {
        startTime : Time.Time;
        weekDays : [Components.DayOfWeek];
    };

    public type AddScenarioRequest = ScenarioHandler.AddScenarioRequest;

    public type AddScenarioError = {
        #invalid : [Text];
        #notAuthorized;
    };

    public type AddScenarioResult = Result.Result<(), AddScenarioError>;

    public type StartSeasonError = {
        #alreadyStarted;
        #idTaken;
        #seedGenerationError : Text;
        #invalidArgs : Text;
        #notAuthorized;
    };

    public type StartSeasonResult = Result.Result<(), StartSeasonError>;

    public type CloseSeasonError = {
        #notAuthorized;
        #seasonNotOpen;
    };

    public type CloseSeasonResult = Result.Result<(), CloseSeasonError>;

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

    public type GetPlayerResult = Result.Result<Player.Player, GetPlayerError>;

    public type CreateTownTraitRequest = {
        id : Text;
        name : Text;
        description : Text;
    };

    public type CreateTownTraitError = {
        #notAuthorized;
        #idTaken;
        #invalid : [Text];
    };

    public type CreateTownTraitResult = Result.Result<(), CreateTownTraitError>;

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

    public type CreateTownRequest = {
        name : Text;
        logoUrl : Text;
        motto : Text;
        description : Text;
        color : (Nat8, Nat8, Nat8);
        entropy : Nat;
        currency : Nat;
    };

    public type CreateTownResult = Result.Result<Nat, CreateTownError>;

    public type CreateTownError = {
        #nameTaken;
        #notAuthorized;
    };

    public type GetUserLeaderboardRequest = {
        count : Nat;
        offset : Nat;
    };

    public type GetUserLeaderboardResult = {
        #ok : CommonTypes.PagedResult<UserHandler.User>;
    };

    public type GetUserStatsResult = Result.Result<UserHandler.UserStats, ()>;

    public type GetTownOwnersRequest = {
        #town : Nat;
        #all;
    };

    public type GetTownOwnersResult = {
        #ok : [UserHandler.UserVotingInfo];
    };

    public type AssignUserToTownRequest = {
        userId : Principal;
        townId : Nat;
    };

    public type AssignUserToTownError = {
        #townNotFound;
        #notAuthorized;
        #notLeagueMember;
    };

    public type GetUserError = {
        #notFound;
        #notAuthorized;
    };

    public type GetUserResult = Result.Result<UserHandler.User, GetUserError>;
};
