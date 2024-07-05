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
import MatchAura "../models/MatchAura";
import LiveState "../models/LiveState";
import ScenarioHandler "../handlers/ScenarioHandler";
import UserHandler "../handlers/UserHandler";

module {
    public type Actor = actor {
        getSeasonStatus : query () -> async Season.SeasonStatus;
        getTeamStandings : query () -> async GetTeamStandingsResult;
        startSeason : (request : StartSeasonRequest) -> async StartSeasonResult;
        closeSeason : () -> async CloseSeasonResult;
        createTeam : (request : CreateTeamRequest) -> async CreateTeamResult;
        predictMatchOutcome : (request : PredictMatchOutcomeRequest) -> async PredictMatchOutcomeResult;
        getMatchGroupPredictions : query (matchGroupId : Nat) -> async GetMatchGroupPredictionsResult;

        createProposal : (request : CreateProposalRequest) -> async CreateProposalResult;
        getProposal : query (Nat) -> async GetProposalResult;
        getProposals : query (count : Nat, offset : Nat) -> async GetProposalsResult;
        getScenario : query (Nat) -> async GetScenarioResult;
        getScenarios : query () -> async GetScenariosResult;
        voteOnProposal : VoteOnProposalRequest -> async VoteOnProposalResult;
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

        getLiveMatchGroupState : query (matchGroupId : Nat) -> async Result.Result<LiveState.LiveMatchGroupState, GetLiveMatchGroupStateError>;
        finishMatchGroup : (id : Nat) -> async FinishMatchGroupResult; // TODO remove
        startMatchGroup : (matchGroupId : Nat) -> async StartMatchGroupResult;
        cancelMatchGroup : (request : CancelMatchGroupRequest) -> async CancelMatchGroupResult;

        getEntropyThreshold : query () -> async Nat;
        getTeams : query () -> async [Team];
        createTeamProposal : (teamId : Nat, request : CreateTeamProposalRequest) -> async CreateProposalResult;
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

    public type FinishMatchGroupResult = Result.Result<(), FinishMatchGroupError>;

    public type FinishMatchGroupError = {
        #notAuthorized;
        #matchGroupNotFound;
    };

    public type GetLiveMatchGroupStateError = {
        #matchGroupNotFound;
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

    public type AddScenarioCustomTeamOptionRequest = {
        scenarioId : Nat;
        value : { #nat : Nat };
    };

    public type AddScenarioCustomTeamOptionError = {
        #scenarioNotFound;
        #invalidValueType;
        #customOptionNotAllowed;
        #duplicate;
        #notAuthorized;
    };

    public type GetScenarioVoteRequest = {
        scenarioId : Nat;
    };

    public type GetScenarioVoteError = {
        #scenarioNotFound;
        #notEligible;
    };

    public type GetScenarioVoteResult = Result.Result<ScenarioHandler.ScenarioVote, GetScenarioVoteError>;

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

    public type GetProposalError = {
        #proposalNotFound;
    };

    public type GetProposalResult = Result.Result<Proposal, GetProposalError>;

    public type GetProposalsResult = {
        #ok : CommonTypes.PagedResult<Proposal>;
    };

    public type Proposal = Dao.Proposal<ProposalContent>;

    public type ProposalContent = {};

    public type VoteOnProposalRequest = {
        proposalId : Nat;
        vote : Bool;
    };

    public type VoteOnProposalResult = Result.Result<(), VoteOnProposalError>;

    public type VoteOnProposalError = {
        #notAuthorized;
        #proposalNotFound;
        #alreadyVoted;
        #votingClosed;
    };

    public type CreateProposalRequest = {
        content : ProposalContent;
    };

    public type CreateProposalResult = Result.Result<Nat, CreateProposalError>;

    public type CreateProposalError = {
        #notAuthorized;
        #invalid : [Text];
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

    public type ProcessEffectOutcomesRequest = {
        outcomes : [Scenario.EffectOutcome];
    };

    public type ProcessEffectOutcomesError = {
        #notAuthorized;
        #seasonNotInProgress;
    };

    public type ProcessEffectOutcomesResult = Result.Result<(), ProcessEffectOutcomesError>;

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

    // Start season
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

    // On complete

    public type OnMatchGroupCompleteRequest = {
        id : Nat;
        matches : [Season.CompletedMatch];
        playerStats : [Player.PlayerMatchStatsWithId];
    };

    public type FailedMatchResult = {
        message : Text;
    };

    public type AddMatchStatsError = {
        #notAuthorized;
    };

    public type AddMatchStatsResult = Result.Result<(), AddMatchStatsError>;

    public type SwapPlayerPositionsError = {
        #notAuthorized;
    };

    public type SwapPlayerPositionsResult = Result.Result<(), SwapPlayerPositionsError>;

    public type OnSeasonEndError = {
        #notAuthorized;
    };

    public type OnSeasonEndResult = Result.Result<(), OnSeasonEndError>;

    public type ApplyEffectsRequest = [Scenario.PlayerEffectOutcome];

    public type ApplyEffectsError = {
        #notAuthorized;
    };

    public type ApplyEffectsResult = Result.Result<(), ApplyEffectsError>;

    public type PopulateTeamRosterError = {
        #missingFluff;
        #notAuthorized;
    };

    public type PopulateTeamRosterResult = Result.Result<[Player.Player], PopulateTeamRosterError>;

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

    public type SetPlayerTeamError = {
        #playerNotFound;
    };

    public type SetPlayerTeamResult = Result.Result<(), SetPlayerTeamError>;

    public type CancelMatchGroupRequest = {
        id : Nat;
    };

    public type CancelMatchGroupError = {
        #matchGroupNotFound;
        #notAuthorized;
    };

    public type CancelMatchGroupResult = Result.Result<(), CancelMatchGroupError>;

    public type StadiumActorInfo = {};

    public type StadiumActorInfoWithId = StadiumActorInfo and {
        id : Principal;
    };

    public type CreateStadiumError = {
        #stadiumCreationError : Text;
    };

    public type CreateStadiumResult = Result.Result<Principal, CreateStadiumError>;

    public type StartMatchGroupRequest = {
        id : Nat;
        matches : [StartMatchRequest];
    };

    public type StartMatchTeam = Team and {
        positions : {
            firstBase : Player.Player;
            secondBase : Player.Player;
            thirdBase : Player.Player;
            shortStop : Player.Player;
            pitcher : Player.Player;
            leftField : Player.Player;
            centerField : Player.Player;
            rightField : Player.Player;
        };
    };

    public type StartMatchRequest = {
        team1 : StartMatchTeam;
        team2 : StartMatchTeam;
        aura : MatchAura.MatchAura;
    };

    public type ResetTickTimerError = {
        #matchGroupNotFound;
    };

    public type ResetTickTimerResult = Result.Result<(), ResetTickTimerError>;

    public type TickMatchGroupResult = Result.Result<{ #inProgress; #completed }, TickMatchGroupError>;

    public type TickMatchGroupError = {
        #matchGroupNotFound;
        #onStartCallbackError : {
            #unknown : Text;
            #notScheduledYet;
            #alreadyStarted;
            #notAuthorized;
            #matchGroupNotFound;
        };
        #notAuthorized;
    };

    public type Player = {
        id : Player.PlayerId;
        name : Text;
    };

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

    public type AddTraitToTeamOk = {
        hadTrait : Bool;
    };

    public type AddTraitToTeamError = {
        #notAuthorized;
        #teamNotFound;
        #traitNotFound;
    };

    public type AddTraitToTeamResult = Result.Result<AddTraitToTeamOk, AddTraitToTeamError>;

    public type RemoveTraitFromTeamOk = {
        hadTrait : Bool;
    };

    public type RemoveTraitFromTeamError = {
        #notAuthorized;
        #teamNotFound;
        #traitNotFound;
    };

    public type RemoveTraitFromTeamResult = Result.Result<RemoveTraitFromTeamOk, RemoveTraitFromTeamError>;

    public type UpdateTeamEnergyResult = Result.Result<(), UpdateTeamEnergyError>;

    public type UpdateTeamEnergyError = {
        #notAuthorized;
        #teamNotFound;
    };

    public type UpdateTeamEntropyResult = Result.Result<(), UpdateTeamEntropyError>;

    public type UpdateTeamEntropyError = {
        #notAuthorized;
        #teamNotFound;
    };

    public type UpdateTeamMottoResult = Result.Result<(), UpdateTeamMottoError>;

    public type UpdateTeamMottoError = {
        #notAuthorized;
        #teamNotFound;
    };

    public type UpdateTeamDescriptionResult = Result.Result<(), UpdateTeamDescriptionError>;

    public type UpdateTeamDescriptionError = {
        #notAuthorized;
        #teamNotFound;
    };

    public type UpdateTeamLogoResult = Result.Result<(), UpdateTeamLogoError>;

    public type UpdateTeamLogoError = {
        #notAuthorized;
        #teamNotFound;
    };

    public type UpdateTeamColorResult = Result.Result<(), UpdateTeamColorError>;

    public type UpdateTeamColorError = {
        #notAuthorized;
        #teamNotFound;
    };

    public type UpdateTeamNameResult = Result.Result<(), UpdateTeamNameError>;

    public type UpdateTeamNameError = {
        #nameTaken;
        #notAuthorized;
        #teamNotFound;
    };

    public type GetTeamProposalResult = Result.Result<Proposal, GetTeamProposalError>;

    public type GetTeamProposalError = {
        #proposalNotFound;
        #teamNotFound;
    };

    public type GetTeamProposalsResult = Result.Result<CommonTypes.PagedResult<Proposal>, GetTeamProposalsError>;

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

    public type CreateTeamProposalRequest = {
        content : ProposalContent;
    };

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
    };

    public type CreateTeamResult = Result.Result<Nat, CreateTeamError>;

    public type CreateTeamError = {
        #nameTaken;
        #notAuthorized;
    };

    public type MatchVoteResult = {
        votes : [Nat];
    };

    public type GetCyclesResult = Result.Result<Nat, GetCyclesError>;

    public type GetCyclesError = {
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

    public type GetTeamOwnersError = {};

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
        #notAuthorized;
    };

    public type AddTeamOwnerResult = Result.Result<(), AddTeamOwnerError>;

    public type GetUserError = {
        #notFound;
        #notAuthorized;
    };

    public type GetUserResult = Result.Result<UserHandler.User, GetUserError>;

    public type AwardPointsRequest = {
        userId : Principal;
        points : Int;
    };

    public type AwardPointsError = {
        #notAuthorized;
    };

    public type AwardPointsResult = Result.Result<(), AwardPointsError>;

    public type SetUserFavoriteTeamError = {
        #identityRequired;
        #teamNotFound;
        #notAuthorized;
        #alreadySet;
    };

    public type SetUserFavoriteTeamResult = Result.Result<(), SetUserFavoriteTeamError>;
};
