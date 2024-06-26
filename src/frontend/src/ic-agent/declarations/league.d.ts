import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export type AddScenarioCustomTeamOptionError = { 'notAuthorized' : null } |
  { 'duplicate' : null } |
  { 'customOptionNotAllowed' : null } |
  { 'invalidValueType' : null } |
  { 'scenarioNotFound' : null };
export interface AddScenarioCustomTeamOptionRequest {
  'scenarioId' : bigint,
  'value' : { 'nat' : bigint },
}
export type AddScenarioError = { 'notAuthorized' : null } |
  { 'invalid' : Array<string> };
export interface AddScenarioRequest {
  'startTime' : [] | [Time],
  'title' : string,
  'endTime' : Time,
  'kind' : ScenarioKind,
  'description' : string,
  'undecidedEffect' : Effect,
}
export type AddScenarioResult = { 'ok' : null } |
  { 'err' : AddScenarioError };
export type BenevolentDictatorState = { 'open' : null } |
  { 'claimed' : Principal } |
  { 'disabled' : null };
export type ChosenOrRandomFieldPosition = { 'random' : null } |
  { 'chosen' : FieldPosition };
export type ChosenOrRandomSkill = { 'random' : null } |
  { 'chosen' : Skill };
export type ClaimBenevolentDictatorRoleError = { 'notOpenToClaim' : null };
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
export type CreateProposalError = { 'notAuthorized' : null };
export interface CreateProposalRequest { 'content' : ProposalContent }
export type CreateProposalResult = { 'ok' : bigint } |
  { 'err' : CreateProposalError };
export type CreateTeamError = { 'nameTaken' : null } |
  { 'notAuthorized' : null } |
  { 'teamsCallError' : string };
export interface CreateTeamRequest {
  'motto' : string,
  'name' : string,
  'color' : [number, number, number],
  'description' : string,
  'logoUrl' : string,
}
export type CreateTeamResult = { 'ok' : bigint } |
  { 'err' : CreateTeamError };
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
export type GetMatchGroupPredictionsError = { 'notFound' : null };
export type GetMatchGroupPredictionsResult = {
    'ok' : MatchGroupPredictionSummary
  } |
  { 'err' : GetMatchGroupPredictionsError };
export type GetProposalError = { 'proposalNotFound' : null };
export type GetProposalResult = { 'ok' : Proposal } |
  { 'err' : GetProposalError };
export type GetProposalsResult = { 'ok' : PagedResult };
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
export type GetTeamStandingsError = { 'notFound' : null };
export type GetTeamStandingsResult = { 'ok' : Array<TeamStandingInfo> } |
  { 'err' : GetTeamStandingsError };
export interface InProgressMatch {
  'team1' : InProgressTeam,
  'team2' : InProgressTeam,
  'aura' : MatchAura,
}
export interface InProgressMatchGroup {
  'stadiumId' : Principal,
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
}
export interface LeagueChoiceScenarioOutcome { 'optionId' : [] | [bigint] }
export interface LotteryScenario { 'minBid' : bigint, 'prize' : Effect }
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
export interface MatchGroupPredictionSummary {
  'matches' : Array<MatchPredictionSummary>,
}
export interface MatchPredictionSummary {
  'team1' : bigint,
  'team2' : bigint,
  'yourVote' : [] | [TeamId],
}
export interface NoLeagueEffectScenario { 'options' : Array<ScenarioOption> }
export interface NotScheduledMatch {
  'team1' : TeamAssignment,
  'team2' : TeamAssignment,
}
export interface NotScheduledMatchGroup {
  'time' : Time,
  'matches' : Array<NotScheduledMatch>,
}
export type OnMatchGroupCompleteError = { 'notAuthorized' : null } |
  { 'seedGenerationError' : string } |
  { 'matchGroupNotFound' : null } |
  { 'seasonNotOpen' : null } |
  { 'matchGroupNotInProgress' : null };
export interface OnMatchGroupCompleteRequest {
  'id' : bigint,
  'matches' : Array<CompletedMatch>,
  'playerStats' : Array<PlayerMatchStatsWithId>,
}
export type OnMatchGroupCompleteResult = { 'ok' : null } |
  { 'err' : OnMatchGroupCompleteError };
export interface PagedResult {
  'data' : Array<Proposal>,
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
export type PlayerId = number;
export interface PlayerMatchStatsWithId {
  'playerId' : PlayerId,
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
  'proposer' : Principal,
  'timeEnd' : bigint,
}
export type ProposalContent = {
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
export interface ResolvedTeamChoice {
  'optionId' : [] | [bigint],
  'teamId' : bigint,
}
export type Result = { 'ok' : null } |
  { 'err' : AddScenarioCustomTeamOptionError };
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
export interface ScenarioOption {
  'title' : string,
  'teamEffect' : Effect,
  'description' : string,
  'traitRequirements' : Array<TraitRequirement>,
  'energyCost' : bigint,
}
export type ScenarioOptionValue = { 'nat' : bigint } |
  { 'none' : null };
export type ScenarioOutcome = { 'lottery' : LotteryScenarioOutcome } |
  { 'noLeagueEffect' : null } |
  { 'threshold' : ThresholdScenarioOutcome } |
  { 'proportionalBid' : ProportionalBidScenarioOutcome } |
  { 'leagueChoice' : LeagueChoiceScenarioOutcome };
export type ScenarioState = { 'notStarted' : null } |
  { 'resolved' : ScenarioStateResolved } |
  { 'inProgress' : null };
export interface ScenarioStateResolved {
  'teamChoices' : Array<ResolvedTeamChoice>,
  'scenarioOutcome' : ScenarioOutcome,
  'effectOutcomes' : Array<EffectOutcome>,
}
export interface ScenarioTeamOption {
  'id' : bigint,
  'title' : string,
  'value' : ScenarioOptionValue,
  'votingPower' : bigint,
  'description' : string,
  'traitRequirements' : Array<TraitRequirement>,
  'energyCost' : bigint,
}
export interface ScenarioVote {
  'optionId' : [] | [bigint],
  'teamOptions' : Array<ScenarioTeamOption>,
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
  'stadiumId' : Principal,
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
export type TeamAssignment = { 'winnerOfMatch' : bigint } |
  { 'predetermined' : bigint } |
  { 'seasonStandingIndex' : bigint };
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
export interface TeamStandingInfo {
  'id' : bigint,
  'wins' : bigint,
  'losses' : bigint,
  'totalScore' : bigint,
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
}
export interface ThresholdScenarioOutcome {
  'contributions' : Array<ThresholdContribution>,
  'successful' : boolean,
}
export type ThresholdValue = { 'fixed' : bigint } |
  {
    'weightedChance' : Array<
      { 'weight' : bigint, 'value' : bigint, 'description' : string }
    >
  };
export type Time = bigint;
export interface TraitRequirement {
  'id' : string,
  'kind' : TraitRequirementKind,
}
export type TraitRequirementKind = { 'prohibited' : null } |
  { 'required' : null };
export interface Vote { 'value' : [] | [boolean], 'votingPower' : bigint }
export type VoteOnProposalError = { 'proposalNotFound' : null } |
  { 'notAuthorized' : null } |
  { 'alreadyVoted' : null } |
  { 'votingClosed' : null };
export interface VoteOnProposalRequest {
  'vote' : boolean,
  'proposalId' : bigint,
}
export type VoteOnProposalResult = { 'ok' : null } |
  { 'err' : VoteOnProposalError };
export type VoteOnScenarioError = { 'invalidOption' : null } |
  { 'votingNotOpen' : null } |
  { 'notEligible' : null } |
  { 'scenarioNotFound' : null };
export interface VoteOnScenarioRequest {
  'scenarioId' : bigint,
  'option' : bigint,
}
export type VoteOnScenarioResult = { 'ok' : null } |
  { 'err' : VoteOnScenarioError };
export interface WeightedEffect {
  'weight' : bigint,
  'description' : string,
  'effect' : Effect,
}
export interface _SERVICE {
  'addScenario' : ActorMethod<[AddScenarioRequest], AddScenarioResult>,
  'addScenarioCustomTeamOption' : ActorMethod<
    [AddScenarioCustomTeamOptionRequest],
    Result
  >,
  'claimBenevolentDictatorRole' : ActorMethod<
    [],
    ClaimBenevolentDictatorRoleResult
  >,
  'closeSeason' : ActorMethod<[], CloseSeasonResult>,
  'createProposal' : ActorMethod<[CreateProposalRequest], CreateProposalResult>,
  'createTeam' : ActorMethod<[CreateTeamRequest], CreateTeamResult>,
  'getBenevolentDictatorState' : ActorMethod<[], BenevolentDictatorState>,
  'getMatchGroupPredictions' : ActorMethod<
    [bigint],
    GetMatchGroupPredictionsResult
  >,
  'getProposal' : ActorMethod<[bigint], GetProposalResult>,
  'getProposals' : ActorMethod<[bigint, bigint], GetProposalsResult>,
  'getScenario' : ActorMethod<[bigint], GetScenarioResult>,
  'getScenarioVote' : ActorMethod<
    [GetScenarioVoteRequest],
    GetScenarioVoteResult
  >,
  'getScenarios' : ActorMethod<[], GetScenariosResult>,
  'getSeasonStatus' : ActorMethod<[], SeasonStatus>,
  'getTeamStandings' : ActorMethod<[], GetTeamStandingsResult>,
  'onMatchGroupComplete' : ActorMethod<
    [OnMatchGroupCompleteRequest],
    OnMatchGroupCompleteResult
  >,
  'predictMatchOutcome' : ActorMethod<
    [PredictMatchOutcomeRequest],
    PredictMatchOutcomeResult
  >,
  'setBenevolentDictatorState' : ActorMethod<
    [BenevolentDictatorState],
    SetBenevolentDictatorStateResult
  >,
  'startMatchGroup' : ActorMethod<[bigint], StartMatchGroupResult>,
  'startSeason' : ActorMethod<[StartSeasonRequest], StartSeasonResult>,
  'voteOnProposal' : ActorMethod<[VoteOnProposalRequest], VoteOnProposalResult>,
  'voteOnScenario' : ActorMethod<[VoteOnScenarioRequest], VoteOnScenarioResult>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
