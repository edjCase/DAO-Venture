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
    public type Actor = actor {
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

        onLeagueCollapse : () -> async OnLeagueCollapseResult;

        addFluff : (request : CreatePlayerFluffRequest) -> async CreatePlayerFluffResult;
        getPlayer : query (id : Nat32) -> async GetPlayerResult;
        getPosition : query (teamId : Nat, position : FieldPosition.FieldPosition) -> async Result.Result<Player.Player, GetPositionError>;
        getTeamPlayers : query (teamId : Nat) -> async [Player.Player];
        getAllPlayers : query () -> async [Player.Player];
        populateTeamRoster : (teamId : Nat) -> async PopulateTeamRosterResult;
        applyEffects : (request : ApplyEffectsRequest) -> async ApplyEffectsResult;
        onSeasonEnd : () -> async OnSeasonEndResult;
        swapTeamPositions : (
            teamId : Nat,
            position1 : FieldPosition.FieldPosition,
            position2 : FieldPosition.FieldPosition,
        ) -> async SwapPlayerPositionsResult;
        addMatchStats : (matchGroupId : Nat, playerStats : [Player.PlayerMatchStatsWithId]) -> async AddMatchStatsResult;

        getMatchGroup : query (id : Nat) -> async ?MatchGroupWithId;
        tickMatchGroup : (id : Nat) -> async TickMatchGroupResult;
        finishMatchGroup : (id : Nat) -> async (); // TODO remove
        resetTickTimer : (matchGroupId : Nat) -> async ResetTickTimerResult;
        startMatchGroup : (request : StartMatchGroupRequest) -> async StartMatchGroupResult;
        cancelMatchGroup : (request : CancelMatchGroupRequest) -> async CancelMatchGroupResult;

        getEntropyThreshold : query () -> async Nat;
        getTeams : query () -> async [Team];
        createProposal : (teamId : Nat, request : CreateProposalRequest) -> async CreateProposalResult;
        getProposal : query (teamId : Nat, id : Nat) -> async GetProposalResult;
        getProposals : query (teamId : Nat, count : Nat, offset : Nat) -> async GetProposalsResult;
        voteOnProposal : (teamId : Nat, request : VoteOnProposalRequest) -> async VoteOnProposalResult;
        onMatchGroupComplete : (request : OnMatchGroupCompleteRequest) -> async Result.Result<(), OnMatchGroupCompleteError>;
        onSeasonEnd() : async OnSeasonEndResult;
        createTeam : (request : CreateTeamRequest) -> async CreateTeamResult;
        updateTeamEnergy : (teamId : Nat, delta : Int) -> async UpdateTeamEnergyResult;
        updateTeamEntropy : (teamId : Nat, delta : Int) -> async UpdateTeamEntropyResult;
        updateTeamMotto : (teamId : Nat, motto : Text) -> async UpdateTeamMottoResult;
        updateTeamDescription : (teamId : Nat, description : Text) -> async UpdateTeamDescriptionResult;
        updateTeamLogo : (teamId : Nat, logoUrl : Text) -> async UpdateTeamLogoResult;
        updateTeamColor : (teamId : Nat, color : (Nat8, Nat8, Nat8)) -> async UpdateTeamColorResult;
        updateTeamName : (teamId : Nat, name : Text) -> async UpdateTeamNameResult;
        createTeamTrait : (request : CreateTeamTraitRequest) -> async CreateTeamTraitResult;
        addTraitToTeam : (teamId : Nat, traitId : Text) -> async AddTraitToTeamResult;
        removeTraitFromTeam : (teamId : Nat, traitId : Text) -> async RemoveTraitFromTeamResult;

        get : query (userId : Principal) -> async GetUserResult;
        getStats : query () -> async GetStatsResult;
        getTeamOwners : query (request : GetTeamOwnersRequest) -> async GetTeamOwnersResult;
        getUserLeaderboard : query (request : GetUserLeaderboardRequest) -> async GetUserLeaderboardResult;
        setFavoriteTeam : (userId : Principal, teamId : Nat) -> async SetUserFavoriteTeamResult;
        addTeamOwner : (request : AddTeamOwnerRequest) -> async AddTeamOwnerResult;
        awardPoints : (awards : [AwardPointsRequest]) -> async AwardPointsResult;
        onSeasonEnd : () -> async OnSeasonEndResult;
    };

    public type OnLeagueCollapseResult = Result.Result<(), OnLeagueCollapseError>;

    public type OnLeagueCollapseError = {
        #notAuthorized;
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

    public type GetPositionError = {
        #teamNotFound;
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

    type FieldPosition = FieldPosition.FieldPosition;
    type Base = Base.Base;
    type PlayerId = Player.PlayerId;

    public type CancelMatchGroupRequest = {
        id : Nat;
    };

    public type CancelMatchGroupError = {
        #matchGroupNotFound;
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

    public type Team = {
        id : Nat;
        name : Text;
        logoUrl : Text;
        color : (Nat8, Nat8, Nat8);
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

    public type StartMatchGroupError = {
        #noMatchesSpecified;
    };

    public type StartMatchError = {
        #notEnoughPlayers : Team.TeamIdOrBoth;
    };

    public type StartMatchGroupResult = Result.Result<(), StartMatchGroupError>;

    public type RoundLog = {
        turns : [TurnLog];
    };

    public type TurnLog = {
        events : [Event];
    };

    public type HitLocation = FieldPosition.FieldPosition or {
        #stands;
    };

    public type Event = {
        #traitTrigger : {
            id : Trait.Trait;
            playerId : Player.PlayerId;
            description : Text;
        };
        #auraTrigger : {
            id : MatchAura.MatchAura;
            description : Text;
        };
        #pitch : {
            pitcherId : Player.PlayerId;
            roll : {
                value : Int;
                crit : Bool;
            };
        };
        #swing : {
            playerId : Player.PlayerId;
            roll : {
                value : Int;
                crit : Bool;
            };
            pitchRoll : {
                value : Int;
                crit : Bool;
            };
            outcome : {
                #foul;
                #strike;
                #hit : HitLocation;
            };
        };
        #catch_ : {
            playerId : Player.PlayerId;
            roll : {
                value : Int;
                crit : Bool;
            };
            difficulty : {
                value : Int;
                crit : Bool;
            };
        };
        #teamSwap : {
            offenseTeamId : Team.TeamId;
            atBatPlayerId : Player.PlayerId;
        };
        #injury : {
            playerId : Nat32;
        };
        #death : {
            playerId : Nat32;
        };
        #score : {
            teamId : Team.TeamId;
            amount : Int;
        };
        #newBatter : {
            playerId : Player.PlayerId;
        };
        #out : {
            playerId : Player.PlayerId;
            reason : OutReason;
        };
        #matchEnd : {
            reason : MatchEndReason;
        };
        #safeAtBase : {
            playerId : Player.PlayerId;
            base : Base.Base;
        };
        #throw_ : {
            from : Player.PlayerId;
            to : Player.PlayerId;
        };
        #hitByBall : {
            playerId : Player.PlayerId;
        };
    };

    public type MatchEndReason = {
        #noMoreRounds;
        #error : Text;
    };

    public type OutReason = {
        #ballCaught;
        #strikeout;
        #hitByBall;
    };

    public type MatchLog = {
        rounds : [RoundLog];
    };

    public type Match = {
        team1 : TeamState;
        team2 : TeamState;
        offenseTeamId : Team.TeamId;
        aura : MatchAura.MatchAura;
        players : [PlayerStateWithId];
        bases : BaseState;
        log : MatchLog;
        outs : Nat;
        strikes : Nat;
    };

    public type PlayerExpectedOnFieldError = {
        id : PlayerId;
        onOffense : Bool;
        description : Text;
    };

    public type BrokenStateError = {
        #playerNotFound : PlayerId;
        #playerExpectedOnField : PlayerExpectedOnFieldError;
    };

    public type TickResult = {
        match : Match;
        status : MatchStatus;
    };

    public type MatchStatus = {
        #inProgress;
        #completed : MatchStatusCompleted;
    };

    public type MatchStatusCompleted = {
        reason : MatchEndReason;
    };

    public type MatchGroup = {
        matches : [TickResult];
        tickTimerId : Nat;
        currentSeed : Nat32;
    };

    public type MatchGroupWithId = MatchGroup and {
        id : Nat;
    };

    public type ResetTickTimerError = {
        #matchGroupNotFound;
    };

    public type ResetTickTimerResult = Result.Result<(), ResetTickTimerError>;

    public type PlayerState = {
        name : Text;
        teamId : Team.TeamId;
        condition : Player.PlayerCondition;
        skills : Player.Skills;
        matchStats : Player.PlayerMatchStats;
    };

    public type PlayerStateWithId = PlayerState and {
        id : PlayerId;
    };

    public type BaseState = {
        atBat : PlayerId;
        firstBase : ?PlayerId;
        secondBase : ?PlayerId;
        thirdBase : ?PlayerId;
    };

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
        id : PlayerId;
        name : Text;
    };

    public type TeamState = Team and {
        score : Int;
        positions : FieldPosition.TeamPositions;
    };

    public type Team = Team.Team;

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

    public type OnMatchGroupCompleteRequest = {
        matchGroup : Season.CompletedMatchGroup;
    };

    public type OnMatchGroupCompleteError = {
        #notAuthorized;
    };

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

    public type Link = {
        name : Text;
        url : Text;
    };

    public type TeamLinks = {
        teamId : Nat;
        links : [Link];
    };

    public type GetProposalResult = Result.Result<Proposal, GetProposalError>;

    public type GetProposalError = {
        #proposalNotFound;
        #teamNotFound;
    };

    public type GetProposalsResult = Result.Result<CommonTypes.PagedResult<Proposal>, GetProposalsError>;

    public type GetProposalsError = {
        #teamNotFound;
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
        #teamNotFound;
    };

    public type Proposal = Dao.Proposal<ProposalContent>;

    public type ProposalContent = {
        #changeName : ChangeNameContent;
        #train : TrainContent;
        #swapPlayerPositions : SwapPlayerPositionsContent;
        #changeColor : ChangeColorContent;
        #changeLogo : ChangeLogoContent;
        #changeMotto : ChangeMottoContent;
        #changeDescription : ChangeDescriptionContent;
        #modifyLink : ModifyLinkContent;
    };

    public type ChangeNameContent = {
        name : Text;
    };

    public type TrainContent = {
        position : FieldPosition.FieldPosition;
        skill : Skill.Skill;
    };

    public type SwapPlayerPositionsContent = {
        position1 : FieldPosition.FieldPosition;
        position2 : FieldPosition.FieldPosition;
    };

    public type ChangeColorContent = {
        color : (Nat8, Nat8, Nat8);
    };

    public type ChangeLogoContent = {
        logoUrl : Text;
    };

    public type ChangeMottoContent = {
        motto : Text;
    };

    public type ChangeDescriptionContent = {
        description : Text;
    };

    public type ModifyLinkContent = {
        name : Text;
        url : ?Text;
    };

    public type CreateProposalRequest = {
        content : ProposalContent;
    };

    public type CreateProposalResult = Result.Result<Nat, CreateProposalError>;

    public type CreateProposalError = {
        #notAuthorized;
        #teamNotFound;
        #invalid : [Text];
    };

    public type OnSeasonEndResult = Result.Result<(), OnSeasonEndError>;

    public type OnSeasonEndError = {
        #notAuthorized;
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
        #ok : CommonTypes.PagedResult<User>;
    };

    public type GetStatsResult = Result.Result<UserStats, ()>;

    public type UserStats = {
        totalPoints : Int;
        userCount : Nat;
        teamOwnerCount : Nat;
        teams : [TeamStats];
    };

    public type TeamStats = {
        id : Nat;
        totalPoints : Int;
        userCount : Nat;
        ownerCount : Nat;
    };
    public type OnSeasonEndError = {
        #notAuthorized;
    };

    public type OnSeasonEndResult = Result.Result<(), OnSeasonEndError>;

    public type GetTeamOwnersRequest = {
        #team : Nat;
        #all;
    };

    public type GetTeamOwnersError = {};

    public type GetTeamOwnersResult = {
        #ok : [UserVotingInfo];
    };

    public type TeamAssociationKind = {
        #fan;
        #owner : {
            votingPower : Nat;
        };
    };

    public type User = {
        // TODO team association be in the season?
        id : Principal;
        team : ?{
            id : Nat;
            kind : TeamAssociationKind;
        };
        points : Int;
    };

    public type UserVotingInfo = {
        id : Principal;
        teamId : Nat;
        votingPower : Nat;
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

    public type GetUserResult = Result.Result<User, GetUserError>;

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
