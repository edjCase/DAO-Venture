import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Player "../models/Player";
import Team "../models/Team";
import Season "../models/Season";
import Scenario "../models/Scenario";
import Dao "../Dao";
import CommonTypes "../CommonTypes";
import Components "mo:datetime/Components";
import Result "mo:base/Result";
import FieldPosition "../models/FieldPosition";
import LiveState "../models/LiveState";
import ScenarioHandler "../handlers/ScenarioHandler";
import UserHandler "../handlers/UserHandler";
import TeamDao "../models/TeamDao";
import LeagueDao "../models/LeagueDao";

module {
    public type Actor = actor {
        getSeasonStatus : query () -> async Season.SeasonStatus;
        getTeamStandings : query () -> async GetTeamStandingsResult;
        startSeason : (request : StartSeasonRequest) -> async StartSeasonResult;
        closeSeason : () -> async CloseSeasonResult;
        createTeam : (request : CreateTeamRequest) -> async CreateTeamResult;
        predictMatchOutcome : (request : PredictMatchOutcomeRequest) -> async PredictMatchOutcomeResult;
        getMatchGroupPredictions : query (matchGroupId : Nat) -> async GetMatchGroupPredictionsResult;

        getLeagueProposal : query (Nat) -> async GetLeagueProposalResult;
        getLeagueProposals : query (count : Nat, offset : Nat) -> async GetLeagueProposalsResult;
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
        getPosition : query (teamId : Nat, position : FieldPosition.FieldPosition) -> async Result.Result<Player.Player, GetPositionError>;
        getTeamPlayers : query (teamId : Nat) -> async [Player.Player];
        getAllPlayers : query () -> async [Player.Player];

        getLiveMatchGroupState : query () -> async ?LiveState.LiveMatchGroupState;
        startNextMatchGroup : () -> async StartMatchGroupResult;

        getLeagueData : query () -> async LeagueData;
        getTeams : query () -> async [Team];
        createTeamProposal : (teamId : Nat, request : TeamProposalContent) -> async CreateTeamProposalResult;
        getTeamProposal : query (teamId : Nat, id : Nat) -> async GetTeamProposalResult;
        getTeamProposals : query (teamId : Nat, count : Nat, offset : Nat) -> async GetTeamProposalsResult;
        voteOnTeamProposal : (teamId : Nat, request : VoteOnTeamProposalRequest) -> async VoteOnTeamProposalResult;
        createTeamTrait : (request : CreateTeamTraitRequest) -> async CreateTeamTraitResult;

        getUser : query (userId : Principal) -> async GetUserResult;
        getUserStats : query () -> async GetUserStatsResult;
        getTeamOwners : query (request : GetTeamOwnersRequest) -> async GetTeamOwnersResult;
        getUserLeaderboard : query (request : GetUserLeaderboardRequest) -> async GetUserLeaderboardResult;
        setFavoriteTeam : (userId : Principal, teamId : Nat) -> async SetUserFavoriteTeamResult;
        addTeamOwner : (request : AddTeamOwnerRequest) -> async AddTeamOwnerResult;
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

    public type Team = {
        id : Nat;
        name : Text;
        logoUrl : Text;
        color : (Nat8, Nat8, Nat8);
    };

    public type GetPositionError = {
        #teamNotFound;
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

    public type LeagueProposal = Dao.Proposal<LeagueDao.ProposalContent>;

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

    public type TeamStandingInfo = {
        id : Nat;
        wins : Nat;
        losses : Nat;
        totalScore : Int;
    };

    public type GetTeamStandingsError = {
        #notFound;
    };

    public type GetTeamStandingsResult = Result.Result<[TeamStandingInfo], GetTeamStandingsError>;

    public type GetMatchGroupPredictionsError = {
        #notFound;
    };

    public type GetMatchGroupPredictionsResult = Result.Result<MatchGroupPredictionSummary, GetMatchGroupPredictionsError>;

    public type MatchGroupPredictionSummary = {
        matches : [MatchPredictionSummary];
    };

    public type MatchPredictionSummary = {
        team1 : Nat;
        team2 : Nat;
        yourVote : ?Team.TeamId;
    };

    public type PredictMatchOutcomeRequest = {
        matchId : Nat;
        winner : ?Team.TeamId;
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
        #notEnoughPlayers : Team.TeamIdOrBoth;
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

    public type CreateTeamTraitRequest = {
        id : Text;
        name : Text;
        description : Text;
    };

    public type CreateTeamTraitError = {
        #notAuthorized;
        #idTaken;
        #invalid : [Text];
    };

    public type CreateTeamTraitResult = Result.Result<(), CreateTeamTraitError>;

    public type TeamProposal = Dao.Proposal<TeamDao.ProposalContent>;

    public type GetTeamProposalResult = Result.Result<TeamProposal, GetTeamProposalError>;

    public type GetTeamProposalError = {
        #proposalNotFound;
        #teamNotFound;
    };

    public type GetTeamProposalsResult = Result.Result<CommonTypes.PagedResult<Dao.Proposal<TeamDao.ProposalContent>>, GetTeamProposalsError>;

    public type GetTeamProposalsError = {
        #teamNotFound;
    };

    public type VoteOnTeamProposalRequest = {
        proposalId : Nat;
        vote : Bool;
    };

    public type VoteOnTeamProposalResult = Result.Result<(), VoteOnTeamProposalError>;

    public type VoteOnTeamProposalError = {
        #notAuthorized;
        #proposalNotFound;
        #alreadyVoted;
        #votingClosed;
        #teamNotFound;
    };

    public type TeamProposalContent = TeamDao.ProposalContent;

    public type CreateTeamProposalResult = Result.Result<Nat, CreateTeamProposalError>;

    public type CreateTeamProposalError = {
        #notAuthorized;
        #teamNotFound;
        #invalid : [Text];
    };

    public type CreateTeamRequest = {
        name : Text;
        logoUrl : Text;
        motto : Text;
        description : Text;
        color : (Nat8, Nat8, Nat8);
        entropy : Nat;
        energy : Nat;
    };

    public type CreateTeamResult = Result.Result<Nat, CreateTeamError>;

    public type CreateTeamError = {
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

    public type GetTeamOwnersRequest = {
        #team : Nat;
        #all;
    };

    public type GetTeamOwnersResult = {
        #ok : [UserHandler.UserVotingInfo];
    };

    public type AddTeamOwnerRequest = {
        userId : Principal;
        teamId : Nat;
        votingPower : Nat;
    };

    public type AddTeamOwnerError = {
        #onOtherTeam : Nat;
        #teamNotFound;
        #alreadyOwner;
        #notAuthorized;
    };

    public type AddTeamOwnerResult = Result.Result<(), AddTeamOwnerError>;

    public type GetUserError = {
        #notFound;
        #notAuthorized;
    };

    public type GetUserResult = Result.Result<UserHandler.User, GetUserError>;

    public type SetUserFavoriteTeamError = {
        #identityRequired;
        #teamNotFound;
        #notAuthorized;
        #alreadySet;
    };

    public type SetUserFavoriteTeamResult = Result.Result<(), SetUserFavoriteTeamError>;
};
