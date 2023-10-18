import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import { createActor } from './Actor';
import type { InterfaceFactory } from '@dfinity/candid/lib/cjs/idl';


export type MatchOptions = {
  offeringId: number,
  specialRuleVotes: [number, bigint][] // [ruleId, votingPower]
};
export type UpdateMatchOptionsResult = {
  'ok': null
} | {
  'invalid': string[]
} | {
  'notAuthorized': null
} | {
  'matchNotFound': null
} | {
  'stadiumNotFound': null
} | {
  'teamNotInMatch': null
};
export type GetMatchOptionsResult = {
  'ok': null
} | {
  'notVotes': null
} | {
  'notAuthorized': null
};
export interface _SERVICE {
  'getMatchOptions': ActorMethod<[Principal, number], GetMatchOptionsResult>,
  'updateMatchOptions': ActorMethod<[Principal, number, MatchOptions], UpdateMatchOptionsResult>,
}



export const idlFactory: InterfaceFactory = ({ IDL }) => {
  const MatchOptions = IDL.Record({
    'offeringId': IDL.Nat32,
    'specialRuleVotes': IDL.Vec(IDL.Tuple(IDL.Nat32, IDL.Nat))
  });
  const UpdateMatchOptionsResult = IDL.Variant({
    'ok': IDL.Null,
    'invalid': IDL.Vec(IDL.Text),
    'stadiumNotFound': IDL.Null,
    'teamNotInMatch': IDL.Null,
    'notAuthorized': IDL.Null
  });
  const GetMatchOptionsResult = IDL.Variant({
    'ok': MatchOptions,
    'noVotes': IDL.Null,
    'notAuthorized': IDL.Null
  });
  return IDL.Service({
    'getMatchOptions': IDL.Func([IDL.Principal, IDL.Nat32], [GetMatchOptionsResult], []),
    'updateMatchOptions': IDL.Func([IDL.Principal, IDL.Nat32, MatchOptions], [UpdateMatchOptionsResult], []),
  });
};
export const teamAgentFactory = (canisterId: string | Principal) => createActor<_SERVICE>(canisterId, idlFactory);