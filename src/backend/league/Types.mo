import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Player "../models/Player";
import Team "../models/Team";
import Season "../models/Season";
import Scenario "../models/Scenario";
import Dao "../Dao";
import CommonTypes "../Types";
import Components "mo:datetime/Components";
import Result "mo:base/Result";

module {
    public type LeagueActor = actor {
        getSeasonStatus : query () -> async Season.SeasonStatus;
        getTeamStandings : query () -> async GetTeamStandingsResult;
        startSeason : (request : StartSeasonRequest) -> async StartSeasonResult;
        closeSeason : () -> async CloseSeasonResult;
        createTeam : (request : CreateTeamRequest) -> async CreateTeamResult;
        predictMatchOutcome : (request : PredictMatchOutcomeRequest) -> async PredictMatchOutcomeResult;
        getMatchGroupPredictions : query (matchGroupId : Nat) -> async GetMatchGroupPredictionsResult;
        startMatchGroup : (id : Nat) -> async StartMatchGroupResult;
        onMatchGroupComplete : (request : OnMatchGroupCompleteRequest) -> async OnMatchGroupCompleteResult;

        createProposal : (request : CreateProposalRequest) -> async CreateProposalResult;
        getProposal : query (Nat) -> async GetProposalResult;
        getProposals : query (count : Nat, offset : Nat) -> async GetProposalsResult;
        getScenario : query (Nat) -> async GetScenarioResult;
        getScenarios : query () -> async GetScenariosResult;
        voteOnProposal : VoteOnProposalRequest -> async VoteOnProposalResult;

        getScenarioVote : query (request : GetScenarioVoteRequest) -> async GetScenarioVoteResult;
        voteOnScenario : (request : VoteOnScenarioRequest) -> async VoteOnScenarioResult;

        claimBenevolentDictatorRole : () -> async ClaimBenevolentDictatorRoleResult;
        setBenevolentDictatorState : (state : BenevolentDictatorState) -> async SetBenevolentDictatorStateResult;
        getBenevolentDictatorState : query () -> async BenevolentDictatorState;
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

    public type ScenarioVote = {
        value : ?ScenarioOptionValue;
        votingPower : Nat;
        teamId : Nat;
        teamVotingPower : Nat;
        teamOptions : ScenarioTeamOptions;
    };

    public type ScenarioTeamOptions = {
        #discrete : [ScenarioTeamOptionDiscrete];
        #nat : [ScenarioTeamOptionNat];
    };

    public type ScenarioTeamOptionDiscrete = {
        id : Nat;
        title : Text;
        description : Text;
        energyCost : Nat;
        currentVotingPower : Nat;
        traitRequirements : [Scenario.TraitRequirement];
    };

    public type ScenarioTeamOptionNat = {
        value : Nat;
        currentVotingPower : Nat;
    };

    public type ScenarioOptionValue = {
        #nat : Nat;
        #id : Nat;
    };

    public type GetScenarioVoteError = {
        #scenarioNotFound;
        #notEligible;
    };

    public type GetScenarioVoteResult = Result.Result<ScenarioVote, GetScenarioVoteError>;

    public type VoteOnScenarioRequest = {
        scenarioId : Nat;
        value : ScenarioOptionValue;
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

    public type ProposalContent = {
        #changeTeamName : {
            teamId : Nat;
            name : Text;
        };
        #changeTeamColor : {
            teamId : Nat;
            color : (Nat8, Nat8, Nat8);
        };
        #changeTeamLogo : {
            teamId : Nat;
            logoUrl : Text;
        };
        #changeTeamMotto : {
            teamId : Nat;
            motto : Text;
        };
        #changeTeamDescription : {
            teamId : Nat;
            description : Text;
        };
    };

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

    public type AddScenarioRequest = {
        startTime : ?Time.Time;
        endTime : Time.Time;
        title : Text;
        description : Text;
        undecidedEffect : Scenario.Effect;
        kind : ScenarioKindRequest;
    };

    public type ScenarioKindRequest = {
        #noLeagueEffect : NoLeagueEffectScenarioRequest;
        #threshold : ThresholdScenarioRequest;
        #leagueChoice : LeagueChoiceScenarioRequest;
        #lottery : Scenario.LotteryScenario;
        #proportionalBid : Scenario.ProportionalBidScenario;
    };

    public type ScenarioOptionDiscrete = {
        title : Text;
        description : Text;
        energyCost : Nat;
        traitRequirements : [Scenario.TraitRequirement];
        teamEffect : Scenario.Effect;
    };

    public type NoLeagueEffectScenarioRequest = {
        options : [ScenarioOptionDiscrete];
    };

    public type ThresholdScenarioRequest = {
        minAmount : Nat;
        success : {
            description : Text;
            effect : Scenario.Effect;
        };
        failure : {
            description : Text;
            effect : Scenario.Effect;
        };
        undecidedAmount : ThresholdValue;
        options : [ThresholdScenarioOptionRequest];
    };

    public type ThresholdScenarioOptionRequest = ScenarioOptionDiscrete and {
        value : ThresholdValue;
    };

    public type ThresholdValue = {
        #fixed : Int;
        #weightedChance : [{
            value : Int;
            weight : Nat;
            description : Text;
        }];
    };

    public type LeagueChoiceScenarioRequest = {
        options : [LeagueChoiceScenarioOptionRequest];
    };

    public type LeagueChoiceScenarioOptionRequest = ScenarioOptionDiscrete and {
        leagueEffect : Scenario.Effect;
    };

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
    public type OnMatchGroupCompleteError = {
        #seasonNotOpen;
        #matchGroupNotFound;
        #matchGroupNotInProgress;
        #seedGenerationError : Text;
        #notAuthorized;
    };

    public type OnMatchGroupCompleteResult = Result.Result<(), OnMatchGroupCompleteError>;

    public type CreateTeamRequest = {
        name : Text;
        logoUrl : Text;
        motto : Text;
        description : Text;
        color : (Nat8, Nat8, Nat8);
    };

    public type CreateTeamError = {
        #nameTaken;
        #teamsCallError : Text;
        #notAuthorized;
    };

    public type CreateTeamResult = Result.Result<Nat, CreateTeamError>;
};
