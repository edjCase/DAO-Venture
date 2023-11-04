import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import { createActor } from './Actor';
import type { InterfaceFactory } from '@dfinity/candid/lib/cjs/idl';
import { IDL } from '@dfinity/candid';
import {
  type PlayerSkills,
  PlayerSkillsIdl,
  type FieldPosition,
  FieldPositionIdl,
} from "./PlayerLedger";

export type Time = bigint;
export const TimeIdl = IDL.Int;

export type MatchTeam = {
  'id': Principal;
  'name': Text;
  'predictionVotes': bigint;
};
export const MatchTeamIdl = IDL.Record({
  'id': IDL.Principal,
  'name': IDL.Text,
  'predictionVotes': IDL.Nat
});

export type Offering =
  | { 'shuffleAndBoost': null };
export const OfferingIdl = IDL.Variant({
  'shuffleAndBoost': IDL.Null
});

export type MatchAura =
  | { 'lowGravity': null }
  | { 'explodingBalls': null }
  | { 'fastBallsHardHits': null }
  | { 'highBlessingsAndCurses': null };
export const MatchAuraIdl = IDL.Variant({
  'lowGravity': IDL.Null,
  'explodingBalls': IDL.Null,
  'fastBallsHardHits': IDL.Null,
  'highBlessingsAndCurses': IDL.Null
});

export type TeamId =
  | { 'team1': null }
  | { 'team2': null };
export const TeamIdIdl = IDL.Variant({
  'team1': IDL.Null,
  'team2': IDL.Null
});

export type TeamState = {
  'id': Principal;
  'name': string;
  'score': bigint;
  'offering': Offering;
  'champion': number;
};
export const TeamStateIdl = IDL.Record({
  'id': IDL.Principal,
  'name': IDL.Text,
  'score': IDL.Int,
  'offering': OfferingIdl,
  'champion': IDL.Nat32
});

export type Injury =
  | { 'twistedAnkle': null }
  | { 'brokenLeg': null }
  | { 'brokenArm': null }
  | { 'concussion': null };
export const InjuryIdl = IDL.Variant({
  'twistedAnkle': IDL.Null,
  'brokenLeg': IDL.Null,
  'brokenArm': IDL.Null,
  'concussion': IDL.Null
});


export type PlayerCondition =
  | { 'ok': null }
  | { 'injured': Injury }
  | { 'dead': null };
export const PlayerConditionIdl = IDL.Variant({
  'ok': IDL.Null,
  'injured': InjuryIdl,
  'dead': IDL.Null
});

export type PlayerState = {
  name: Text;
  teamId: TeamId;
  condition: PlayerCondition;
  skills: PlayerSkills;
  position: FieldPosition;
};
export const PlayerStateIdl = IDL.Record({
  'name': IDL.Text,
  'teamId': TeamIdIdl,
  'condition': PlayerConditionIdl,
  'skills': PlayerSkillsIdl,
  'position': FieldPositionIdl
});

export type DefenseFieldState = {
  'firstBase': number;
  'secondBase': number;
  'thirdBase': number;
  'shortStop': number;
  'pitcher': number;
  'leftField': number;
  'centerField': number;
  'rightField': number;
};
export const DefenseFieldStateIdl = IDL.Record({
  'firstBase': IDL.Nat32,
  'secondBase': IDL.Nat32,
  'thirdBase': IDL.Nat32,
  'shortStop': IDL.Nat32,
  'pitcher': IDL.Nat32,
  'leftField': IDL.Nat32,
  'centerField': IDL.Nat32,
  'rightField': IDL.Nat32
});

export type OffenseFieldState = {
  'atBat': number;
  'firstBase': [number] | [];
  'secondBase': [number] | [];
  'thirdBase': [number] | [];
};
export const OffenseFieldStateIdl = IDL.Record({
  'atBat': IDL.Nat32,
  'firstBase': IDL.Opt(IDL.Nat32),
  'secondBase': IDL.Opt(IDL.Nat32),
  'thirdBase': IDL.Opt(IDL.Nat32)
});

export type FieldState =
  | { 'defense': DefenseFieldState }
  | { 'offense': OffenseFieldState };
export const FieldStateIdl = IDL.Variant({
  'defense': DefenseFieldStateIdl,
  'offense': OffenseFieldStateIdl
});

export type LogEntry = {
  description: Text;
  isImportant: boolean;
};
export const LogEntryIdl = IDL.Record({
  'description': IDL.Text,
  'isImportant': IDL.Bool
});

export type InProgressMatchState = {
  'offenseTeamId': TeamId;
  'team1': TeamState;
  'team2': TeamState;
  'aura': MatchAura;
  'players': [PlayerState];
  'field': FieldState;
  'log': [LogEntry];
  'round': bigint;
  'outs': bigint;
  'strikes': bigint;
};
export const InProgressMatchStateIdl = IDL.Record({
  'offenseTeamId': TeamIdIdl,
  'team1': TeamStateIdl,
  'team2': TeamStateIdl,
  'aura': MatchAuraIdl,
  'players': IDL.Vec(PlayerStateIdl),
  'field': FieldStateIdl,
  'log': IDL.Vec(LogEntryIdl),
  'round': IDL.Nat,
  'outs': IDL.Nat,
  'strikes': IDL.Nat
});

export type CompletedTeamState = {
  'id': Principal;
  'score': bigint;
};
export const CompletedTeamStateIdl = IDL.Record({
  'id': IDL.Principal,
  'score': IDL.Int
});

export type TeamIdOrTie =
  | TeamId
  | { 'tie': null };
export const TeamIdOrTieIdl = IDL.Variant({
  'team1': IDL.Null,
  'team2': IDL.Null,
  'tie': IDL.Null
});

export type CompletedMatchResult = {
  'team1': CompletedTeamState,
  'team2': CompletedTeamState,
  'winner': TeamIdOrTie,
  'log': LogEntry[]
};
export const CompletedMatchResultIdl = IDL.Record({
  'team1': CompletedTeamStateIdl,
  'team2': CompletedTeamStateIdl,
  'winner': TeamIdOrTieIdl,
  'log': IDL.Vec(LogEntryIdl)
});

export type CompletedMatchState =
  | { 'absentTeam': TeamId }
  | { 'allAbsent': null }
  | { 'played': CompletedMatchResult };
export const CompletedMatchStateIdl = IDL.Variant({
  'absentTeam': TeamIdIdl,
  'allAbsent': IDL.Null,
  'played': CompletedMatchResultIdl
});

export type StartedMatchState =
  | { 'inProgress': InProgressMatchState }
  | { 'completed': CompletedMatchState };
export const StartedMatchStateIdl = IDL.Variant({
  'inProgress': InProgressMatchStateIdl,
  'completed': CompletedMatchStateIdl
});


export type MatchState =
  | StartedMatchState
  | { 'notStarted': null }
export const MatchStateIdl = IDL.Variant({
  'notStarted': IDL.Null,
  'inProgress': InProgressMatchStateIdl,
  'completed': CompletedMatchStateIdl
});


export type Match = {
  'id': number,
  'team1': MatchTeam,
  'team2': MatchTeam,
  'offerings': Offering[],
  'aura': MatchAura,
  'state': MatchState
};
export const MatchIdl = IDL.Record({
  'id': IDL.Nat32,
  'team1': MatchTeamIdl,
  'team2': MatchTeamIdl,
  'offerings': IDL.Vec(OfferingIdl),
  'aura': MatchAuraIdl,
  'state': MatchStateIdl
});

export type NotStartedMatchGroupState = {
  'startTimerId': bigint;
  'matches': [Match];
};
export const NotStartedMatchGroupStateIdl = IDL.Record({
  'startTimerId': IDL.Nat,
  'matches': IDL.Vec(MatchIdl)
});

export type InProgressMatchGroupState = {
  'tickTimerId': bigint;
  'currentSeed': number;
  'matches': [StartedMatchState];
};
export const InProgressMatchGroupStateIdl = IDL.Record({
  'tickTimerId': IDL.Nat,
  'currentSeed': IDL.Nat32,
  'matches': IDL.Vec(StartedMatchStateIdl)
});

export type CompletedMatchGroupState = {
  'matches': [CompletedMatchState];
};
export const CompletedMatchGroupStateIdl = IDL.Record({
  'matches': IDL.Vec(CompletedMatchStateIdl)
});

export type MatchGroupState = {
  'notStarted': NotStartedMatchGroupState
} | {
  'inProgress': InProgressMatchGroupState
} | {
  'completed': CompletedMatchGroupState
};
export const MatchGroupStateIdl = IDL.Variant({
  'notStarted': NotStartedMatchGroupStateIdl,
  'inProgress': InProgressMatchGroupStateIdl,
  'completed': CompletedMatchGroupStateIdl
});

export type MatchGroup = {
  time: Time,
  state: MatchGroupState,
};
export const MatchGroupIdl = IDL.Record({
  'time': TimeIdl,
  'state': MatchGroupStateIdl
});

export type TickMatchGroupResult =
  | { 'inProgress': null }
  | { 'matchGroupNotFound': null }
  | { 'completed': null };
export const TickMatchGroupResultIdl = IDL.Variant({
  'inProgress': IDL.Null,
  'matchGroupNotFound': IDL.Null,
  'completed': IDL.Null
});

export type ScheduleMatchRequest = {
  'team1Id': Principal;
  'team2Id': Principal;
  'offerings': Offering[];
  'aura': MatchAura;
};
export const ScheduleMatchRequestIdl = IDL.Record({
  'team1Id': IDL.Principal,
  'team2Id': IDL.Principal,
  'offerings': IDL.Vec(OfferingIdl),
  'aura': MatchAuraIdl
});

export type ScheduleMatchGroupRequest = {
  'time': Time;
  'divisionId': Principal;
  'matches': [ScheduleMatchRequest];
};
export const ScheduleMatchGroupRequestIdl = IDL.Record({
  'time': TimeIdl,
  'divisionId': IDL.Principal,
  'matches': IDL.Vec(ScheduleMatchRequestIdl)
});

export type TeamIdOrBoth =
  | TeamId
  | { 'both': null };
export const TeamIdOrBothIdl = IDL.Variant({
  'team1': IDL.Null,
  'team2': IDL.Null,
  'both': IDL.Null
});

export type ScheduleMatchError =
  | { 'teamNotFound': TeamIdOrBoth };
export const ScheduleMatchErrorIdl = IDL.Variant({
  'teamNotFound': TeamIdOrBothIdl
});

export type ScheduleMatchGroupResult =
  | { 'ok': number }
  | { 'teamFetchError': string }
  | { 'matchErrors': ScheduleMatchError[] };
export const ScheduleMatchGroupResultIdl = IDL.Variant({
  'ok': IDL.Nat32,
  'teamFetchError': IDL.Text,
  'matchErrors': IDL.Vec(ScheduleMatchErrorIdl)
});


export interface _SERVICE {
  'getMatchGroup': ActorMethod<[number], [] | [MatchGroup]>,
  'getMatchGroups': ActorMethod<[], MatchGroup[]>,
  'tickMatchGroup': ActorMethod<[number], TickMatchGroupResult>,
  'scheduleMatchGroup': ActorMethod<[ScheduleMatchGroupRequest], ScheduleMatchGroupResult>
}
export const idlFactory: InterfaceFactory = ({ IDL }) => {
  return IDL.Service({
    'getMatchGroup': IDL.Func([IDL.Nat32], [IDL.Opt(MatchGroupIdl)], ['query']),
    'getMatchGroups': IDL.Func([], [IDL.Vec(MatchGroupIdl)], ['query']),
    'tickMatchGroup': IDL.Func([IDL.Nat32], [TickMatchGroupResultIdl], []),
    'scheduleMatchGroup': IDL.Func([ScheduleMatchGroupRequestIdl], [ScheduleMatchGroupResultIdl], [])
  });
};
export const stadiumAgentFactory = (canisterId: string | Principal) => createActor<_SERVICE>(canisterId, idlFactory);