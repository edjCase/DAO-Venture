import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

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
  'scenario' : ResolvedScenario,
}
export interface CompletedMatchTeam {
  'id' : Principal,
  'name' : string,
  'score' : bigint,
  'logoUrl' : string,
  'positions' : TeamPositions,
}
export interface CompletedSeason {
  'teams' : Array<CompletedSeasonTeam>,
  'runnerUpTeamId' : Principal,
  'matchGroups' : Array<CompletedMatchGroup>,
  'championTeamId' : Principal,
}
export interface CompletedSeasonTeam {
  'id' : Principal,
  'name' : string,
  'wins' : bigint,
  'losses' : bigint,
  'totalScore' : bigint,
  'logoUrl' : string,
}
export interface CreateTeamRequest {
  'motto' : string,
  'name' : string,
  'color' : [number, number, number],
  'description' : string,
  'logoUrl' : string,
}
export type CreateTeamResult = { 'ok' : Principal } |
  { 'nameTaken' : null } |
  { 'noStadiumsExist' : null } |
  { 'notAuthorized' : null } |
  { 'teamFactoryCallError' : string } |
  { 'populateTeamRosterCallError' : string };
export type Duration = { 'matches' : bigint } |
  { 'indefinite' : null };
export type Effect = { 'allOf' : Array<Effect> } |
  { 'noEffect' : null } |
  { 'oneOf' : Array<[bigint, Effect]> } |
  { 'entropy' : { 'team' : TargetTeam, 'delta' : bigint } } |
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
    'entropy' : { 'teamId' : Principal, 'delta' : bigint }
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
  { 'energy' : { 'teamId' : Principal, 'delta' : bigint } };
export type FieldPosition = { 'rightField' : null } |
  { 'leftField' : null } |
  { 'thirdBase' : null } |
  { 'pitcher' : null } |
  { 'secondBase' : null } |
  { 'shortStop' : null } |
  { 'centerField' : null } |
  { 'firstBase' : null };
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
  'scenario' : ResolvedScenario,
}
export interface InProgressSeason {
  'matchGroups' : Array<InProgressSeasonMatchGroupVariant>,
}
export type InProgressSeasonMatchGroupVariant = {
    'scheduled' : ScheduledMatchGroup
  } |
  { 'completed' : CompletedMatchGroup } |
  { 'inProgress' : InProgressMatchGroup } |
  { 'notScheduled' : NotScheduledMatchGroup };
export interface InProgressTeam {
  'id' : Principal,
  'name' : string,
  'logoUrl' : string,
  'positions' : TeamPositions,
}
export type Injury = { 'twistedAnkle' : null } |
  { 'brokenArm' : null } |
  { 'brokenLeg' : null } |
  { 'concussion' : null };
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
export interface NotScheduledMatch {
  'team1' : TeamAssignment,
  'team2' : TeamAssignment,
}
export interface NotScheduledMatchGroup {
  'time' : Time,
  'matches' : Array<NotScheduledMatch>,
  'scenario' : Scenario,
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
  'matchId' : number,
}
export type PredictMatchOutcomeResult = { 'ok' : null } |
  { 'predictionsClosed' : null } |
  { 'matchNotFound' : null } |
  { 'matchGroupNotFound' : null } |
  { 'identityRequired' : null };
export type ProcessEffectOutcomesResult = { 'ok' : null } |
  { 'notAuthorized' : null } |
  { 'seasonNotInProgress' : null };
export interface ResolvedScenario {
  'id' : string,
  'title' : string,
  'teamChoices' : Array<{ 'choiceIndex' : number, 'teamId' : Principal }>,
  'description' : string,
  'effect' : {
      'lottery' : {
        'prize' : Effect,
        'options' : Array<{ 'tickets' : bigint }>,
      }
    } |
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
    { 'pickASide' : { 'options' : Array<{ 'sideId' : string }> } } |
    {
      'proportionalBid' : {
        'prize' : {
            'skill' : {
              'total' : bigint,
              'duration' : Duration,
              'skill' : Skill,
              'target' : { 'position' : FieldPosition },
            }
          },
        'options' : Array<{ 'bidValue' : bigint }>,
      }
    } |
    { 'simple' : null } |
    { 'leagueChoice' : { 'options' : Array<{ 'effect' : Effect }> } },
  'options' : Array<ScenarioOption>,
  'effectOutcomes' : Array<EffectOutcome>,
}
export interface Scenario {
  'id' : string,
  'title' : string,
  'description' : string,
  'effect' : {
      'lottery' : {
        'prize' : Effect,
        'options' : Array<{ 'tickets' : bigint }>,
      }
    } |
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
    { 'pickASide' : { 'options' : Array<{ 'sideId' : string }> } } |
    {
      'proportionalBid' : {
        'prize' : {
            'skill' : {
              'total' : bigint,
              'duration' : Duration,
              'skill' : Skill,
              'target' : { 'position' : FieldPosition },
            }
          },
        'options' : Array<{ 'bidValue' : bigint }>,
      }
    } |
    { 'simple' : null } |
    { 'leagueChoice' : { 'options' : Array<{ 'effect' : Effect }> } },
  'options' : Array<ScenarioOption>,
}
export interface ScenarioOption {
  'title' : string,
  'description' : string,
  'effect' : Effect,
}
export interface ScheduledMatch {
  'team1' : ScheduledTeamInfo,
  'team2' : ScheduledTeamInfo,
  'aura' : MatchAuraWithMetaData,
}
export interface ScheduledMatchGroup {
  'time' : Time,
  'matches' : Array<ScheduledMatch>,
  'scenario' : Scenario,
  'timerId' : bigint,
}
export interface ScheduledTeamInfo {
  'id' : Principal,
  'name' : string,
  'logoUrl' : string,
}
export type SeasonStatus = { 'notStarted' : null } |
  { 'starting' : null } |
  { 'completed' : CompletedSeason } |
  { 'inProgress' : InProgressSeason };
export type SetUserIsAdminResult = { 'ok' : null } |
  { 'notAuthorized' : null };
export type Skill = { 'battingAccuracy' : null } |
  { 'throwingAccuracy' : null } |
  { 'speed' : null } |
  { 'catching' : null } |
  { 'battingPower' : null } |
  { 'defense' : null } |
  { 'throwingPower' : null };
export type StartMatchError = { 'notEnoughPlayers' : TeamIdOrBoth };
export type StartMatchGroupResult = { 'ok' : null } |
  { 'notAuthorized' : null } |
  { 'notScheduledYet' : null } |
  { 'matchGroupNotFound' : null } |
  { 'alreadyStarted' : null } |
  { 'matchErrors' : Array<{ 'error' : StartMatchError, 'matchId' : bigint }> };
export interface StartSeasonRequest {
  'startTime' : Time,
  'scenarios' : Array<Scenario>,
}
export type StartSeasonResult = { 'ok' : null } |
  { 'invalidScenario' : { 'id' : string, 'errors' : Array<string> } } |
  { 'noStadiumsExist' : null } |
  { 'notAuthorized' : null } |
  { 'oddNumberOfTeams' : null } |
  { 'seedGenerationError' : string } |
  { 'alreadyStarted' : null } |
  { 'scenarioCountMismatch' : { 'actual' : bigint, 'expected' : bigint } } |
  { 'noTeams' : null };
export type Target = { 'teams' : Array<TargetTeam> } |
  { 'players' : Array<TargetPlayer> } |
  { 'league' : null };
export type TargetInstance = { 'teams' : Array<Principal> } |
  { 'players' : Uint32Array | number[] } |
  { 'league' : null };
export type TargetPlayer = { 'position' : FieldPosition };
export type TargetTeam = { 'choosingTeam' : null };
export type TeamAssignment = { 'winnerOfMatch' : bigint } |
  { 'predetermined' : TeamInfo } |
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
  'id' : Principal,
  'name' : string,
  'logoUrl' : string,
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
  'id' : Principal,
  'wins' : bigint,
  'losses' : bigint,
  'totalScore' : bigint,
}
export interface TeamWithId {
  'id' : Principal,
  'motto' : string,
  'name' : string,
  'color' : [number, number, number],
  'description' : string,
  'entropy' : bigint,
  'logoUrl' : string,
  'energy' : bigint,
}
export type Time = bigint;
export interface UpcomingMatchPrediction {
  'team1' : bigint,
  'team2' : bigint,
  'yourVote' : [] | [TeamId],
}
export type UpcomingMatchPredictionsResult = {
    'ok' : Array<UpcomingMatchPrediction>
  } |
  { 'noUpcomingMatches' : null };
export type UpdateLeagueCanistersResult = { 'ok' : null } |
  { 'notAuthorized' : null };
export interface _SERVICE {
  'clearTeams' : ActorMethod<[], undefined>,
  'closeSeason' : ActorMethod<[], CloseSeasonResult>,
  'createTeam' : ActorMethod<[CreateTeamRequest], CreateTeamResult>,
  'getAdmins' : ActorMethod<[], Array<Principal>>,
  'getSeasonStatus' : ActorMethod<[], SeasonStatus>,
  'getTeamStandings' : ActorMethod<[], GetTeamStandingsResult>,
  'getTeams' : ActorMethod<[], Array<TeamWithId>>,
  'getUpcomingMatchPredictions' : ActorMethod<
    [],
    UpcomingMatchPredictionsResult
  >,
  'onMatchGroupComplete' : ActorMethod<
    [OnMatchGroupCompleteRequest],
    OnMatchGroupCompleteResult
  >,
  'predictMatchOutcome' : ActorMethod<
    [PredictMatchOutcomeRequest],
    PredictMatchOutcomeResult
  >,
  'processEffectOutcomes' : ActorMethod<
    [Array<EffectOutcome>],
    ProcessEffectOutcomesResult
  >,
  'setUserIsAdmin' : ActorMethod<[Principal, boolean], SetUserIsAdminResult>,
  'startMatchGroup' : ActorMethod<[bigint], StartMatchGroupResult>,
  'startSeason' : ActorMethod<[StartSeasonRequest], StartSeasonResult>,
  'updateLeagueCanisters' : ActorMethod<[], UpdateLeagueCanistersResult>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
