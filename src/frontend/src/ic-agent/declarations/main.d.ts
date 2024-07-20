import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export type AddScenarioError = { 'notAuthorized': null } |
{ 'invalid': Array<string> };
export interface AddScenarioRequest {
  'startTime': [] | [Time],
  'title': string,
  'endTime': Time,
  'kind': ScenarioKindRequest,
  'description': string,
  'undecidedEffect': Effect,
}
export type AddScenarioResult = { 'ok': null } |
{ 'err': AddScenarioError };
export type Anomoly = { 'foggy': null } |
{ 'moveBasesIn': null } |
{ 'extraStrike': null } |
{ 'moreBlessingsAndCurses': null } |
{ 'fastBallsHardHits': null } |
{ 'explodingBalls': null } |
{ 'lowGravity': null } |
{ 'doubleOrNothing': null } |
{ 'windy': null } |
{ 'rainy': null };
export type AssignUserToTownError = { 'notAuthorized': null } |
{ 'townNotFound': null } |
{ 'notLeagueMember': null };
export interface AssignUserToTownRequest {
  'userId': Principal,
  'townId': bigint,
}
export type Base = { 'homeBase': null } |
{ 'thirdBase': null } |
{ 'secondBase': null } |
{ 'firstBase': null };
export type BenevolentDictatorState = { 'open': null } |
{ 'claimed': Principal } |
{ 'disabled': null };
export interface ChangeTownColorContent { 'color': [number, number, number] }
export interface ChangeTownColorContent__1 {
  'color': [number, number, number],
  'townId': bigint,
}
export interface ChangeTownDescriptionContent { 'description': string }
export interface ChangeTownDescriptionContent__1 {
  'description': string,
  'townId': bigint,
}
export interface ChangeTownLogoContent { 'logoUrl': string }
export interface ChangeTownLogoContent__1 {
  'logoUrl': string,
  'townId': bigint,
}
export interface ChangeTownMottoContent { 'motto': string }
export interface ChangeTownMottoContent__1 {
  'motto': string,
  'townId': bigint,
}
export interface ChangeTownNameContent { 'name': string }
export interface ChangeTownNameContent__1 { 'name': string, 'townId': bigint }
export type ChosenOrRandomFieldPosition = { 'random': null } |
{ 'chosen': FieldPosition };
export type ChosenOrRandomSkill = { 'random': null } |
{ 'chosen': Skill };
export type ClaimBenevolentDictatorRoleError = { 'notOpenToClaim': null } |
{ 'notAuthenticated': null };
export type ClaimBenevolentDictatorRoleResult = { 'ok': null } |
{ 'err': ClaimBenevolentDictatorRoleError };
export type CloseSeasonError = { 'notAuthorized': null } |
{ 'seasonNotOpen': null };
export type CloseSeasonResult = { 'ok': null } |
{ 'err': CloseSeasonError };
export interface CompletedMatch {
  'town1': CompletedMatchTown,
  'town2': CompletedMatchTown,
  'winner': TownIdOrTie,
}
export interface CompletedMatchGroup {
  'time': Time,
  'matches': Array<CompletedMatch>,
}
export interface CompletedMatchTown {
  'id': bigint,
  'anomolies': Array<Anomoly>,
  'score': bigint,
  'playerStats': Array<PlayerMatchStats>,
  'positions': TownPositions,
}
export interface CompletedSeason {
  'towns': Array<CompletedSeasonTown>,
  'completedMatchGroups': Array<CompletedMatchGroup>,
  'outcome': CompletedSeasonOutcome,
}
export type CompletedSeasonOutcome = {
  'failure': CompletedSeasonOutcomeFailure
} |
{ 'success': CompletedSeasonOutcomeSuccess };
export interface CompletedSeasonOutcomeFailure {
  'incompleteMatchGroups': Array<NotScheduledMatchGroup>,
}
export interface CompletedSeasonOutcomeSuccess {
  'runnerUpTownId': bigint,
  'championTownId': bigint,
}
export interface CompletedSeasonTown {
  'id': bigint,
  'wins': bigint,
  'losses': bigint,
  'totalScore': bigint,
}
export type CreateLeagueProposalError = { 'notAuthorized': null } |
{ 'invalid': Array<string> };
export type CreateLeagueProposalRequest = {
  'changeTownColor': ChangeTownColorContent__1
} |
{ 'changeTownDescription': ChangeTownDescriptionContent__1 } |
{ 'changeTownLogo': ChangeTownLogoContent__1 } |
{ 'changeTownName': ChangeTownNameContent__1 } |
{ 'motion': MotionContent__1 } |
{ 'changeTownMotto': ChangeTownMottoContent__1 };
export type CreateLeagueProposalResult = { 'ok': bigint } |
{ 'err': CreateLeagueProposalError };
export type CreatePlayerFluffError = { 'notAuthorized': null } |
{ 'invalid': Array<InvalidError> };
export interface CreatePlayerFluffRequest {
  'title': string,
  'name': string,
  'description': string,
  'likes': Array<string>,
  'quirks': Array<string>,
  'dislikes': Array<string>,
}
export type CreatePlayerFluffResult = { 'ok': null } |
{ 'err': CreatePlayerFluffError };
export type CreateTownError = { 'nameTaken': null } |
{ 'notAuthorized': null };
export type CreateTownProposalError = { 'notAuthorized': null } |
{ 'invalid': Array<string> } |
{ 'townNotFound': null };
export type CreateTownProposalResult = { 'ok': bigint } |
{ 'err': CreateTownProposalError };
export interface CreateTownRequest {
  'motto': string,
  'name': string,
  'color': [number, number, number],
  'description': string,
  'entropy': bigint,
  'logoUrl': string,
  'currency': bigint,
}
export type CreateTownResult = { 'ok': bigint } |
{ 'err': CreateTownError };
export type CreateTownTraitError = { 'notAuthorized': null } |
{ 'invalid': Array<string> } |
{ 'idTaken': null };
export interface CreateTownTraitRequest {
  'id': string,
  'name': string,
  'description': string,
}
export type CreateTownTraitResult = { 'ok': null } |
{ 'err': CreateTownTraitError };
export interface CurrencyEffect {
  'value': { 'flat': bigint },
  'town': TargetTown,
}
export interface CurrencyTownEffectOutcome {
  'townId': bigint,
  'delta': bigint,
}
export type DayOfWeek = { 'tuesday': null } |
{ 'wednesday': null } |
{ 'saturday': null } |
{ 'thursday': null } |
{ 'sunday': null } |
{ 'friday': null } |
{ 'monday': null };
export type Duration = { 'matches': bigint } |
{ 'indefinite': null };
export type Effect = { 'allOf': Array<Effect> } |
{ 'townTrait': TownTraitEffect } |
{ 'noEffect': null } |
{ 'oneOf': Array<WeightedEffect> } |
{ 'entropy': EntropyEffect } |
{ 'entropyThreshold': EntropyThresholdEffect } |
{ 'skill': SkillEffect } |
{ 'injury': InjuryEffect } |
{ 'currency': CurrencyEffect } |
{ 'leagueIncome': LeagueIncomeEffect };
export type EffectOutcome = { 'townTrait': TownTraitTownEffectOutcome } |
{ 'entropy': EntropyTownEffectOutcome } |
{ 'entropyThreshold': EntropyThresholdEffectOutcome } |
{ 'skill': SkillPlayerEffectOutcome } |
{ 'injury': InjuryPlayerEffectOutcome } |
{ 'currency': CurrencyTownEffectOutcome } |
{ 'leagueIncome': LeagueIncomeEffectOutcome };
export interface EntropyEffect { 'town': TargetTown, 'delta': bigint }
export interface EntropyTownEffectOutcome {
  'townId': bigint,
  'delta': bigint,
}
export interface EntropyThresholdEffect { 'delta': bigint }
export interface EntropyThresholdEffectOutcome { 'delta': bigint }
export type FieldPosition = { 'rightField': null } |
{ 'leftField': null } |
{ 'thirdBase': null } |
{ 'pitcher': null } |
{ 'secondBase': null } |
{ 'shortStop': null } |
{ 'centerField': null } |
{ 'firstBase': null };
export type GetLeagueProposalError = { 'proposalNotFound': null };
export type GetLeagueProposalResult = { 'ok': LeagueProposal } |
{ 'err': GetLeagueProposalError };
export type GetLeagueProposalsResult = { 'ok': PagedResult_2 };
export type GetMatchGroupPredictionsError = { 'notFound': null };
export type GetMatchGroupPredictionsResult = {
  'ok': MatchGroupPredictionSummary
} |
{ 'err': GetMatchGroupPredictionsError };
export type GetPlayerError = { 'notFound': null };
export type GetPlayerResult = { 'ok': Player } |
{ 'err': GetPlayerError };
export type GetPositionError = { 'townNotFound': null };
export type GetScenarioError = { 'notStarted': null } |
{ 'notFound': null };
export type GetScenarioResult = { 'ok': Scenario } |
{ 'err': GetScenarioError };
export type GetScenarioVoteError = { 'notEligible': null } |
{ 'scenarioNotFound': null };
export interface GetScenarioVoteRequest { 'scenarioId': bigint }
export type GetScenarioVoteResult = { 'ok': VotingData } |
{ 'err': GetScenarioVoteError };
export type GetScenariosResult = { 'ok': Array<Scenario> };
export type GetTownOwnersRequest = { 'all': null } |
{ 'town': bigint };
export type GetTownOwnersResult = { 'ok': Array<UserVotingInfo> };
export type GetTownProposalError = { 'proposalNotFound': null } |
{ 'townNotFound': null };
export type GetTownProposalResult = { 'ok': TownProposal } |
{ 'err': GetTownProposalError };
export type GetTownProposalsError = { 'townNotFound': null };
export type GetTownProposalsResult = { 'ok': PagedResult_1 } |
{ 'err': GetTownProposalsError };
export type GetTownStandingsError = { 'notFound': null };
export type GetTownStandingsResult = { 'ok': Array<TownStandingInfo> } |
{ 'err': GetTownStandingsError };
export type GetUserError = { 'notAuthorized': null } |
{ 'notFound': null };
export interface GetUserLeaderboardRequest {
  'count': bigint,
  'offset': bigint,
}
export type GetUserLeaderboardResult = { 'ok': PagedResult };
export type GetUserResult = { 'ok': User } |
{ 'err': GetUserError };
export type GetUserStatsResult = { 'ok': UserStats } |
{ 'err': null };
export type HitLocation = { 'rightField': null } |
{ 'stands': null } |
{ 'leftField': null } |
{ 'thirdBase': null } |
{ 'pitcher': null } |
{ 'secondBase': null } |
{ 'shortStop': null } |
{ 'centerField': null } |
{ 'firstBase': null };
export interface InProgressMatch {
  'town1': InProgressTown,
  'town2': InProgressTown,
}
export interface InProgressMatchGroup {
  'time': Time,
  'matches': Array<InProgressMatch>,
}
export interface InProgressSeason {
  'matchGroups': Array<InProgressSeasonMatchGroupVariant>,
}
export type InProgressSeasonMatchGroupVariant = {
  'scheduled': ScheduledMatchGroup
} |
{ 'completed': CompletedMatchGroup } |
{ 'inProgress': InProgressMatchGroup } |
{ 'notScheduled': NotScheduledMatchGroup };
export interface InProgressTown {
  'id': bigint,
  'anomolies': Array<Anomoly>,
  'positions': TownPositions,
}
export interface InjuryEffect { 'position': TargetPosition }
export interface InjuryPlayerEffectOutcome {
  'position': TargetPositionInstance,
}
export type InvalidError = { 'nameTaken': null } |
{ 'nameNotSpecified': null };
export type JoinLeagueError = { 'notAuthorized': null } |
{ 'noTowns': null } |
{ 'alreadyLeagueMember': null };
export interface LeagueChoiceScenario {
  'options': Array<LeagueChoiceScenarioOption>,
}
export interface LeagueChoiceScenarioOption {
  'title': string,
  'townEffect': Effect,
  'description': string,
  'leagueEffect': Effect,
  'traitRequirements': Array<TraitRequirement>,
  'currencyCost': bigint,
  'allowedTownIds': Array<bigint>,
}
export interface LeagueChoiceScenarioOptionRequest {
  'title': string,
  'townEffect': Effect,
  'description': string,
  'leagueEffect': Effect,
  'traitRequirements': Array<TraitRequirement>,
  'currencyCost': bigint,
}
export interface LeagueChoiceScenarioOutcome { 'optionId': [] | [bigint] }
export interface LeagueChoiceScenarioRequest {
  'options': Array<LeagueChoiceScenarioOptionRequest>,
}
export interface LeagueData {
  'entropyThreshold': bigint,
  'currentEntropy': bigint,
  'leagueIncome': bigint,
}
export interface LeagueIncomeEffect { 'delta': bigint }
export interface LeagueIncomeEffectOutcome { 'delta': bigint }
export interface LeagueProposal {
  'id': bigint,
  'content': ProposalContent__1,
  'timeStart': bigint,
  'votes': Array<[Principal, Vote]>,
  'statusLog': Array<ProposalStatusLogEntry>,
  'endTimerId': [] | [bigint],
  'timeEnd': bigint,
  'proposerId': Principal,
}
export interface Link { 'url': string, 'name': string }
export interface LiveBaseState {
  'atBat': PlayerId,
  'thirdBase': [] | [PlayerId],
  'secondBase': [] | [PlayerId],
  'firstBase': [] | [PlayerId],
}
export interface LiveMatchGroupState {
  'id': bigint,
  'tickTimerId': bigint,
  'currentSeed': number,
  'matches': Array<LiveMatchStateWithStatus>,
}
export interface LiveMatchStateWithStatus {
  'log': MatchLog,
  'status': LiveMatchStatus,
  'town1': LiveMatchTown,
  'town2': LiveMatchTown,
  'outs': bigint,
  'offenseTownId': TownId,
  'players': Array<LivePlayerState>,
  'bases': LiveBaseState,
  'strikes': bigint,
}
export type LiveMatchStatus = { 'completed': LiveMatchStatusCompleted } |
{ 'inProgress': null };
export interface LiveMatchStatusCompleted { 'reason': MatchEndReason }
export interface LiveMatchTown {
  'id': bigint,
  'anomolies': Array<Anomoly>,
  'score': bigint,
  'positions': TownPositions,
}
export interface LivePlayerState {
  'id': PlayerId,
  'name': string,
  'matchStats': PlayerMatchStatsWithoutId,
  'townId': TownId,
  'skills': Skills,
  'condition': PlayerCondition,
}
export interface LotteryPrize { 'description': string, 'effect': Effect }
export interface LotteryScenario { 'minBid': bigint, 'prize': LotteryPrize }
export interface LotteryScenarioOutcome { 'winningTownId': [] | [bigint] }
export type MatchEndReason = { 'noMoreRounds': null } |
{ 'error': string };
export type MatchEvent = {
  'out': { 'playerId': PlayerId, 'reason': OutReason }
} |
{ 'throw': { 'to': PlayerId, 'from': PlayerId } } |
{ 'newBatter': { 'playerId': PlayerId } } |
{ 'townSwap': { 'atBatPlayerId': PlayerId, 'offenseTownId': TownId } } |
{ 'hitByBall': { 'playerId': PlayerId } } |
{
  'catch': {
    'difficulty': { 'value': bigint, 'crit': boolean },
    'playerId': PlayerId,
    'roll': { 'value': bigint, 'crit': boolean },
  }
} |
{
  'traitTrigger': {
    'id': Trait,
    'playerId': PlayerId,
    'description': string,
  }
} |
{ 'safeAtBase': { 'base': Base, 'playerId': PlayerId } } |
{ 'anomolyTrigger': { 'id': Anomoly, 'description': string } } |
{ 'score': { 'townId': TownId, 'amount': bigint } } |
{
  'swing': {
    'pitchRoll': { 'value': bigint, 'crit': boolean },
    'playerId': PlayerId,
    'roll': { 'value': bigint, 'crit': boolean },
    'outcome': { 'hit': HitLocation } |
    { 'strike': null } |
    { 'foul': null },
  }
} |
{ 'injury': { 'playerId': number } } |
{
  'pitch': {
    'roll': { 'value': bigint, 'crit': boolean },
    'pitcherId': PlayerId,
  }
} |
{ 'matchEnd': { 'reason': MatchEndReason } } |
{ 'death': { 'playerId': number } };
export interface MatchGroupPredictionSummary {
  'matches': Array<MatchPredictionSummary>,
}
export interface MatchLog { 'rounds': Array<RoundLog> }
export interface MatchPredictionSummary {
  'town1': bigint,
  'town2': bigint,
  'yourVote': [] | [TownId],
}
export interface ModifyTownLinkContent {
  'url': [] | [string],
  'name': string,
}
export interface MotionContent { 'title': string, 'description': string }
export interface MotionContent__1 { 'title': string, 'description': string }
export interface NoLeagueEffectScenario {
  'options': Array<ScenarioOptionDiscrete>,
}
export interface NoLeagueEffectScenarioRequest {
  'options': Array<ScenarioOptionDiscrete__1>,
}
export interface NotScheduledMatch {
  'town1': TownAssignment,
  'town2': TownAssignment,
}
export interface NotScheduledMatchGroup {
  'time': Time,
  'matches': Array<NotScheduledMatch>,
}
export type OutReason = { 'strikeout': null } |
{ 'ballCaught': null } |
{ 'hitByBall': null };
export interface PagedResult {
  'data': Array<User>,
  'count': bigint,
  'offset': bigint,
}
export interface PagedResult_1 {
  'data': Array<Proposal>,
  'count': bigint,
  'offset': bigint,
}
export interface PagedResult_2 {
  'data': Array<LeagueProposal>,
  'count': bigint,
  'offset': bigint,
}
export interface Player {
  'id': number,
  'title': string,
  'name': string,
  'description': string,
  'likes': Array<string>,
  'townId': bigint,
  'position': FieldPosition,
  'quirks': Array<string>,
  'dislikes': Array<string>,
  'skills': Skills,
}
export type PlayerCondition = { 'ok': null } |
{ 'dead': null } |
{ 'injured': null };
export type PlayerId = number;
export interface PlayerMatchStats {
  'playerId': PlayerId,
  'battingStats': {
    'homeRuns': bigint,
    'hits': bigint,
    'runs': bigint,
    'strikeouts': bigint,
    'atBats': bigint,
  },
  'injuries': bigint,
  'pitchingStats': {
    'homeRuns': bigint,
    'pitches': bigint,
    'hits': bigint,
    'runs': bigint,
    'strikeouts': bigint,
    'strikes': bigint,
  },
  'catchingStats': {
    'missedCatches': bigint,
    'throwOuts': bigint,
    'throws': bigint,
    'successfulCatches': bigint,
  },
}
export interface PlayerMatchStatsWithoutId {
  'battingStats': {
    'homeRuns': bigint,
    'hits': bigint,
    'runs': bigint,
    'strikeouts': bigint,
    'atBats': bigint,
  },
  'injuries': bigint,
  'pitchingStats': {
    'homeRuns': bigint,
    'pitches': bigint,
    'hits': bigint,
    'runs': bigint,
    'strikeouts': bigint,
    'strikes': bigint,
  },
  'catchingStats': {
    'missedCatches': bigint,
    'throwOuts': bigint,
    'throws': bigint,
    'successfulCatches': bigint,
  },
}
export type PredictMatchOutcomeError = { 'predictionsClosed': null } |
{ 'matchNotFound': null } |
{ 'matchGroupNotFound': null } |
{ 'identityRequired': null };
export interface PredictMatchOutcomeRequest {
  'winner': [] | [TownId],
  'matchId': bigint,
}
export type PredictMatchOutcomeResult = { 'ok': null } |
{ 'err': PredictMatchOutcomeError };
export interface ProportionalBidPrize {
  'kind': PropotionalBidPrizeKind,
  'description': string,
  'amount': bigint,
}
export interface ProportionalBidScenario { 'prize': ProportionalBidPrize }
export interface ProportionalBidScenarioOutcome {
  'bids': Array<ProportionalWinningBid>,
}
export interface ProportionalWinningBid {
  'proportion': bigint,
  'townId': bigint,
}
export interface Proposal {
  'id': bigint,
  'content': ProposalContent,
  'timeStart': bigint,
  'votes': Array<[Principal, Vote]>,
  'statusLog': Array<ProposalStatusLogEntry>,
  'endTimerId': [] | [bigint],
  'timeEnd': bigint,
  'proposerId': Principal,
}
export type ProposalContent = { 'train': TrainContent } |
{ 'changeLogo': ChangeTownLogoContent } |
{ 'changeName': ChangeTownNameContent } |
{ 'changeMotto': ChangeTownMottoContent } |
{ 'modifyLink': ModifyTownLinkContent } |
{ 'changeColor': ChangeTownColorContent } |
{ 'swapPlayerPositions': SwapPlayerPositionsContent } |
{ 'motion': MotionContent } |
{ 'changeDescription': ChangeTownDescriptionContent };
export type ProposalContent__1 = {
  'changeTownColor': ChangeTownColorContent__1
} |
{ 'changeTownDescription': ChangeTownDescriptionContent__1 } |
{ 'changeTownLogo': ChangeTownLogoContent__1 } |
{ 'changeTownName': ChangeTownNameContent__1 } |
{ 'motion': MotionContent__1 } |
{ 'changeTownMotto': ChangeTownMottoContent__1 };
export type ProposalStatusLogEntry = {
  'failedToExecute': { 'time': Time, 'error': string }
} |
{ 'rejected': { 'time': Time } } |
{ 'executing': { 'time': Time } } |
{ 'executed': { 'time': Time } };
export type PropotionalBidPrizeKind = { 'skill': PropotionalBidPrizeSkill };
export interface PropotionalBidPrizeSkill {
  'duration': Duration,
  'skill': ChosenOrRandomSkill,
  'position': TargetPosition,
}
export type Result = { 'ok': null } |
{ 'err': JoinLeagueError };
export type Result_1 = { 'ok': Player } |
{ 'err': GetPositionError };
export type Result_2 = { 'ok': null } |
{ 'err': AssignUserToTownError };
export interface RoundLog { 'turns': Array<TurnLog> }
export interface Scenario {
  'id': bigint,
  'startTime': bigint,
  'title': string,
  'endTime': bigint,
  'kind': ScenarioKind,
  'description': string,
  'undecidedEffect': Effect,
  'state': ScenarioState,
}
export type ScenarioKind = { 'lottery': LotteryScenario } |
{ 'noLeagueEffect': NoLeagueEffectScenario } |
{ 'threshold': ThresholdScenario } |
{ 'textInput': TextInputScenario } |
{ 'proportionalBid': ProportionalBidScenario } |
{ 'leagueChoice': LeagueChoiceScenario };
export type ScenarioKindRequest = { 'lottery': LotteryScenario } |
{ 'noLeagueEffect': NoLeagueEffectScenarioRequest } |
{ 'threshold': ThresholdScenarioRequest } |
{ 'textInput': TextInputScenario } |
{ 'proportionalBid': ProportionalBidScenario } |
{ 'leagueChoice': LeagueChoiceScenarioRequest };
export interface ScenarioOptionDiscrete {
  'title': string,
  'townEffect': Effect,
  'description': string,
  'traitRequirements': Array<TraitRequirement>,
  'currencyCost': bigint,
  'allowedTownIds': Array<bigint>,
}
export interface ScenarioOptionDiscrete__1 {
  'title': string,
  'townEffect': Effect,
  'description': string,
  'traitRequirements': Array<TraitRequirement>,
  'currencyCost': bigint,
}
export type ScenarioOptionValue = { 'id': bigint } |
{ 'nat': bigint } |
{ 'text': string };
export type ScenarioOutcome = { 'lottery': LotteryScenarioOutcome } |
{ 'noLeagueEffect': null } |
{ 'threshold': ThresholdScenarioOutcome } |
{ 'textInput': TextInputScenarioOutcome } |
{ 'proportionalBid': ProportionalBidScenarioOutcome } |
{ 'leagueChoice': LeagueChoiceScenarioOutcome };
export interface ScenarioResolvedOptionDiscrete {
  'id': bigint,
  'title': string,
  'townEffect': Effect,
  'seenByTownIds': Array<bigint>,
  'description': string,
  'traitRequirements': Array<TraitRequirement>,
  'chosenByTownIds': Array<bigint>,
  'currencyCost': bigint,
}
export interface ScenarioResolvedOptionRaw {
  'value': bigint,
  'chosenByTownIds': Array<bigint>,
}
export interface ScenarioResolvedOptionRaw_1 {
  'value': string,
  'chosenByTownIds': Array<bigint>,
}
export interface ScenarioResolvedOptions {
  'undecidedOption': {
    'townEffect': Effect,
    'chosenByTownIds': Array<bigint>,
  },
  'kind': ScenarioResolvedOptionsKind,
}
export type ScenarioResolvedOptionsKind = {
  'nat': Array<ScenarioResolvedOptionRaw>
} |
{ 'text': Array<ScenarioResolvedOptionRaw_1> } |
{ 'discrete': Array<ScenarioResolvedOptionDiscrete> };
export type ScenarioState = { 'notStarted': null } |
{ 'resolved': ScenarioStateResolved } |
{ 'resolving': null } |
{ 'inProgress': null };
export interface ScenarioStateResolved {
  'scenarioOutcome': ScenarioOutcome,
  'options': ScenarioResolvedOptions,
  'effectOutcomes': Array<EffectOutcome>,
}
export interface ScenarioTownOptionDiscrete {
  'id': bigint,
  'title': string,
  'description': string,
  'traitRequirements': Array<TraitRequirement>,
  'currentVotingPower': bigint,
  'currencyCost': bigint,
}
export interface ScenarioTownOptionNat {
  'value': bigint,
  'currentVotingPower': bigint,
}
export interface ScenarioTownOptionText {
  'value': string,
  'currentVotingPower': bigint,
}
export type ScenarioTownOptions = { 'nat': Array<ScenarioTownOptionNat> } |
{ 'text': Array<ScenarioTownOptionText> } |
{ 'discrete': Array<ScenarioTownOptionDiscrete> };
export interface ScenarioVote {
  'value': [] | [ScenarioOptionValue],
  'townOptions': ScenarioTownOptions,
  'votingPower': bigint,
  'townId': bigint,
  'townVotingPower': TownVotingPower,
}
export interface ScheduledMatch {
  'town1': ScheduledTownInfo,
  'town2': ScheduledTownInfo,
}
export interface ScheduledMatchGroup {
  'time': Time,
  'matches': Array<ScheduledMatch>,
  'timerId': bigint,
}
export interface ScheduledTownInfo { 'id': bigint }
export type SeasonStatus = { 'notStarted': null } |
{ 'completed': CompletedSeason } |
{ 'inProgress': InProgressSeason };
export type SetBenevolentDictatorStateError = { 'notAuthorized': null };
export type SetBenevolentDictatorStateResult = { 'ok': null } |
{ 'err': SetBenevolentDictatorStateError };
export type Skill = { 'battingAccuracy': null } |
{ 'throwingAccuracy': null } |
{ 'speed': null } |
{ 'catching': null } |
{ 'battingPower': null } |
{ 'defense': null } |
{ 'throwingPower': null };
export interface SkillEffect {
  'duration': Duration,
  'skill': ChosenOrRandomSkill,
  'position': TargetPosition,
  'delta': bigint,
}
export interface SkillPlayerEffectOutcome {
  'duration': Duration,
  'skill': Skill,
  'position': TargetPositionInstance,
  'delta': bigint,
}
export interface Skills {
  'battingAccuracy': bigint,
  'throwingAccuracy': bigint,
  'speed': bigint,
  'catching': bigint,
  'battingPower': bigint,
  'defense': bigint,
  'throwingPower': bigint,
}
export type StartMatchError = { 'notEnoughPlayers': TownIdOrBoth };
export type StartMatchGroupError = { 'notAuthorized': null } |
{ 'notScheduledYet': null } |
{ 'matchGroupNotFound': null } |
{ 'alreadyStarted': null } |
{ 'matchErrors': Array<{ 'error': StartMatchError, 'matchId': bigint }> };
export type StartMatchGroupResult = { 'ok': null } |
{ 'err': StartMatchGroupError };
export type StartSeasonError = { 'notAuthorized': null } |
{ 'seedGenerationError': string } |
{ 'alreadyStarted': null } |
{ 'idTaken': null } |
{ 'invalidArgs': string };
export interface StartSeasonRequest {
  'startTime': Time,
  'weekDays': Array<DayOfWeek>,
}
export type StartSeasonResult = { 'ok': null } |
{ 'err': StartSeasonError };
export interface SwapPlayerPositionsContent {
  'position1': FieldPosition,
  'position2': FieldPosition,
}
export interface TargetPosition {
  'town': TargetTown,
  'position': ChosenOrRandomFieldPosition,
}
export interface TargetPositionInstance {
  'townId': bigint,
  'position': FieldPosition,
}
export type TargetTown = { 'all': null } |
{ 'contextual': null } |
{ 'random': bigint } |
{ 'chosen': Array<bigint> };
export interface Town {
  'id': bigint,
  'motto': string,
  'traits': Array<Trait>,
  'name': string,
  'color': [number, number, number],
  'description': string,
  'links': Array<Link>,
  'entropy': bigint,
  'logoUrl': string,
  'currency': bigint,
}
export type TownAssignment = { 'winnerOfMatch': bigint } |
{ 'predetermined': bigint } |
{ 'seasonStandingIndex': bigint };
export type TownId = { 'town1': null } |
{ 'town2': null };
export type TownIdOrBoth = { 'town1': null } |
{ 'town2': null } |
{ 'bothTowns': null };
export type TownIdOrTie = { 'tie': null } |
{ 'town1': null } |
{ 'town2': null };
export interface TownPositions {
  'rightField': number,
  'leftField': number,
  'thirdBase': number,
  'pitcher': number,
  'secondBase': number,
  'shortStop': number,
  'centerField': number,
  'firstBase': number,
}
export interface TownProposal {
  'id': bigint,
  'content': ProposalContent,
  'timeStart': bigint,
  'votes': Array<[Principal, Vote]>,
  'statusLog': Array<ProposalStatusLogEntry>,
  'endTimerId': [] | [bigint],
  'timeEnd': bigint,
  'proposerId': Principal,
}
export type TownProposalContent = { 'train': TrainContent } |
{ 'changeLogo': ChangeTownLogoContent } |
{ 'changeName': ChangeTownNameContent } |
{ 'changeMotto': ChangeTownMottoContent } |
{ 'modifyLink': ModifyTownLinkContent } |
{ 'changeColor': ChangeTownColorContent } |
{ 'swapPlayerPositions': SwapPlayerPositionsContent } |
{ 'motion': MotionContent } |
{ 'changeDescription': ChangeTownDescriptionContent };
export interface TownStandingInfo {
  'id': bigint,
  'wins': bigint,
  'losses': bigint,
  'totalScore': bigint,
}
export interface TownStats {
  'id': bigint,
  'totalPoints': bigint,
  'ownerCount': bigint,
  'userCount': bigint,
}
export interface TownTraitEffect {
  'kind': TownTraitEffectKind,
  'town': TargetTown,
  'traitId': string,
}
export type TownTraitEffectKind = { 'add': null } |
{ 'remove': null };
export interface TownTraitTownEffectOutcome {
  'kind': TownTraitEffectKind,
  'traitId': string,
  'townId': bigint,
}
export interface TownVotingPower { 'total': bigint, 'voted': bigint }
export interface TextInputScenario { 'description': string }
export interface TextInputScenarioOutcome { 'text': string }
export interface ThresholdContribution { 'townId': bigint, 'amount': bigint }
export interface ThresholdScenario {
  'failure': { 'description': string, 'effect': Effect },
  'minAmount': bigint,
  'success': { 'description': string, 'effect': Effect },
  'options': Array<ThresholdScenarioOption>,
  'undecidedAmount': ThresholdValue,
}
export interface ThresholdScenarioOption {
  'title': string,
  'value': ThresholdValue,
  'townEffect': Effect,
  'description': string,
  'traitRequirements': Array<TraitRequirement>,
  'currencyCost': bigint,
  'allowedTownIds': Array<bigint>,
}
export interface ThresholdScenarioOptionRequest {
  'title': string,
  'value': ThresholdValue__1,
  'townEffect': Effect,
  'description': string,
  'traitRequirements': Array<TraitRequirement>,
  'currencyCost': bigint,
}
export interface ThresholdScenarioOutcome {
  'contributions': Array<ThresholdContribution>,
  'successful': boolean,
}
export interface ThresholdScenarioRequest {
  'failure': { 'description': string, 'effect': Effect },
  'minAmount': bigint,
  'success': { 'description': string, 'effect': Effect },
  'options': Array<ThresholdScenarioOptionRequest>,
  'undecidedAmount': ThresholdValue__1,
}
export type ThresholdValue = { 'fixed': bigint } |
{
  'weightedChance': Array<
    { 'weight': bigint, 'value': bigint, 'description': string }
  >
};
export type ThresholdValue__1 = { 'fixed': bigint } |
{
  'weightedChance': Array<
    { 'weight': bigint, 'value': bigint, 'description': string }
  >
};
export type Time = bigint;
export interface TrainContent { 'skill': Skill, 'position': FieldPosition }
export interface Trait {
  'id': string,
  'name': string,
  'description': string,
}
export interface TraitRequirement {
  'id': string,
  'kind': TraitRequirementKind,
}
export type TraitRequirementKind = { 'prohibited': null } |
{ 'required': null };
export interface TurnLog { 'events': Array<MatchEvent> }
export interface User {
  'id': Principal,
  'membership': [] | [UserMembership],
  'points': bigint,
}
export interface UserMembership { 'votingPower': bigint, 'townId': bigint }
export interface UserStats {
  'towns': Array<TownStats>,
  'townOwnerCount': bigint,
  'totalPoints': bigint,
  'userCount': bigint,
}
export interface UserVotingInfo {
  'id': Principal,
  'votingPower': bigint,
  'townId': bigint,
}
export interface Vote { 'value': [] | [boolean], 'votingPower': bigint }
export type VoteOnLeagueProposalError = { 'proposalNotFound': null } |
{ 'notAuthorized': null } |
{ 'alreadyVoted': null } |
{ 'votingClosed': null };
export interface VoteOnLeagueProposalRequest {
  'vote': boolean,
  'proposalId': bigint,
}
export type VoteOnLeagueProposalResult = { 'ok': null } |
{ 'err': VoteOnLeagueProposalError };
export type VoteOnScenarioError = { 'votingNotOpen': null } |
{ 'invalidValue': null } |
{ 'notEligible': null } |
{ 'scenarioNotFound': null };
export interface VoteOnScenarioRequest {
  'scenarioId': bigint,
  'value': ScenarioOptionValue,
}
export type VoteOnScenarioResult = { 'ok': null } |
{ 'err': VoteOnScenarioError };
export type VoteOnTownProposalError = { 'proposalNotFound': null } |
{ 'notAuthorized': null } |
{ 'alreadyVoted': null } |
{ 'votingClosed': null } |
{ 'townNotFound': null };
export interface VoteOnTownProposalRequest {
  'vote': boolean,
  'proposalId': bigint,
}
export type VoteOnTownProposalResult = { 'ok': null } |
{ 'err': VoteOnTownProposalError };
export interface VotingData {
  'townIdsWithConsensus': Array<bigint>,
  'yourData': [] | [ScenarioVote],
}
export interface WeightedEffect {
  'weight': bigint,
  'description': string,
  'effect': Effect,
}
export interface _SERVICE {
  'addFluff': ActorMethod<[CreatePlayerFluffRequest], CreatePlayerFluffResult>,
  'addScenario': ActorMethod<[AddScenarioRequest], AddScenarioResult>,
  'assignUserToTown': ActorMethod<[AssignUserToTownRequest], Result_2>,
  'claimBenevolentDictatorRole': ActorMethod<
    [],
    ClaimBenevolentDictatorRoleResult
  >,
  'closeSeason': ActorMethod<[], CloseSeasonResult>,
  'createLeagueProposal': ActorMethod<
    [CreateLeagueProposalRequest],
    CreateLeagueProposalResult
  >,
  'createTown': ActorMethod<[CreateTownRequest], CreateTownResult>,
  'createTownProposal': ActorMethod<
    [bigint, TownProposalContent],
    CreateTownProposalResult
  >,
  'createTownTrait': ActorMethod<
    [CreateTownTraitRequest],
    CreateTownTraitResult
  >,
  'getAllPlayers': ActorMethod<[], Array<Player>>,
  'getBenevolentDictatorState': ActorMethod<[], BenevolentDictatorState>,
  'getLeagueData': ActorMethod<[], LeagueData>,
  'getLeagueProposal': ActorMethod<[bigint], GetLeagueProposalResult>,
  'getLeagueProposals': ActorMethod<
    [bigint, bigint],
    GetLeagueProposalsResult
  >,
  'getLiveMatchGroupState': ActorMethod<[], [] | [LiveMatchGroupState]>,
  'getMatchGroupPredictions': ActorMethod<
    [bigint],
    GetMatchGroupPredictionsResult
  >,
  'getPlayer': ActorMethod<[number], GetPlayerResult>,
  'getPosition': ActorMethod<[bigint, FieldPosition], Result_1>,
  'getScenario': ActorMethod<[bigint], GetScenarioResult>,
  'getScenarioVote': ActorMethod<
    [GetScenarioVoteRequest],
    GetScenarioVoteResult
  >,
  'getScenarios': ActorMethod<[], GetScenariosResult>,
  'getSeasonStatus': ActorMethod<[], SeasonStatus>,
  'getTownOwners': ActorMethod<[GetTownOwnersRequest], GetTownOwnersResult>,
  'getTownPlayers': ActorMethod<[bigint], Array<Player>>,
  'getTownProposal': ActorMethod<[bigint, bigint], GetTownProposalResult>,
  'getTownProposals': ActorMethod<
    [bigint, bigint, bigint],
    GetTownProposalsResult
  >,
  'getTownStandings': ActorMethod<[], GetTownStandingsResult>,
  'getTowns': ActorMethod<[], Array<Town>>,
  'getTraits': ActorMethod<[], Array<Trait>>,
  'getUser': ActorMethod<[Principal], GetUserResult>,
  'getUserLeaderboard': ActorMethod<
    [GetUserLeaderboardRequest],
    GetUserLeaderboardResult
  >,
  'getUserStats': ActorMethod<[], GetUserStatsResult>,
  'joinLeague': ActorMethod<[], Result>,
  'predictMatchOutcome': ActorMethod<
    [PredictMatchOutcomeRequest],
    PredictMatchOutcomeResult
  >,
  'setBenevolentDictatorState': ActorMethod<
    [BenevolentDictatorState],
    SetBenevolentDictatorStateResult
  >,
  'startNextMatchGroup': ActorMethod<[], StartMatchGroupResult>,
  'startSeason': ActorMethod<[StartSeasonRequest], StartSeasonResult>,
  'voteOnLeagueProposal': ActorMethod<
    [VoteOnLeagueProposalRequest],
    VoteOnLeagueProposalResult
  >,
  'voteOnScenario': ActorMethod<[VoteOnScenarioRequest], VoteOnScenarioResult>,
  'voteOnTownProposal': ActorMethod<
    [bigint, VoteOnTownProposalRequest],
    VoteOnTownProposalResult
  >,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
