import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import { createActor } from './Actor';
import type { InterfaceFactory } from '@dfinity/candid/lib/cjs/idl';


export type Time = bigint;
export type MatchTeam = {
  'id': Principal,
  'score': [] | [bigint],
  'predictionVotes': bigint
};
export type Offering = {
  'deities': string[],
  'effects': string[],
};
export type SpecialRule = {
  'name': string,
  'description': string,
};
export type Match = {
  'id': number,
  'teams': [MatchTeam, MatchTeam],
  'time': Time,
  'winner': [] | [Principal],
  'offerings': Offering[],
  'specialRules': SpecialRule[]
};
export interface _SERVICE {
  'getMatches': ActorMethod<[], Match[]>,
  'getMatch': ActorMethod<[number], [] | [Match]>,
}



export const idlFactory: InterfaceFactory = ({ IDL }) => {
  const MatchTeamInfo = IDL.Record({
    'id': IDL.Principal,
    'score': IDL.Opt(IDL.Nat),
    'predictionVotes': IDL.Nat
  });
  const Offering = IDL.Record({
    'deities': IDL.Vec(IDL.Text),
    'effects': IDL.Vec(IDL.Text),
  });
  const SpecialRule = IDL.Record({
    'name': IDL.Text,
    'description': IDL.Text,
  });
  const Match = IDL.Record({
    'id': IDL.Nat32,
    'teams': IDL.Tuple(MatchTeamInfo, MatchTeamInfo),
    'time': IDL.Int,
    'winner': IDL.Opt(IDL.Principal),
    'offerings': IDL.Vec(Offering),
    'specialRules': IDL.Vec(SpecialRule),
  });
  return IDL.Service({
    'getMatches': IDL.Func([], [IDL.Vec(Match)], ['query']),
    'getMatch': IDL.Func([IDL.Nat32], [IDL.Opt(Match)], ['query']),
  });
};
export const stadiumAgentFactory = (canisterId: string | Principal) => createActor<_SERVICE>(canisterId, idlFactory);