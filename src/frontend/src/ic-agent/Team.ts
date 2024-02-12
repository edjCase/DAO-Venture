import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import { createActor } from './Actor';
import type { InterfaceFactory } from '@dfinity/candid/lib/cjs/idl';
import { Player, PlayerIdl } from './Players';
import { IDL } from "@dfinity/candid";


export type MatchGroupVote = {
  'choice': number;
};
export const MatchGroupVoteIdl = IDL.Record({
  'choice': IDL.Nat8,
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
  'choice': IDL.Nat8,
  'matchGroupId': IDL.Nat
});

export type InvalidVoteError =
  | { 'invalidChoice': number };
export const InvalidVoteErrorIdl = IDL.Variant({
  'invalidChoice': IDL.Nat8
});

export type VoteOnMatchGroupResult =
  | { 'ok': null }
  | { 'notAuthorized': null }
  | { 'matchGroupNotFound': null }
  | { 'teamNotInMatchGroup': null }
  | { 'votingNotOpen': null }
  | { 'alreadyVoted': null }
  | { 'seasonStatusFetchError': string }
  | { 'invalid': [InvalidVoteError] };
export const VoteOnMatchGroupResultIdl = IDL.Variant({
  'ok': IDL.Null,
  'notAuthorized': IDL.Null,
  'matchGroupNotFound': IDL.Null,
  'teamNotInMatchGroup': IDL.Null,
  'votingNotOpen': IDL.Null,
  'alreadyVoted': IDL.Null,
  'seasonStatusFetchError': IDL.Text,
  'invalid': IDL.Vec(InvalidVoteErrorIdl)
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