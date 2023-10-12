import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import { createActor } from './Actor';
import type { InterfaceFactory } from '@dfinity/candid/lib/cjs/idl';


export type MatchOptions = {
  offeringId: number,
  specialRuleId: number
};
export type VoteResult = {
  'ok': null
} | {
  'invalid': string[]
} | {
  'alreadyVoted': null
} | {
  'matchNotFound': null
} | {
  'stadiumNotFound': null
} | {
  'teamNotInMatch': null
};
export interface _SERVICE {
  'voteForMatchOptions': ActorMethod<[Principal, number, MatchOptions], VoteResult>,
}



export const idlFactory: InterfaceFactory = ({ IDL }) => {
  const MatchOptions = IDL.Record({
    'offeringId': IDL.Nat32,
    'specialRuleId': IDL.Nat32
  });
  const VoteResult = IDL.Variant({
    'ok': IDL.Null,
    'invalid': IDL.Vec(IDL.Text),
    'alreadyVoted': IDL.Null,
    'matchNotFound': IDL.Null,
    'stadiumNotFound': IDL.Null,
    'teamNotInMatch': IDL.Null
  });
  return IDL.Service({
    'voteForMatchOptions': IDL.Func([IDL.Principal, IDL.Nat32, MatchOptions], [VoteResult], []),
  });
};
export const teamAgentFactory = (canisterId: string | Principal) => createActor<_SERVICE>(canisterId, idlFactory);