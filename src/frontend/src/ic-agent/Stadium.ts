import type { Principal } from '@dfinity/principal';
import type { Actor, ActorMethod } from '@dfinity/agent';
import { createActor } from './Actor';
import type { InterfaceFactory } from '@dfinity/candid/lib/cjs/idl';


export type Time = bigint;
export type MatchTeam = {
  'id': Principal,
  'predictionVotes': bigint
};
export type OfferingWithId = {
  'id': number,
  'deities': string[],
  'effects': string[],
};
export type SpecialRuleWithId = {
  'id': number,
  'name': string,
  'description': string,
};
export type TeamState = {
  'id': Principal;
  'score': bigint;
  'offeringId': number;
};
export type OffenseFieldState = {
  'firstBase': [] | [number],
  'secondBase': [] | [number],
  'thirdBase': [] | [number],
  'atBat': number,
};
export type DefenseFieldState = {
  'firstBase': number,
  'secondBase': number,
  'thirdBase': number,
  'pitcher': number,
  'shortStop': number,
  'leftField': number,
  'centerField': number,
  'rightField': number,
};
export type FieldState = {
  'offense': OffenseFieldState,
  'defense': DefenseFieldState,
}
export type MatchEvent = {
  'description': string
};
export type PlayerCondition = {

};
export type PlayerSkills = {

};
export type FieldPosition = {

};
export type PlayerState = {
  'id': number,
  'name': string;
  'teamId': TeamId;
  // 'condition': PlayerCondition;
  // 'skills': PlayerSkills;
  // 'position': FieldPosition;
};
export type InProgressMatchState = {
  'offenseTeamId': TeamId,
  'team1': TeamState,
  'team2': TeamState,
  'specialRuleId': [] | [number],
  'events': [MatchEvent],
  'field': FieldState,
  'round': bigint,
  'outs': bigint,
  'strikes': bigint,
  'players': PlayerState[]
};
export type TeamId = {
  'team1': null
} | {
  'team2': null;
};
export type CompletedTeamState = {
  id: Principal;
  score: bigint;
};
export type CompletedMatchResult = {
  team1: CompletedTeamState;
  team2: CompletedTeamState;
  winner: TeamId;
  events: [MatchEvent];
};
export type CompletedMatchState = {
  'absentTeam': TeamId
} | {
  'allAbsent': null
} | {
  'played': CompletedMatchResult;
};
export type MatchState = {
  'notStarted': null
} | {
  'inProgress': InProgressMatchState
} | {
  'completed': CompletedMatchState;
};
export type TickMatchResult = {
  'ok': InProgressMatchState
} | {
  'matchNotFound': null
} | {
  'matchOver': CompletedMatchState
} | {
  'notStarted': null
};
export type Match = {
  'id': number,
  'stadiumId': Principal,
  'teams': [MatchTeam, MatchTeam],
  'time': Time,
  'offerings': OfferingWithId[],
  'specialRules': SpecialRuleWithId[],
  'state': MatchState
};
export type StartMatchResult = {
  'ok': InProgressMatchState
} | {
  'matchNotFound': null
} | {
  'matchAlreadyStarted': null
} | {
  'completed': CompletedMatchState
};
export interface _SERVICE {
  'getMatches': ActorMethod<[], Match[]>,
  'getMatch': ActorMethod<[number], [] | [Match]>,
  'tickMatch': ActorMethod<[number], TickMatchResult>,
  'startMatch': ActorMethod<[number], StartMatchResult>
}



export const idlFactory: InterfaceFactory = ({ IDL }) => {
  const MatchTeamInfo = IDL.Record({
    'id': IDL.Principal,
    'score': IDL.Opt(IDL.Int),
    'predictionVotes': IDL.Nat
  });
  const OfferingWithId = IDL.Record({
    'id': IDL.Nat32,
    'deities': IDL.Vec(IDL.Text),
    'effects': IDL.Vec(IDL.Text),
  });
  const SpecialRuleWithId = IDL.Record({
    'id': IDL.Nat32,
    'name': IDL.Text,
    'description': IDL.Text,
  });
  const OffenseFieldState = IDL.Record({
    'firstBase': IDL.Opt(IDL.Nat32),
    'secondBase': IDL.Opt(IDL.Nat32),
    'thirdBase': IDL.Opt(IDL.Nat32),
    'atBat': IDL.Nat32,
  });
  const DefenseFieldState = IDL.Record({
    'firstBase': IDL.Nat32,
    'secondBase': IDL.Nat32,
    'thirdBase': IDL.Nat32,
    'pitcher': IDL.Nat32,
    'shortStop': IDL.Nat32,
    'leftField': IDL.Nat32,
    'centerField': IDL.Nat32,
    'rightField': IDL.Nat32
  });
  const FieldState = IDL.Record({
    'defense': DefenseFieldState,
    'offense': OffenseFieldState,
  });
  const MatchEvent = IDL.Record({
    'description': IDL.Text
  });
  const TeamId = IDL.Variant({
    'team1': IDL.Null,
    'team2': IDL.Null
  });
  const TeamState = IDL.Record({
    'id': IDL.Principal,
    'score': IDL.Int,
    'offeringId': IDL.Nat32,
  });
  const PlayerCondition = IDL.Variant({

  });
  const PlayerSkills = IDL.Record({

  });
  const FieldPosition = IDL.Variant({

  });
  const PlayerState = IDL.Record({
    'id': IDL.Nat32,
    'name': IDL.Text,
    'teamId': TeamId,
    // 'condition': PlayerCondition,
    // 'skills': PlayerSkills,
    // 'position': FieldPosition
  });
  const InProgressState = IDL.Record({
    'offenseTeamId': TeamId,
    'team1': TeamState,
    'team2': TeamState,
    'specialRuleId': IDL.Opt(IDL.Nat32),
    'events': IDL.Vec(MatchEvent),
    'field': FieldState,
    'players': IDL.Vec(PlayerState),
    'strikes': IDL.Nat,
    'outs': IDL.Nat,
    'round': IDL.Nat,
  });
  const CompletedTeamState = IDL.Record({
    'id': IDL.Principal,
    'score': IDL.Int
  });
  const CompletedMatchResult = IDL.Record({
    'team1': CompletedTeamState,
    'team2': CompletedTeamState,
    'winner': TeamId,
    'events': IDL.Vec(MatchEvent)
  });
  const CompletedState = IDL.Variant({
    'absentTeam': TeamId,
    'allAbsent': IDL.Null,
    'played': CompletedMatchResult
  });
  const MatchState = IDL.Variant({
    'notStarted': IDL.Null,
    'inProgress': InProgressState,
    'completed': CompletedState
  });
  const Match = IDL.Record({
    'id': IDL.Nat32,
    'stadiumId': IDL.Principal,
    'teams': IDL.Tuple(MatchTeamInfo, MatchTeamInfo),
    'time': IDL.Int,
    'offerings': IDL.Vec(OfferingWithId),
    'specialRules': IDL.Vec(SpecialRuleWithId),
    'state': MatchState
  });
  const TickMatchResult = IDL.Variant({
    'ok': InProgressState,
    'matchNotFound': IDL.Null,
    'matchOver': CompletedState,
    'notStarted': IDL.Null
  });
  const StartMatchResult = IDL.Variant({
    'ok': InProgressState,
    'matchNotFound': IDL.Null,
    'matchAlreadyStarted': IDL.Null,
    'completed': CompletedState
  });
  return IDL.Service({
    'getMatches': IDL.Func([], [IDL.Vec(Match)], ['query']),
    'getMatch': IDL.Func([IDL.Nat32], [IDL.Opt(Match)], ['query']),
    'tickMatch': IDL.Func([IDL.Nat32], [TickMatchResult], []),
    'startMatch': IDL.Func([IDL.Nat32], [StartMatchResult], [])
  });
};
export const stadiumAgentFactory = (canisterId: string | Principal) => createActor<_SERVICE>(canisterId, idlFactory);