import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export type AddScenarioError = { 'notAuthorized' : null } |
  { 'invalid' : Array<string> };
export interface AddScenarioRequest {
  'startTime' : [] | [Time],
  'title' : string,
  'endTime' : Time,
  'kind' : ScenarioKindRequest,
  'description' : string,
  'undecidedEffect' : Effect,
}
export type AddScenarioResult = { 'ok' : null } |
  { 'err' : AddScenarioError };
export type AddTeamOwnerError = { 'notAuthorized' : null } |
  { 'alreadyOwner' : null } |
  { 'onOtherTeam' : bigint } |
  { 'teamNotFound' : null };
export interface AddTeamOwnerRequest {
  'votingPower' : bigint,
  'userId' : Principal,
  'teamId' : bigint,
}
export type AddTeamOwnerResult = { 'ok' : null } |
  { 'err' : AddTeamOwnerError };
export type Base = { 'homeBase' : null } |
  { 'thirdBase' : null } |
  { 'secondBase' : null } |
  { 'firstBase' : null };
export type BenevolentDictatorState = { 'open' : null } |
  { 'claimed' : Principal } |
  { 'disabled' : null };
export interface ChangeTeamColorContent { 'color' : [number, number, number] }
export interface ChangeTeamDescriptionContent { 'description' : string }
export interface ChangeTeamLogoContent { 'logoUrl' : string }
export interface ChangeTeamMottoContent { 'motto' : string }
export interface ChangeTeamNameContent { 'name' : string }
export type ChosenOrRandomFieldPosition = { 'random' : null } |
  { 'chosen' : FieldPosition };
export type ChosenOrRandomSkill = { 'random' : null } |
  { 'chosen' : Skill };
export type ClaimBenevolentDictatorRoleError = { 'notOpenToClaim' : null } |
  { 'notAuthenticated' : null };
export type ClaimBenevolentDictatorRoleResult = { 'ok' : null } |
  { 'err' : ClaimBenevolentDictatorRoleError };
export type CloseSeasonError = { 'notAuthorized' : null } |
  { 'seasonNotOpen' : null };
export type CloseSeasonResult = { 'ok' : null } |
  { 'err' : CloseSeasonError };
export interface CompletedMatch {
  'team1' : CompletedMatchTeam,
  'team2' : CompletedMatchTeam,
  'aura' : MatchAura,
  'winner' : TeamIdOrTie,
}
export interface CompletedMatchGroup {
  'time' : Time,
  'matches' : Array<CompletedMatch>,
}
export interface CompletedMatchTeam { 'id' : bigint, 'score' : bigint }
export interface CompletedSeason {
  'teams' : Array<CompletedSeasonTeam>,
  'runnerUpTeamId' : bigint,
  'matchGroups' : Array<CompletedMatchGroup>,
  'championTeamId' : bigint,
}
export interface CompletedSeasonTeam {
  'id' : bigint,
  'name' : string,
  'color' : [number, number, number],
  'wins' : bigint,
  'losses' : bigint,
  'totalScore' : bigint,
  'logoUrl' : string,
  'positions' : TeamPositions,
}
export type CreatePlayerFluffError = { 'notAuthorized' : null } |
  { 'invalid' : Array<InvalidError> };
export interface CreatePlayerFluffRequest {
  'title' : string,
  'name' : string,
  'description' : string,
  'likes' : Array<string>,
  'quirks' : Array<string>,
  'dislikes' : Array<string>,
}
export type CreatePlayerFluffResult = { 'ok' : null } |
  { 'err' : CreatePlayerFluffError };
export type CreateTeamError = { 'nameTaken' : null } |
  { 'notAuthorized' : null };
export type CreateTeamProposalError = { 'notAuthorized' : null } |
  { 'invalid' : Array<string> } |
  { 'teamNotFound' : null };
export type CreateTeamProposalResult = { 'ok' : bigint } |
  { 'err' : CreateTeamProposalError };
export interface CreateTeamRequest {
  'motto' : string,
  'name' : string,
  'color' : [number, number, number],
  'description' : string,
  'logoUrl' : string,
}
export type CreateTeamResult = { 'ok' : bigint } |
  { 'err' : CreateTeamError };
export type CreateTeamTraitError = { 'notAuthorized' : null } |
  { 'invalid' : Array<string> } |
  { 'idTaken' : null };
export interface CreateTeamTraitRequest {
  'id' : string,
  'name' : string,
  'description' : string,
}
export type CreateTeamTraitResult = { 'ok' : null } |
  { 'err' : CreateTeamTraitError };
export type DayOfWeek = { 'tuesday' : null } |
  { 'wednesday' : null } |
  { 'saturday' : null } |
  { 'thursday' : null } |
  { 'sunday' : null } |
  { 'friday' : null } |
  { 'monday' : null };
export type Duration = { 'matches' : bigint } |
  { 'indefinite' : null };
export type Effect = { 'allOf' : Array<Effect> } |
  { 'teamTrait' : TeamTraitEffect } |
  { 'noEffect' : null } |
  { 'oneOf' : Array<WeightedEffect> } |
  { 'entropy' : EntropyEffect } |
  { 'skill' : SkillEffect } |
  { 'injury' : InjuryEffect } |
  { 'energy' : EnergyEffect };
export type EffectOutcome = { 'teamTrait' : TeamTraitTeamEffectOutcome } |
  { 'entropy' : EntropyTeamEffectOutcome } |
  { 'skill' : SkillPlayerEffectOutcome } |
  { 'injury' : InjuryPlayerEffectOutcome } |
  { 'energy' : EnergyTeamEffectOutcome };
export interface EnergyEffect {
  'value' : { 'flat' : bigint },
  'target' : TargetTeam,
}
export interface EnergyTeamEffectOutcome { 'teamId' : bigint, 'delta' : bigint }
export interface EntropyEffect { 'target' : TargetTeam, 'delta' : bigint }
export interface EntropyTeamEffectOutcome {
  'teamId' : bigint,
  'delta' : bigint,
}
export type FieldPosition = { 'rightField' : null } |
  { 'leftField' : null } |
  { 'thirdBase' : null } |
  { 'pitcher' : null } |
  { 'secondBase' : null } |
  { 'shortStop' : null } |
  { 'centerField' : null } |
  { 'firstBase' : null };
export type FinishMatchGroupError = { 'notAuthorized' : null } |
  { 'noLiveMatchGroup' : null };
export type FinishMatchGroupResult = { 'ok' : null } |
  { 'err' : FinishMatchGroupError };
export type GetLeagueProposalError = { 'proposalNotFound' : null };
export type GetLeagueProposalResult = { 'ok' : LeagueProposal } |
  { 'err' : GetLeagueProposalError };
export type GetLeagueProposalsResult = { 'ok' : PagedResult_2 };
export type GetMatchGroupPredictionsError = { 'notFound' : null };
export type GetMatchGroupPredictionsResult = {
    'ok' : MatchGroupPredictionSummary
  } |
  { 'err' : GetMatchGroupPredictionsError };
export type GetPlayerError = { 'notFound' : null };
export type GetPlayerResult = { 'ok' : Player } |
  { 'err' : GetPlayerError };
export type GetPositionError = { 'teamNotFound' : null };
export type GetScenarioError = { 'notStarted' : null } |
  { 'notFound' : null };
export type GetScenarioResult = { 'ok' : Scenario } |
  { 'err' : GetScenarioError };
export type GetScenarioVoteError = { 'notEligible' : null } |
  { 'scenarioNotFound' : null };
export interface GetScenarioVoteRequest { 'scenarioId' : bigint }
export type GetScenarioVoteResult = { 'ok' : ScenarioVote } |
  { 'err' : GetScenarioVoteError };
export type GetScenariosResult = { 'ok' : Array<Scenario> };
export type GetTeamOwnersRequest = { 'all' : null } |
  { 'team' : bigint };
export type GetTeamOwnersResult = { 'ok' : Array<UserVotingInfo> };
export type GetTeamProposalError = { 'proposalNotFound' : null } |
  { 'teamNotFound' : null };
export type GetTeamProposalResult = { 'ok' : TeamProposal } |
  { 'err' : GetTeamProposalError };
export type GetTeamProposalsError = { 'teamNotFound' : null };
export type GetTeamProposalsResult = { 'ok' : PagedResult_1 } |
  { 'err' : GetTeamProposalsError };
export type GetTeamStandingsError = { 'notFound' : null };
export type GetTeamStandingsResult = { 'ok' : Array<TeamStandingInfo> } |
  { 'err' : GetTeamStandingsError };
export type GetUserError = { 'notAuthorized' : null } |
  { 'notFound' : null };
export interface GetUserLeaderboardRequest {
  'count' : bigint,
  'offset' : bigint,
}
export type GetUserLeaderboardResult = { 'ok' : PagedResult };
export type GetUserResult = { 'ok' : User } |
  { 'err' : GetUserError };
export type GetUserStatsResult = { 'ok' : UserStats } |
  { 'err' : null };
export type HitLocation = { 'rightField' : null } |
  { 'stands' : null } |
  { 'leftField' : null } |
  { 'thirdBase' : null } |
  { 'pitcher' : null } |
  { 'secondBase' : null } |
  { 'shortStop' : null } |
  { 'centerField' : null } |
  { 'firstBase' : null };
export interface InProgressMatch {
  'team1' : InProgressTeam,
  'team2' : InProgressTeam,
  'aura' : MatchAura,
}
export interface InProgressMatchGroup {
  'time' : Time,
  'matches' : Array<InProgressMatch>,
}
export interface InProgressSeason {
  'teams' : Array<TeamInfo>,
  'players' : Array<Player>,
  'matchGroups' : Array<InProgressSeasonMatchGroupVariant>,
}
export type InProgressSeasonMatchGroupVariant = {
    'scheduled' : ScheduledMatchGroup
  } |
  { 'completed' : CompletedMatchGroup } |
  { 'inProgress' : InProgressMatchGroup } |
  { 'notScheduled' : NotScheduledMatchGroup };
export interface InProgressTeam { 'id' : bigint }
export interface InjuryEffect { 'target' : TargetPosition }
export interface InjuryPlayerEffectOutcome { 'target' : TargetPositionInstance }
export type InvalidError = { 'nameTaken' : null } |
  { 'nameNotSpecified' : null };
export interface LeagueChoiceScenario {
  'options' : Array<LeagueChoiceScenarioOption>,
}
export interface LeagueChoiceScenarioOption {
  'title' : string,
  'teamEffect' : Effect,
  'description' : string,
  'leagueEffect' : Effect,
  'traitRequirements' : Array<TraitRequirement>,
  'energyCost' : bigint,
  'allowedTeamIds' : Array<bigint>,
}
export interface LeagueChoiceScenarioOptionRequest {
  'title' : string,
  'teamEffect' : Effect,
  'description' : string,
  'leagueEffect' : Effect,
  'traitRequirements' : Array<TraitRequirement>,
  'energyCost' : bigint,
}
export interface LeagueChoiceScenarioOutcome { 'optionId' : [] | [bigint] }
export interface LeagueChoiceScenarioRequest {
  'options' : Array<LeagueChoiceScenarioOptionRequest>,
}
export interface LeagueProposal {
  'id' : bigint,
  'content' : ProposalContent__1,
  'timeStart' : bigint,
  'votes' : Array<[Principal, Vote]>,
  'statusLog' : Array<ProposalStatusLogEntry>,
  'endTimerId' : [] | [bigint],
  'timeEnd' : bigint,
  'proposerId' : Principal,
}
export interface Link { 'url' : string, 'name' : string }
export interface LiveBaseState {
  'atBat' : PlayerId,
  'thirdBase' : [] | [PlayerId],
  'secondBase' : [] | [PlayerId],
  'firstBase' : [] | [PlayerId],
}
export interface LiveMatchGroupState {
  'id' : bigint,
  'tickTimerId' : bigint,
  'currentSeed' : number,
  'matches' : Array<LiveMatchStateWithStatus>,
}
export interface LiveMatchStateWithStatus {
  'log' : MatchLog,
  'status' : LiveMatchStatus,
  'team1' : LiveMatchTeam,
  'team2' : LiveMatchTeam,
  'aura' : MatchAura,
  'outs' : bigint,
  'offenseTeamId' : TeamId,
  'players' : Array<LivePlayerState>,
  'bases' : LiveBaseState,
  'strikes' : bigint,
}
export type LiveMatchStatus = { 'completed' : LiveMatchStatusCompleted } |
  { 'inProgress' : null };
export interface LiveMatchStatusCompleted { 'reason' : MatchEndReason }
export interface LiveMatchTeam {
  'id' : bigint,
  'name' : string,
  'color' : [number, number, number],
  'score' : bigint,
  'logoUrl' : string,
  'positions' : TeamPositions,
}
export interface LivePlayerState {
  'id' : PlayerId,
  'name' : string,
  'matchStats' : PlayerMatchStats,
  'teamId' : TeamId,
  'skills' : Skills,
  'condition' : PlayerCondition,
}
export interface LotteryPrize { 'description' : string, 'effect' : Effect }
export interface LotteryScenario { 'minBid' : bigint, 'prize' : LotteryPrize }
export interface LotteryScenarioOutcome { 'winningTeamId' : [] | [bigint] }
export type MatchAura = { 'foggy' : null } |
  { 'moveBasesIn' : null } |
  { 'extraStrike' : null } |
  { 'moreBlessingsAndCurses' : null } |
  { 'fastBallsHardHits' : null } |
  { 'explodingBalls' : null } |
  { 'lowGravity' : null } |
  { 'doubleOrNothing' : null } |
  { 'windy' : null } |
  { 'rainy' : null };
export interface MatchAuraWithMetaData {
  'aura' : MatchAura,
  'name' : string,
  'description' : string,
}
export type MatchEndReason = { 'noMoreRounds' : null } |
  { 'error' : string };
export type MatchEvent = {
    'out' : { 'playerId' : PlayerId, 'reason' : OutReason }
  } |
  { 'throw' : { 'to' : PlayerId, 'from' : PlayerId } } |
  { 'newBatter' : { 'playerId' : PlayerId } } |
  { 'teamSwap' : { 'atBatPlayerId' : PlayerId, 'offenseTeamId' : TeamId } } |
  { 'hitByBall' : { 'playerId' : PlayerId } } |
  {
    'catch' : {
      'difficulty' : { 'value' : bigint, 'crit' : boolean },
      'playerId' : PlayerId,
      'roll' : { 'value' : bigint, 'crit' : boolean },
    }
  } |
  { 'auraTrigger' : { 'id' : MatchAura, 'description' : string } } |
  {
    'traitTrigger' : {
      'id' : Trait,
      'playerId' : PlayerId,
      'description' : string,
    }
  } |
  { 'safeAtBase' : { 'base' : Base, 'playerId' : PlayerId } } |
  { 'score' : { 'teamId' : TeamId, 'amount' : bigint } } |
  {
    'swing' : {
      'pitchRoll' : { 'value' : bigint, 'crit' : boolean },
      'playerId' : PlayerId,
      'roll' : { 'value' : bigint, 'crit' : boolean },
      'outcome' : { 'hit' : HitLocation } |
        { 'strike' : null } |
        { 'foul' : null },
    }
  } |
  { 'injury' : { 'playerId' : number } } |
  {
    'pitch' : {
      'roll' : { 'value' : bigint, 'crit' : boolean },
      'pitcherId' : PlayerId,
    }
  } |
  { 'matchEnd' : { 'reason' : MatchEndReason } } |
  { 'death' : { 'playerId' : number } };
export interface MatchGroupPredictionSummary {
  'matches' : Array<MatchPredictionSummary>,
}
export interface MatchLog { 'rounds' : Array<RoundLog> }
export interface MatchPredictionSummary {
  'team1' : bigint,
  'team2' : bigint,
  'yourVote' : [] | [TeamId],
}
export interface ModifyTeamLinkContent {
  'url' : [] | [string],
  'name' : string,
}
export interface NoLeagueEffectScenario {
  'options' : Array<ScenarioOptionDiscrete>,
}
export interface NoLeagueEffectScenarioRequest {
  'options' : Array<ScenarioOptionDiscrete__1>,
}
export interface NotScheduledMatch {
  'team1' : TeamAssignment,
  'team2' : TeamAssignment,
}
export interface NotScheduledMatchGroup {
  'time' : Time,
  'matches' : Array<NotScheduledMatch>,
}
export type OutReason = { 'strikeout' : null } |
  { 'ballCaught' : null } |
  { 'hitByBall' : null };
export interface PagedResult {
  'data' : Array<User>,
  'count' : bigint,
  'offset' : bigint,
}
export interface PagedResult_1 {
  'data' : Array<Proposal>,
  'count' : bigint,
  'offset' : bigint,
}
export interface PagedResult_2 {
  'data' : Array<LeagueProposal>,
  'count' : bigint,
  'offset' : bigint,
}
export interface Player {
  'id' : number,
  'title' : string,
  'name' : string,
  'description' : string,
  'likes' : Array<string>,
  'teamId' : bigint,
  'position' : FieldPosition,
  'quirks' : Array<string>,
  'dislikes' : Array<string>,
  'skills' : Skills,
}
export type PlayerCondition = { 'ok' : null } |
  { 'dead' : null } |
  { 'injured' : null };
export type PlayerId = number;
export interface PlayerMatchStats {
  'battingStats' : {
    'homeRuns' : bigint,
    'hits' : bigint,
    'runs' : bigint,
    'strikeouts' : bigint,
    'atBats' : bigint,
  },
  'injuries' : bigint,
  'pitchingStats' : {
    'homeRuns' : bigint,
    'pitches' : bigint,
    'hits' : bigint,
    'runs' : bigint,
    'strikeouts' : bigint,
    'strikes' : bigint,
  },
  'catchingStats' : {
    'missedCatches' : bigint,
    'throwOuts' : bigint,
    'throws' : bigint,
    'successfulCatches' : bigint,
  },
}
export type PredictMatchOutcomeError = { 'predictionsClosed' : null } |
  { 'matchNotFound' : null } |
  { 'matchGroupNotFound' : null } |
  { 'identityRequired' : null };
export interface PredictMatchOutcomeRequest {
  'winner' : [] | [TeamId],
  'matchId' : bigint,
}
export type PredictMatchOutcomeResult = { 'ok' : null } |
  { 'err' : PredictMatchOutcomeError };
export interface ProportionalBidPrize {
  'kind' : PropotionalBidPrizeKind,
  'description' : string,
  'amount' : bigint,
}
export interface ProportionalBidScenario { 'prize' : ProportionalBidPrize }
export interface ProportionalBidScenarioOutcome {
  'bids' : Array<ProportionalWinningBid>,
}
export interface ProportionalWinningBid {
  'proportion' : bigint,
  'teamId' : bigint,
}
export interface Proposal {
  'id' : bigint,
  'content' : ProposalContent,
  'timeStart' : bigint,
  'votes' : Array<[Principal, Vote]>,
  'statusLog' : Array<ProposalStatusLogEntry>,
  'endTimerId' : [] | [bigint],
  'timeEnd' : bigint,
  'proposerId' : Principal,
}
export type ProposalContent = { 'train' : TrainContent } |
  { 'changeLogo' : ChangeTeamLogoContent } |
  { 'changeName' : ChangeTeamNameContent } |
  { 'changeMotto' : ChangeTeamMottoContent } |
  { 'modifyLink' : ModifyTeamLinkContent } |
  { 'changeColor' : ChangeTeamColorContent } |
  { 'swapPlayerPositions' : SwapPlayerPositionsContent } |
  { 'changeDescription' : ChangeTeamDescriptionContent };
export type ProposalContent__1 = {
    'changeTeamColor' : {
      'color' : [number, number, number],
      'teamId' : bigint,
    }
  } |
  { 'changeTeamDescription' : { 'description' : string, 'teamId' : bigint } } |
  { 'changeTeamLogo' : { 'logoUrl' : string, 'teamId' : bigint } } |
  { 'changeTeamName' : { 'name' : string, 'teamId' : bigint } } |
  { 'changeTeamMotto' : { 'motto' : string, 'teamId' : bigint } };
export type ProposalStatusLogEntry = {
    'failedToExecute' : { 'time' : Time, 'error' : string }
  } |
  { 'rejected' : { 'time' : Time } } |
  { 'executing' : { 'time' : Time } } |
  { 'executed' : { 'time' : Time } };
export type PropotionalBidPrizeKind = { 'skill' : PropotionalBidPrizeSkill };
export interface PropotionalBidPrizeSkill {
  'duration' : Duration,
  'skill' : ChosenOrRandomSkill,
  'target' : TargetPosition,
}
export type Result = { 'ok' : Player } |
  { 'err' : GetPositionError };
export interface RoundLog { 'turns' : Array<TurnLog> }
export interface Scenario {
  'id' : bigint,
  'startTime' : bigint,
  'title' : string,
  'endTime' : bigint,
  'kind' : ScenarioKind,
  'description' : string,
  'undecidedEffect' : Effect,
  'state' : ScenarioState,
}
export type ScenarioKind = { 'lottery' : LotteryScenario } |
  { 'noLeagueEffect' : NoLeagueEffectScenario } |
  { 'threshold' : ThresholdScenario } |
  { 'proportionalBid' : ProportionalBidScenario } |
  { 'leagueChoice' : LeagueChoiceScenario };
export type ScenarioKindRequest = { 'lottery' : LotteryScenario } |
  { 'noLeagueEffect' : NoLeagueEffectScenarioRequest } |
  { 'threshold' : ThresholdScenarioRequest } |
  { 'proportionalBid' : ProportionalBidScenario } |
  { 'leagueChoice' : LeagueChoiceScenarioRequest };
export interface ScenarioOptionDiscrete {
  'title' : string,
  'teamEffect' : Effect,
  'description' : string,
  'traitRequirements' : Array<TraitRequirement>,
  'energyCost' : bigint,
  'allowedTeamIds' : Array<bigint>,
}
export interface ScenarioOptionDiscrete__1 {
  'title' : string,
  'teamEffect' : Effect,
  'description' : string,
  'traitRequirements' : Array<TraitRequirement>,
  'energyCost' : bigint,
}
export type ScenarioOptionValue = { 'id' : bigint } |
  { 'nat' : bigint };
export type ScenarioOutcome = { 'lottery' : LotteryScenarioOutcome } |
  { 'noLeagueEffect' : null } |
  { 'threshold' : ThresholdScenarioOutcome } |
  { 'proportionalBid' : ProportionalBidScenarioOutcome } |
  { 'leagueChoice' : LeagueChoiceScenarioOutcome };
export interface ScenarioResolvedOptionDiscrete {
  'id' : bigint,
  'title' : string,
  'teamEffect' : Effect,
  'seenByTeamIds' : Array<bigint>,
  'description' : string,
  'traitRequirements' : Array<TraitRequirement>,
  'chosenByTeamIds' : Array<bigint>,
  'energyCost' : bigint,
}
export interface ScenarioResolvedOptionNat {
  'value' : bigint,
  'chosenByTeamIds' : Array<bigint>,
}
export interface ScenarioResolvedOptions {
  'undecidedOption' : {
    'teamEffect' : Effect,
    'chosenByTeamIds' : Array<bigint>,
  },
  'kind' : ScenarioResolvedOptionsKind,
}
export type ScenarioResolvedOptionsKind = {
    'nat' : Array<ScenarioResolvedOptionNat>
  } |
  { 'discrete' : Array<ScenarioResolvedOptionDiscrete> };
export type ScenarioState = { 'notStarted' : null } |
  { 'resolved' : ScenarioStateResolved } |
  { 'resolving' : null } |
  { 'inProgress' : null };
export interface ScenarioStateResolved {
  'scenarioOutcome' : ScenarioOutcome,
  'options' : ScenarioResolvedOptions,
  'effectOutcomes' : Array<EffectOutcome>,
}
export interface ScenarioTeamOptionDiscrete {
  'id' : bigint,
  'title' : string,
  'description' : string,
  'traitRequirements' : Array<TraitRequirement>,
  'energyCost' : bigint,
  'currentVotingPower' : bigint,
}
export interface ScenarioTeamOptionNat {
  'value' : bigint,
  'currentVotingPower' : bigint,
}
export type ScenarioTeamOptions = { 'nat' : Array<ScenarioTeamOptionNat> } |
  { 'discrete' : Array<ScenarioTeamOptionDiscrete> };
export interface ScenarioVote {
  'value' : [] | [ScenarioOptionValue],
  'teamOptions' : ScenarioTeamOptions,
  'votingPower' : bigint,
  'teamId' : bigint,
  'teamVotingPower' : bigint,
}
export interface ScheduledMatch {
  'team1' : ScheduledTeamInfo,
  'team2' : ScheduledTeamInfo,
  'aura' : MatchAuraWithMetaData,
}
export interface ScheduledMatchGroup {
  'time' : Time,
  'matches' : Array<ScheduledMatch>,
  'timerId' : bigint,
}
export interface ScheduledTeamInfo { 'id' : bigint }
export type SeasonStatus = { 'notStarted' : null } |
  { 'starting' : null } |
  { 'completed' : CompletedSeason } |
  { 'inProgress' : InProgressSeason };
export type SetBenevolentDictatorStateError = { 'notAuthorized' : null };
export type SetBenevolentDictatorStateResult = { 'ok' : null } |
  { 'err' : SetBenevolentDictatorStateError };
export type SetUserFavoriteTeamError = { 'notAuthorized' : null } |
  { 'alreadySet' : null } |
  { 'identityRequired' : null } |
  { 'teamNotFound' : null };
export type SetUserFavoriteTeamResult = { 'ok' : null } |
  { 'err' : SetUserFavoriteTeamError };
export type Skill = { 'battingAccuracy' : null } |
  { 'throwingAccuracy' : null } |
  { 'speed' : null } |
  { 'catching' : null } |
  { 'battingPower' : null } |
  { 'defense' : null } |
  { 'throwingPower' : null };
export interface SkillEffect {
  'duration' : Duration,
  'skill' : ChosenOrRandomSkill,
  'target' : TargetPosition,
  'delta' : bigint,
}
export interface SkillPlayerEffectOutcome {
  'duration' : Duration,
  'skill' : Skill,
  'target' : TargetPositionInstance,
  'delta' : bigint,
}
export interface Skills {
  'battingAccuracy' : bigint,
  'throwingAccuracy' : bigint,
  'speed' : bigint,
  'catching' : bigint,
  'battingPower' : bigint,
  'defense' : bigint,
  'throwingPower' : bigint,
}
export type StartMatchError = { 'notEnoughPlayers' : TeamIdOrBoth };
export type StartMatchGroupError = { 'notAuthorized' : null } |
  { 'notScheduledYet' : null } |
  { 'matchGroupNotFound' : null } |
  { 'alreadyStarted' : null } |
  { 'matchErrors' : Array<{ 'error' : StartMatchError, 'matchId' : bigint }> };
export type StartMatchGroupResult = { 'ok' : null } |
  { 'err' : StartMatchGroupError };
export type StartSeasonError = { 'notAuthorized' : null } |
  { 'seedGenerationError' : string } |
  { 'alreadyStarted' : null } |
  { 'idTaken' : null } |
  { 'invalidArgs' : string };
export interface StartSeasonRequest {
  'startTime' : Time,
  'weekDays' : Array<DayOfWeek>,
}
export type StartSeasonResult = { 'ok' : null } |
  { 'err' : StartSeasonError };
export interface SwapPlayerPositionsContent {
  'position1' : FieldPosition,
  'position2' : FieldPosition,
}
export interface TargetPosition {
  'team' : TargetTeam,
  'position' : ChosenOrRandomFieldPosition,
}
export interface TargetPositionInstance {
  'teamId' : bigint,
  'position' : FieldPosition,
}
export type TargetTeam = { 'all' : null } |
  { 'contextual' : null } |
  { 'random' : bigint } |
  { 'chosen' : Array<bigint> };
export interface Team {
  'id' : bigint,
  'motto' : string,
  'traits' : Array<Trait>,
  'name' : string,
  'color' : [number, number, number],
  'description' : string,
  'links' : Array<Link>,
  'entropy' : bigint,
  'logoUrl' : string,
  'energy' : bigint,
}
export type TeamAssignment = { 'winnerOfMatch' : bigint } |
  { 'predetermined' : bigint } |
  { 'seasonStandingIndex' : bigint };
export interface TeamAssociation { 'id' : bigint, 'kind' : TeamAssociationKind }
export type TeamAssociationKind = { 'fan' : null } |
  { 'owner' : { 'votingPower' : bigint } };
export type TeamId = { 'team1' : null } |
  { 'team2' : null };
export type TeamIdOrBoth = { 'team1' : null } |
  { 'team2' : null } |
  { 'bothTeams' : null };
export type TeamIdOrTie = { 'tie' : null } |
  { 'team1' : null } |
  { 'team2' : null };
export interface TeamInfo {
  'id' : bigint,
  'name' : string,
  'color' : [number, number, number],
  'logoUrl' : string,
  'positions' : TeamPositions,
}
export interface TeamPositions {
  'rightField' : number,
  'leftField' : number,
  'thirdBase' : number,
  'pitcher' : number,
  'secondBase' : number,
  'shortStop' : number,
  'centerField' : number,
  'firstBase' : number,
}
export interface TeamProposal {
  'id' : bigint,
  'content' : ProposalContent,
  'timeStart' : bigint,
  'votes' : Array<[Principal, Vote]>,
  'statusLog' : Array<ProposalStatusLogEntry>,
  'endTimerId' : [] | [bigint],
  'timeEnd' : bigint,
  'proposerId' : Principal,
}
export type TeamProposalContent = { 'train' : TrainContent } |
  { 'changeLogo' : ChangeTeamLogoContent } |
  { 'changeName' : ChangeTeamNameContent } |
  { 'changeMotto' : ChangeTeamMottoContent } |
  { 'modifyLink' : ModifyTeamLinkContent } |
  { 'changeColor' : ChangeTeamColorContent } |
  { 'swapPlayerPositions' : SwapPlayerPositionsContent } |
  { 'changeDescription' : ChangeTeamDescriptionContent };
export interface TeamStandingInfo {
  'id' : bigint,
  'wins' : bigint,
  'losses' : bigint,
  'totalScore' : bigint,
}
export interface TeamStats {
  'id' : bigint,
  'totalPoints' : bigint,
  'ownerCount' : bigint,
  'userCount' : bigint,
}
export interface TeamTraitEffect {
  'kind' : TeamTraitEffectKind,
  'target' : TargetTeam,
  'traitId' : string,
}
export type TeamTraitEffectKind = { 'add' : null } |
  { 'remove' : null };
export interface TeamTraitTeamEffectOutcome {
  'kind' : TeamTraitEffectKind,
  'traitId' : string,
  'teamId' : bigint,
}
export interface ThresholdContribution { 'teamId' : bigint, 'amount' : bigint }
export interface ThresholdScenario {
  'failure' : { 'description' : string, 'effect' : Effect },
  'minAmount' : bigint,
  'success' : { 'description' : string, 'effect' : Effect },
  'options' : Array<ThresholdScenarioOption>,
  'undecidedAmount' : ThresholdValue,
}
export interface ThresholdScenarioOption {
  'title' : string,
  'value' : ThresholdValue,
  'teamEffect' : Effect,
  'description' : string,
  'traitRequirements' : Array<TraitRequirement>,
  'energyCost' : bigint,
  'allowedTeamIds' : Array<bigint>,
}
export interface ThresholdScenarioOptionRequest {
  'title' : string,
  'value' : ThresholdValue__1,
  'teamEffect' : Effect,
  'description' : string,
  'traitRequirements' : Array<TraitRequirement>,
  'energyCost' : bigint,
}
export interface ThresholdScenarioOutcome {
  'contributions' : Array<ThresholdContribution>,
  'successful' : boolean,
}
export interface ThresholdScenarioRequest {
  'failure' : { 'description' : string, 'effect' : Effect },
  'minAmount' : bigint,
  'success' : { 'description' : string, 'effect' : Effect },
  'options' : Array<ThresholdScenarioOptionRequest>,
  'undecidedAmount' : ThresholdValue__1,
}
export type ThresholdValue = { 'fixed' : bigint } |
  {
    'weightedChance' : Array<
      { 'weight' : bigint, 'value' : bigint, 'description' : string }
    >
  };
export type ThresholdValue__1 = { 'fixed' : bigint } |
  {
    'weightedChance' : Array<
      { 'weight' : bigint, 'value' : bigint, 'description' : string }
    >
  };
export type Time = bigint;
export interface TrainContent { 'skill' : Skill, 'position' : FieldPosition }
export interface Trait {
  'id' : string,
  'name' : string,
  'description' : string,
}
export interface TraitRequirement {
  'id' : string,
  'kind' : TraitRequirementKind,
}
export type TraitRequirementKind = { 'prohibited' : null } |
  { 'required' : null };
export interface TurnLog { 'events' : Array<MatchEvent> }
export interface User {
  'id' : Principal,
  'team' : [] | [TeamAssociation],
  'points' : bigint,
}
export interface UserStats {
  'teams' : Array<TeamStats>,
  'teamOwnerCount' : bigint,
  'totalPoints' : bigint,
  'userCount' : bigint,
}
export interface UserVotingInfo {
  'id' : Principal,
  'votingPower' : bigint,
  'teamId' : bigint,
}
export interface Vote { 'value' : [] | [boolean], 'votingPower' : bigint }
export type VoteOnLeagueProposalError = { 'proposalNotFound' : null } |
  { 'notAuthorized' : null } |
  { 'alreadyVoted' : null } |
  { 'votingClosed' : null };
export interface VoteOnLeagueProposalRequest {
  'vote' : boolean,
  'proposalId' : bigint,
}
export type VoteOnLeagueProposalResult = { 'ok' : null } |
  { 'err' : VoteOnLeagueProposalError };
export type VoteOnScenarioError = { 'votingNotOpen' : null } |
  { 'invalidValue' : null } |
  { 'notEligible' : null } |
  { 'scenarioNotFound' : null };
export interface VoteOnScenarioRequest {
  'scenarioId' : bigint,
  'value' : ScenarioOptionValue,
}
export type VoteOnScenarioResult = { 'ok' : null } |
  { 'err' : VoteOnScenarioError };
export type VoteOnTeamProposalError = { 'proposalNotFound' : null } |
  { 'notAuthorized' : null } |
  { 'alreadyVoted' : null } |
  { 'votingClosed' : null } |
  { 'teamNotFound' : null };
export interface VoteOnTeamProposalRequest {
  'vote' : boolean,
  'proposalId' : bigint,
}
export type VoteOnTeamProposalResult = { 'ok' : null } |
  { 'err' : VoteOnTeamProposalError };
export interface WeightedEffect {
  'weight' : bigint,
  'description' : string,
  'effect' : Effect,
}
export interface _SERVICE {
  'addFluff' : ActorMethod<[CreatePlayerFluffRequest], CreatePlayerFluffResult>,
  'addScenario' : ActorMethod<[AddScenarioRequest], AddScenarioResult>,
  'addTeamOwner' : ActorMethod<[AddTeamOwnerRequest], AddTeamOwnerResult>,
  'claimBenevolentDictatorRole' : ActorMethod<
    [],
    ClaimBenevolentDictatorRoleResult
  >,
  'closeSeason' : ActorMethod<[], CloseSeasonResult>,
  'createTeam' : ActorMethod<[CreateTeamRequest], CreateTeamResult>,
  'createTeamProposal' : ActorMethod<
    [bigint, TeamProposalContent],
    CreateTeamProposalResult
  >,
  'createTeamTrait' : ActorMethod<
    [CreateTeamTraitRequest],
    CreateTeamTraitResult
  >,
  'finishLiveMatchGroup' : ActorMethod<[], FinishMatchGroupResult>,
  'getAllPlayers' : ActorMethod<[], Array<Player>>,
  'getBenevolentDictatorState' : ActorMethod<[], BenevolentDictatorState>,
  'getEntropyThreshold' : ActorMethod<[], bigint>,
  'getLeagueProposal' : ActorMethod<[bigint], GetLeagueProposalResult>,
  'getLeagueProposals' : ActorMethod<
    [bigint, bigint],
    GetLeagueProposalsResult
  >,
  'getLiveMatchGroupState' : ActorMethod<[], [] | [LiveMatchGroupState]>,
  'getMatchGroupPredictions' : ActorMethod<
    [bigint],
    GetMatchGroupPredictionsResult
  >,
  'getPlayer' : ActorMethod<[number], GetPlayerResult>,
  'getPosition' : ActorMethod<[bigint, FieldPosition], Result>,
  'getScenario' : ActorMethod<[bigint], GetScenarioResult>,
  'getScenarioVote' : ActorMethod<
    [GetScenarioVoteRequest],
    GetScenarioVoteResult
  >,
  'getScenarios' : ActorMethod<[], GetScenariosResult>,
  'getSeasonStatus' : ActorMethod<[], SeasonStatus>,
  'getTeamOwners' : ActorMethod<[GetTeamOwnersRequest], GetTeamOwnersResult>,
  'getTeamPlayers' : ActorMethod<[bigint], Array<Player>>,
  'getTeamProposal' : ActorMethod<[bigint, bigint], GetTeamProposalResult>,
  'getTeamProposals' : ActorMethod<
    [bigint, bigint, bigint],
    GetTeamProposalsResult
  >,
  'getTeamStandings' : ActorMethod<[], GetTeamStandingsResult>,
  'getTeams' : ActorMethod<[], Array<Team>>,
  'getTraits' : ActorMethod<[], Array<Trait>>,
  'getUser' : ActorMethod<[Principal], GetUserResult>,
  'getUserLeaderboard' : ActorMethod<
    [GetUserLeaderboardRequest],
    GetUserLeaderboardResult
  >,
  'getUserStats' : ActorMethod<[], GetUserStatsResult>,
  'predictMatchOutcome' : ActorMethod<
    [PredictMatchOutcomeRequest],
    PredictMatchOutcomeResult
  >,
  'setBenevolentDictatorState' : ActorMethod<
    [BenevolentDictatorState],
    SetBenevolentDictatorStateResult
  >,
  'setFavoriteTeam' : ActorMethod<
    [Principal, bigint],
    SetUserFavoriteTeamResult
  >,
  'startNextMatchGroup' : ActorMethod<[], StartMatchGroupResult>,
  'startSeason' : ActorMethod<[StartSeasonRequest], StartSeasonResult>,
  'voteOnLeagueProposal' : ActorMethod<
    [VoteOnLeagueProposalRequest],
    VoteOnLeagueProposalResult
  >,
  'voteOnScenario' : ActorMethod<[VoteOnScenarioRequest], VoteOnScenarioResult>,
  'voteOnTeamProposal' : ActorMethod<
    [bigint, VoteOnTeamProposalRequest],
    VoteOnTeamProposalResult
  >,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
