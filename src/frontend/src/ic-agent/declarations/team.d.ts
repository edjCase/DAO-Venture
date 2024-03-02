import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export type FieldPosition = { 'rightField' : null } |
  { 'leftField' : null } |
  { 'thirdBase' : null } |
  { 'pitcher' : null } |
  { 'secondBase' : null } |
  { 'shortStop' : null } |
  { 'centerField' : null } |
  { 'firstBase' : null };
export type GetCyclesResult = { 'ok' : bigint } |
  { 'notAuthorized' : null };
export interface GetMatchGroupVoteRequest { 'matchGroupId' : bigint }
export type GetMatchGroupVoteResult = { 'ok' : MatchGroupVoteResult } |
  { 'noVotes' : null } |
  { 'notAuthorized' : null };
export type InvalidVoteError = { 'invalidChoice' : number };
export interface MatchGroupVoteResult { 'scenarioChoice' : number }
export type OnSeasonCompleteResult = { 'ok' : null } |
  { 'notAuthorized' : null };
export interface PlayerWithId {
  'id' : number,
  'title' : string,
  'name' : string,
  'description' : string,
  'likes' : Array<string>,
  'teamId' : Principal,
  'position' : FieldPosition,
  'quirks' : Array<string>,
  'dislikes' : Array<string>,
  'skills' : Skills,
  'traitIds' : Array<string>,
}
export interface Skills {
  'battingAccuracy' : bigint,
  'throwingAccuracy' : bigint,
  'speed' : bigint,
  'catching' : bigint,
  'battingPower' : bigint,
  'defense' : bigint,
  'throwingPower' : bigint,
}
export interface TeamActor {
  'getCycles' : ActorMethod<[], GetCyclesResult>,
  'getMatchGroupVote' : ActorMethod<
    [GetMatchGroupVoteRequest],
    GetMatchGroupVoteResult
  >,
  'getPlayers' : ActorMethod<[], Array<PlayerWithId>>,
  'onSeasonComplete' : ActorMethod<[], OnSeasonCompleteResult>,
  'voteOnMatchGroup' : ActorMethod<
    [VoteOnMatchGroupRequest],
    VoteOnMatchGroupResult
  >,
}
export interface VoteOnMatchGroupRequest {
  'matchGroupId' : bigint,
  'scenarioChoice' : number,
}
export type VoteOnMatchGroupResult = { 'ok' : null } |
  { 'teamNotInMatchGroup' : null } |
  { 'notAuthorized' : null } |
  { 'invalid' : Array<InvalidVoteError> } |
  { 'alreadyVoted' : null } |
  { 'seasonStatusFetchError' : string } |
  { 'matchGroupNotFound' : null } |
  { 'votingNotOpen' : null };
export interface _SERVICE extends TeamActor {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
