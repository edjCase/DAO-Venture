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

export type MatchPlayer = {
  'id': number;
  'name': string;
};
export const MatchPlayerIdl = IDL.Record({
  'id': IDL.Nat32,
  'name': IDL.Text,
});

export type MatchTeam = {
  'id': Principal;
  'name': string;
  'logoUrl': string;
  'predictionVotes': bigint;
  'players': MatchPlayer[]
};
export const MatchTeamIdl = IDL.Record({
  'id': IDL.Principal,
  'name': IDL.Text,
  'logoUrl': IDL.Text,
  'predictionVotes': IDL.Nat,
  'players': IDL.Vec(MatchPlayerIdl)
});

export type Offering =
  | { 'shuffleAndBoost': null };
export const OfferingIdl = IDL.Variant({
  'shuffleAndBoost': IDL.Null
});

export type OfferingWithMetaData = {
  offering: Offering;
  name: string;
  description: string;
};
export const OfferingWithMetaDataIdl = IDL.Record({
  'offering': OfferingIdl,
  'name': IDL.Text,
  'description': IDL.Text
});

export type MatchAura =
  | { 'lowGravity': null }
  | { 'explodingBalls': null }
  | { 'fastBallsHardHits': null }
  | { 'moreBlessingsAndCurses': null };
export const MatchAuraIdl = IDL.Variant({
  'lowGravity': IDL.Null,
  'explodingBalls': IDL.Null,
  'fastBallsHardHits': IDL.Null,
  'moreBlessingsAndCurses': IDL.Null
});

export type MatchAuraWithMetaData = {
  aura: MatchAura;
  name: string;
  description: string;
};
export const MatchAuraWithMetaDataIdl = IDL.Record({
  'aura': MatchAuraIdl,
  'name': IDL.Text,
  'description': IDL.Text
});

export type TeamId =
  | { 'team1': null }
  | { 'team2': null };
export const TeamIdIdl = IDL.Variant({
  'team1': IDL.Null,
  'team2': IDL.Null
});

export type TeamState = {
  'score': bigint;
  'offering': Offering;
  'championId': number;
};
export const TeamStateIdl = IDL.Record({
  'score': IDL.Int,
  'offering': OfferingIdl,
  'championId': IDL.Nat32
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
  'id': number;
  'teamId': TeamId;
  'condition': PlayerCondition;
  'skills': PlayerSkills;
  'position': FieldPosition;
};
export const PlayerStateIdl = IDL.Record({
  'id': IDL.Nat32,
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

export type FieldState = {
  'defense': DefenseFieldState,
  'offense': OffenseFieldState
}
export const FieldStateIdl = IDL.Record({
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

export type PlayedTeamState = {
  'score': bigint;
};
export const PlayedTeamStateIdl = IDL.Record({
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

export type PlayedMatchState = {
  'team1': PlayedTeamState,
  'team2': PlayedTeamState,
  'winner': TeamIdOrTie,
  'log': LogEntry[]
};
export const PlayedMatchStateIdl = IDL.Record({
  'team1': PlayedTeamStateIdl,
  'team2': PlayedTeamStateIdl,
  'winner': TeamIdOrTieIdl,
  'log': IDL.Vec(LogEntryIdl)
});

export type PlayerNotFoundError = {
  'id': number;
  'teamId': [TeamId] | [];
};
export const PlayerNotFoundErrorIdl = IDL.Record({
  'id': IDL.Nat32,
  'teamId': IDL.Opt(TeamIdIdl)
});

export type PlayerExpectedOnFieldError = {
  'id': number;
  'onOffense': boolean;
  'description': string;
};
export const PlayerExpectedOnFieldErrorIdl = IDL.Record({
  'id': IDL.Nat32,
  'onOffense': IDL.Bool,
  'description': IDL.Text
});

export type BrokenStateError =
  | { 'playerNotFound': PlayerNotFoundError }
  | { 'playerExpectedOnField': PlayerExpectedOnFieldError };
export const BrokenStateErrorIdl = IDL.Variant({
  'playerNotFound': PlayerNotFoundErrorIdl,
  'playerExpectedOnField': PlayerExpectedOnFieldErrorIdl
});

export type BrokenState = {
  'log': LogEntry[],
  'error': BrokenStateError
};
export const BrokenStateIdl = IDL.Record({
  'log': IDL.Vec(LogEntryIdl),
  'error': BrokenStateErrorIdl
});

export type CompletedMatchState =
  | { 'absentTeam': TeamId }
  | { 'allAbsent': null }
  | { 'played': PlayedMatchState }
  | { 'stateBroken': BrokenState };
export const CompletedMatchStateIdl = IDL.Variant({
  'absentTeam': TeamIdIdl,
  'allAbsent': IDL.Null,
  'played': PlayedMatchStateIdl,
  'stateBroken': BrokenStateIdl
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
  'team1': MatchTeam,
  'team2': MatchTeam,
  'offerings': OfferingWithMetaData[],
  'aura': MatchAuraWithMetaData
};
export const MatchIdl = IDL.Record({
  'team1': MatchTeamIdl,
  'team2': MatchTeamIdl,
  'offerings': IDL.Vec(OfferingWithMetaDataIdl),
  'aura': MatchAuraWithMetaDataIdl
});

export type NotStartedMatchGroupState = {
  'startTimerId': bigint;
};
export const NotStartedMatchGroupStateIdl = IDL.Record({
  'startTimerId': IDL.Nat,
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
  'id': number,
  'time': Time,
  'matches': Match[],
  'state': MatchGroupState,
};
export const MatchGroupIdl = IDL.Record({
  'id': IDL.Nat32,
  'time': TimeIdl,
  'matches': IDL.Vec(MatchIdl),
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
  'divisionId': number;
  'matches': [ScheduleMatchRequest];
};
export const ScheduleMatchGroupRequestIdl = IDL.Record({
  'time': TimeIdl,
  'divisionId': IDL.Nat32,
  'matches': IDL.Vec(ScheduleMatchRequestIdl)
});

export type TeamIdOrBoth =
  | TeamId
  | { 'bothTeams': null };
export const TeamIdOrBothIdl = IDL.Variant({
  'team1': IDL.Null,
  'team2': IDL.Null,
  'bothTeams': IDL.Null
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

export type DivisionSchedule = {
  'id': number;
  'matchGroups': MatchGroup[];
};
export const DivisionScheduleIdl = IDL.Record({
  'id': IDL.Nat32,
  'matchGroups': IDL.Vec(MatchGroupIdl)
});

export type SeasonSchedule = {
  'divisions': DivisionSchedule[];
};
export const SeasonScheduleIdl = IDL.Record({
  'divisions': IDL.Vec(DivisionScheduleIdl)
});

export type ScheduleMatchGroupError =
  | { 'teamFetchError': string }
  | { 'matchErrors': ScheduleMatchError[] }
  | { 'noMatchesSpecified': null };
export const ScheduleMatchGroupErrorIdl = IDL.Variant({
  'teamFetchError': IDL.Text,
  'matchErrors': IDL.Vec(ScheduleMatchErrorIdl),
  'noMatchesSpecified': IDL.Null
});

export type ScheduleDivisionError =
  | { 'divisionNotFound': null }
  | { 'teamFetchError': string }
  | { 'playerFetchError': string }
  | { 'matchGroupErrors': ScheduleMatchGroupError[] }
  | { 'noMatchGroupsSpecified': null }
  | { 'noTeamsInDivision': null }
  | { 'oddNumberOfTeams': null };
export const ScheduleDivisionErrorIdl = IDL.Variant({
  'divisionNotFound': IDL.Null,
  'teamFetchError': IDL.Text,
  'playerFetchError': IDL.Text,
  'matchGroupErrors': IDL.Vec(ScheduleMatchGroupErrorIdl),
  'noMatchGroupsSpecified': IDL.Null,
  'noTeamsInDivision': IDL.Null,
  'oddNumberOfTeams': IDL.Null
});

export type ScheduleDivisionErrorResult = {
  id: number;
  error: ScheduleDivisionError;
};
export const ScheduleDivisionErrorResultIdl = IDL.Record({
  'id': IDL.Nat32,
  'error': ScheduleDivisionErrorIdl
});

export type ScheduleSeasonResult =
  | { 'ok': null }
  | { 'divisionErrors': ScheduleDivisionErrorResult[] }
  | { 'noDivisionSpecified': null }
  | { 'alreadyScheduled': null };
export const ScheduleSeasonResultIdl = IDL.Variant({
  'ok': IDL.Null,
  'divisionErrors': IDL.Vec(ScheduleDivisionErrorResultIdl),
  'noDivisionSpecified': IDL.Null,
  'alreadyScheduled': IDL.Null
});

export type DivisionScheduleRequest = {
  // TODO
};
export const DivisionScheduleRequestIdl = IDL.Record({
  // TODO
});

export type ScheduleSeasonRequest = {
  'divisions': DivisionScheduleRequest[];
};
export const ScheduleSeasonRequestIdl = IDL.Record({
  'divisions': IDL.Vec(DivisionScheduleRequestIdl)
});

export interface _SERVICE {
  'getMatchGroup': ActorMethod<[number], [] | [MatchGroup]>,
  'getSeasonSchedule': ActorMethod<[], [] | [SeasonSchedule]>,
  'tickMatchGroup': ActorMethod<[number], TickMatchGroupResult>,
  'scheduleSeason': ActorMethod<[ScheduleSeasonRequest], ScheduleSeasonResult>
}
export const idlFactory: InterfaceFactory = ({ IDL }) => {
  return IDL.Service({
    'getMatchGroup': IDL.Func([IDL.Nat32], [IDL.Opt(MatchGroupIdl)], ['query']),
    'getSeasonSchedule': IDL.Func([], [IDL.Opt(SeasonScheduleIdl)], ['query']),
    'tickMatchGroup': IDL.Func([IDL.Nat32], [TickMatchGroupResultIdl], []),
    'scheduleSeason': IDL.Func([ScheduleSeasonRequestIdl], [ScheduleSeasonResultIdl], [])
  });
};
export const stadiumAgentFactory = (canisterId: string | Principal) => createActor<_SERVICE>(canisterId, idlFactory);