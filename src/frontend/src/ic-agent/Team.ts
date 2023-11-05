import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import { createActor } from './Actor';
import type { InterfaceFactory } from '@dfinity/candid/lib/cjs/idl';
import { Offering, OfferingIdl } from './Stadium';
import { Player, PlayerIdl } from './PlayerLedger';
import { IDL } from "@dfinity/candid";


export type MatchGroupVote = {
  'offering': Offering;
  'champion': number;
};
export const MatchGroupVoteIdl = IDL.Record({
  'offering': OfferingIdl,
  'champion': IDL.Nat32
});

export type GetMatchGroupVoteResult =
  | { 'ok': MatchGroupVote }
  | { 'noVotes': null }
  | { 'notAuthorized': null };
export const GetMatchGroupVoteResultIdl = IDL.Variant({
  'ok': MatchGroupVoteIdl,
  'noVotes': IDL.Null,
  'notAuthorized': IDL.Null
});

export type VoteOnMatchGroupRequest = MatchGroupVote & {
  'matchGroupId': number;
};
export const VoteOnMatchGroupRequestIdl = IDL.Record({
  'offering': OfferingIdl,
  'champion': IDL.Nat32,
  'matchGroupId': IDL.Nat32
});

export type VoteOnMatchGroupResult =
  | { 'ok': null }
  | { 'notAuthorized': null }
  | { 'matchGroupNotFound': null }
  | { 'teamNotInMatchGroup': null }
  | { 'alreadyVoted': null }
  | { 'alreadyStarted': null }
  | { 'matchGroupFetchError': string }
  | { 'invalid': [string] };
export const VoteOnMatchGroupResultIdl = IDL.Variant({
  'ok': IDL.Null,
  'notAuthorized': IDL.Null,
  'matchGroupNotFound': IDL.Null,
  'teamNotInMatchGroup': IDL.Null,
  'alreadyVoted': IDL.Null,
  'alreadyStarted': IDL.Null,
  'matchGroupFetchError': IDL.Text,
  'invalid': IDL.Vec(IDL.Text)
});


export interface _SERVICE {
  'getPlayers': ActorMethod<[], Player[]>,
  'getMatchGroupVote': ActorMethod<[number], GetMatchGroupVoteResult>,
  'voteOnMatchGroup': ActorMethod<[VoteOnMatchGroupRequest], VoteOnMatchGroupResult>,
}


export const idlFactory: InterfaceFactory = ({ IDL }) => {
  return IDL.Service({
    'getPlayers': IDL.Func([], [IDL.Vec(PlayerIdl)], ['query']),
    'getMatchGroupVote': IDL.Func([IDL.Nat32], [GetMatchGroupVoteResultIdl], ['query']),
    'voteOnMatchGroup': IDL.Func([VoteOnMatchGroupRequestIdl], [VoteOnMatchGroupResultIdl], []),
  });
};
export const teamAgentFactory = (canisterId: string | Principal) => createActor<_SERVICE>(canisterId, idlFactory);