import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import { createActor } from './Actor';
import type { InterfaceFactory } from '@dfinity/candid/lib/cjs/idl';


export type MatchOptionsVote = {
  offeringId: number,
  specialRuleId: number
};
export type VoteMatchOptionsResult = {
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
  'alreadyVoted': null
} | {
  'teamNotInMatch': null
};
export type VoteMatchOptionsRequest = {
  'stadiumId': Principal;
  'matchId': number,
  'vote': MatchOptionsVote
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
  'voteForMatchOptions': ActorMethod<[VoteMatchOptionsRequest], VoteMatchOptionsResult>,
}



export const idlFactory: InterfaceFactory = ({ IDL }) => {
  const MatchOptions = IDL.Record({
    'offeringId': IDL.Nat32,
    'specialRuleVotes': IDL.Vec(IDL.Tuple(IDL.Nat32, IDL.Nat))
  });
  const MatchOptionsVote = IDL.Record({
    'offeringId': IDL.Nat32,
    'specialRuleId': IDL.Nat32
  });
  const VoteMatchOptionsRequest = IDL.Record({
    'stadiumId': IDL.Principal,
    'matchId': IDL.Nat32,
    'vote': MatchOptionsVote
  });
  const VoteMatchOptionsResult = IDL.Variant({
    'ok': IDL.Null,
    'invalid': IDL.Vec(IDL.Text),
    'stadiumNotFound': IDL.Null,
    'teamNotInMatch': IDL.Null,
    'notAuthorized': IDL.Null,
    'alreadyVoted': IDL.Null
  });
  const GetMatchOptionsResult = IDL.Variant({
    'ok': MatchOptions,
    'noVotes': IDL.Null,
    'notAuthorized': IDL.Null
  });
  return IDL.Service({
    'getMatchOptions': IDL.Func([IDL.Principal, IDL.Nat32], [GetMatchOptionsResult], []),
    'voteForMatchOptions': IDL.Func([VoteMatchOptionsRequest], [VoteMatchOptionsResult], []),
  });
};
export const teamAgentFactory = (canisterId: string | Principal) => createActor<_SERVICE>(canisterId, idlFactory);