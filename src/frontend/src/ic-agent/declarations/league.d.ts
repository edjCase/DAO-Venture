import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface AddScenarioRequest {
  'startTime' : Time,
  'title' : string,
  'endTime' : Time,
  'metaEffect' : MetaEffect,
  'teamIds' : Array<bigint>,
  'description' : string,
  'options' : Array<ScenarioOptionWithEffect>,
}
export type AddScenarioResult = { 'ok' : null } |
  { 'notAuthorized' : null } |
  { 'invalid' : Array<string> };
export type BenevolentDictatorState = { 'open' : null } |
  { 'claimed' : Principal } |
  { 'disabled' : null };
export type ClaimBenevolentDictatorRoleResult = { 'ok' : null } |
  { 'notOpenToClaim' : null };
export type CloseSeasonResult = { 'ok' : null } |
  { 'notAuthorized' : null } |
  { 'seasonNotOpen' : null };
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
export interface CreateTeamRequest {
  'motto' : string,
  'name' : string,
  'color' : [number, number, number],
  'description' : string,
  'logoUrl' : string,
}
export type CreateTeamResult = { 'ok' : bigint } |
  { 'nameTaken' : null } |
  { 'notAuthorized' : null } |
  { 'teamsCallError' : string };
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
  { 'noEffect' : null } |
  { 'oneOf' : Array<[bigint, Effect]> } |
  { 'entropy' : { 'target' : LeagueOrTeamsTarget, 'delta' : bigint } } |
  {
    'skill' : {
      'duration' : Duration,
      'skill' : Skill,
      'target' : Target,
      'delta' : bigint,
    }
  } |
  { 'injury' : { 'target' : Target, 'injury' : Injury } } |
  { 'energy' : { 'value' : { 'flat' : bigint }, 'team' : TargetTeam } };
export type EffectOutcome = {
    'entropy' : { 'teamId' : bigint, 'delta' : bigint }
  } |
  {
    'skill' : {
      'duration' : Duration,
      'skill' : Skill,
      'target' : TargetInstance,
      'delta' : bigint,
    }
  } |
  { 'injury' : { 'target' : TargetInstance, 'injury' : Injury } } |
  { 'energy' : { 'teamId' : bigint, 'delta' : bigint } };
export type FieldPosition = { 'rightField' : null } |
  { 'leftField' : null } |
  { 'thirdBase' : null } |
  { 'pitcher' : null } |
  { 'secondBase' : null } |
  { 'shortStop' : null } |
  { 'centerField' : null } |
  { 'firstBase' : null };
export type GetMatchGroupPredictionsResult = {
    'ok' : MatchGroupPredictionSummary
  } |
  { 'notFound' : null };
export type GetProposalResult = { 'ok' : Proposal } |
  { 'proposalNotFound' : null };
export type GetProposalsResult = { 'ok' : PagedResult };
export type GetScenarioResult = { 'ok' : Scenario } |
  { 'notStarted' : null } |
  { 'notFound' : null };
export interface GetScenarioVoteRequest { 'scenarioId' : bigint }
export type GetScenarioVoteResult = { 'ok' : ScenarioVote } |
  { 'notEligible' : null } |
  { 'scenarioNotFound' : null };
export type GetScenariosResult = { 'ok' : Array<Scenario> };
export type GetTeamStandingsResult = { 'ok' : Array<TeamStandingInfo> } |
  { 'notFound' : null };
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
export type Injury = { 'twistedAnkle' : null } |
  { 'brokenArm' : null } |
  { 'brokenLeg' : null } |
  { 'concussion' : null };
export type LeagueOrTeamsTarget = { 'teams' : Array<TargetTeam> } |
  { 'league' : null };
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
export type MetaEffect = {
    'lottery' : { 'prize' : Effect, 'options' : Array<{ 'tickets' : bigint }> }
  } |
  { 'noEffect' : null } |
  {
    'threshold' : {
      'threshold' : bigint,
      'over' : Effect,
      'under' : Effect,
      'options' : Array<
        {
          'value' : { 'fixed' : bigint } |
            { 'weightedChance' : Array<[bigint, bigint]> },
        }
      >,
    }
  } |
  {
    'proportionalBid' : {
      'prize' : {
        'kind' : {
            'skill' : {
              'duration' : Duration,
              'skill' : Skill,
              'target' : { 'position' : FieldPosition },
            }
          },
        'amount' : bigint,
      },
      'options' : Array<{ 'bidValue' : bigint }>,
    }
  } |
  { 'leagueChoice' : { 'options' : Array<{ 'effect' : Effect }> } };
export interface NotScheduledMatch {
  'team1' : TeamAssignment,
  'team2' : TeamAssignment,
}
export interface NotScheduledMatchGroup {
  'time' : Time,
  'matches' : Array<NotScheduledMatch>,
}
export interface OnMatchGroupCompleteRequest {
  'id' : bigint,
  'matches' : Array<CompletedMatch>,
  'playerStats' : Array<PlayerMatchStatsWithId>,
}
export type OnMatchGroupCompleteResult = { 'ok' : null } |
  { 'notAuthorized' : null } |
  { 'seedGenerationError' : string } |
  { 'matchGroupNotFound' : null } |
  { 'seasonNotOpen' : null } |
  { 'matchGroupNotInProgress' : null };
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
export interface PredictMatchOutcomeRequest {
  'winner' : [] | [TeamId],
  'matchId' : bigint,
}
export type PredictMatchOutcomeResult = { 'ok' : null } |
  { 'predictionsClosed' : null } |
  { 'matchNotFound' : null } |
  { 'matchGroupNotFound' : null } |
  { 'identityRequired' : null };
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
export interface Scenario {
  'id' : bigint,
  'startTime' : bigint,
  'title' : string,
  'endTime' : bigint,
  'metaEffect' : MetaEffect,
  'description' : string,
  'state' : ScenarioState,
  'options' : Array<ScenarioOptionWithEffect>,
}
export interface ScenarioOptionWithEffect {
  'title' : string,
  'description' : string,
  'effect' : Effect,
  'energyCost' : bigint,
}
export type ScenarioState = { 'notStarted' : null } |
  { 'resolved' : ScenarioStateResolved } |
  { 'inProgress' : null };
export interface ScenarioStateResolved {
  'teamChoices' : Array<{ 'option' : bigint, 'teamId' : bigint }>,
  'effectOutcomes' : Array<EffectOutcome>,
}
export interface ScenarioVote {
  'option' : [] | [bigint],
  'votingPower' : bigint,
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
export type SetBenevolentDictatorStateResult = { 'ok' : null } |
  { 'notAuthorized' : null };
export type Skill = { 'battingAccuracy' : null } |
  { 'throwingAccuracy' : null } |
  { 'speed' : null } |
  { 'catching' : null } |
  { 'battingPower' : null } |
  { 'defense' : null } |
  { 'throwingPower' : null };
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
export type StartMatchGroupResult = { 'ok' : null } |
  { 'notAuthorized' : null } |
  { 'notScheduledYet' : null } |
  { 'matchGroupNotFound' : null } |
  { 'alreadyStarted' : null } |
  { 'matchErrors' : Array<{ 'error' : StartMatchError, 'matchId' : bigint }> };
export interface StartSeasonRequest {
  'startTime' : Time,
  'weekDays' : Array<DayOfWeek>,
}
export type StartSeasonResult = { 'ok' : null } |
  { 'notAuthorized' : null } |
  { 'seedGenerationError' : string } |
  { 'alreadyStarted' : null } |
  { 'idTaken' : null } |
  { 'invalidArgs' : string };
export type Target = { 'teams' : Array<TargetTeam> } |
  { 'league' : null } |
  { 'positions' : Array<TargetPosition> };
export type TargetInstance = { 'teams' : Array<bigint> } |
  { 'league' : null } |
  { 'positions' : Array<TargetPositionInstance> };
export interface TargetPosition {
  'teamId' : TargetTeam,
  'position' : FieldPosition,
}
export interface TargetPositionInstance {
  'teamId' : bigint,
  'position' : FieldPosition,
}
export type TargetTeam = { 'choosingTeam' : null };
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
export type Time = bigint;
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
export interface VoteOnScenarioRequest {
  'scenarioId' : bigint,
  'option' : bigint,
}
export type VoteOnScenarioResult = { 'ok' : null } |
  { 'invalidOption' : null } |
  { 'alreadyVoted' : null } |
  { 'votingNotOpen' : null } |
  { 'notEligible' : null } |
  { 'scenarioNotFound' : null };
export interface _SERVICE {
  'addScenario' : ActorMethod<[AddScenarioRequest], AddScenarioResult>,
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
