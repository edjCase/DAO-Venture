import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface AddScenarioRequest {
  'id' : string,
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
export interface CreateProposalRequest { 'content' : ProposalContent }
export type CreateProposalResult = { 'ok' : bigint } |
  { 'notAuthorized' : null };
export interface CreateTeamRequest {
  'motto' : string,
  'name' : string,
  'color' : [number, number, number],
  'description' : string,
  'logoUrl' : string,
}
export type CreateTeamResult = { 'ok' : bigint } |
  { 'nameTaken' : null } |
  { 'noStadiumsExist' : null } |
  { 'notAuthorized' : null } |
  { 'teamsCallError' : string } |
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
export type GetProposalsResult = { 'ok' : Array<Proposal> };
export type GetScenarioResult = { 'ok' : Scenario } |
  { 'notStarted' : null } |
  { 'notFound' : null };
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
  'players' : Array<PlayerWithId>,
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
export interface PlayerWithId {
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
  'traitIds' : Array<string>,
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
    'changeTeamName' : { 'name' : string, 'teamId' : bigint }
  };
export type ProposalStatusLogEntry = {
    'failedToExecute' : { 'time' : Time, 'error' : string }
  } |
  { 'rejected' : { 'time' : Time } } |
  { 'executing' : { 'time' : Time } } |
  { 'executed' : { 'time' : Time } };
export interface Scenario {
  'id' : string,
  'title' : string,
  'description' : string,
  'state' : { 'notStarted' : null } |
    { 'resolved' : ScenarioStateResolved } |
    { 'inProgress' : null },
  'options' : Array<ScenarioOption>,
}
export interface ScenarioOption { 'title' : string, 'description' : string }
export interface ScenarioOptionWithEffect {
  'title' : string,
  'description' : string,
  'effect' : Effect,
}
export interface ScenarioStateResolved {
  'teamChoices' : Array<{ 'option' : bigint, 'teamId' : bigint }>,
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
export interface StartSeasonRequest { 'startTime' : Time }
export type StartSeasonResult = { 'ok' : null } |
  { 'invalidScenario' : { 'id' : string, 'errors' : Array<string> } } |
  { 'noStadiumsExist' : null } |
  { 'notAuthorized' : null } |
  { 'oddNumberOfTeams' : null } |
  { 'seedGenerationError' : string } |
  { 'alreadyStarted' : null } |
  { 'idTaken' : null } |
  { 'scenarioCountMismatch' : { 'actual' : bigint, 'expected' : bigint } } |
  { 'noTeams' : null };
export type Target = { 'teams' : Array<TargetTeam> } |
  { 'league' : null } |
  { 'positions' : Array<TargetPosition> };
export interface TargetPosition {
  'teamId' : TargetTeam,
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
export interface TeamWithId {
  'id' : bigint,
  'motto' : string,
  'name' : string,
  'color' : [number, number, number],
  'description' : string,
  'entropy' : bigint,
  'logoUrl' : string,
  'energy' : bigint,
}
export type Time = bigint;
export interface Vote { 'value' : [] | [boolean], 'votingPower' : bigint }
export interface VoteOnProposalRequest {
  'vote' : boolean,
  'proposalId' : bigint,
}
export type VoteOnProposalResult = { 'ok' : null } |
  { 'proposalNotFound' : null } |
  { 'notAuthorized' : null } |
  { 'alreadyVoted' : null } |
  { 'votingClosed' : null };
export interface _SERVICE {
  'addScenario' : ActorMethod<[AddScenarioRequest], AddScenarioResult>,
  'clearTeams' : ActorMethod<[], undefined>,
  'closeSeason' : ActorMethod<[], CloseSeasonResult>,
  'createProposal' : ActorMethod<[CreateProposalRequest], CreateProposalResult>,
  'createTeam' : ActorMethod<[CreateTeamRequest], CreateTeamResult>,
  'getMatchGroupPredictions' : ActorMethod<
    [bigint],
    GetMatchGroupPredictionsResult
  >,
  'getProposal' : ActorMethod<[bigint], GetProposalResult>,
  'getProposals' : ActorMethod<[], GetProposalsResult>,
  'getScenario' : ActorMethod<[string], GetScenarioResult>,
  'getScenarios' : ActorMethod<[], GetScenariosResult>,
  'getSeasonStatus' : ActorMethod<[], SeasonStatus>,
  'getTeamStandings' : ActorMethod<[], GetTeamStandingsResult>,
  'getTeams' : ActorMethod<[], Array<TeamWithId>>,
  'onMatchGroupComplete' : ActorMethod<
    [OnMatchGroupCompleteRequest],
    OnMatchGroupCompleteResult
  >,
  'predictMatchOutcome' : ActorMethod<
    [PredictMatchOutcomeRequest],
    PredictMatchOutcomeResult
  >,
  'startMatchGroup' : ActorMethod<[bigint], StartMatchGroupResult>,
  'startSeason' : ActorMethod<[StartSeasonRequest], StartSeasonResult>,
  'voteOnProposal' : ActorMethod<[VoteOnProposalRequest], VoteOnProposalResult>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
