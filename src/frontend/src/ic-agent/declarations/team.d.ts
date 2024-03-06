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
export interface GetScenarioVoteRequest { 'scenarioId' : string }
export type GetScenarioVoteResult = { 'ok' : [] | [bigint] } |
  { 'scenarioNotFound' : null };
export interface GetWinningScenarioOptionRequest { 'scenarioId' : string }
export type GetWinningScenarioOptionResult = { 'ok' : bigint } |
  { 'noVotes' : null } |
  { 'notAuthorized' : null } |
  { 'scenarioNotFound' : null };
export interface OnNewScenarioRequest {
  'scenarioId' : string,
  'optionCount' : bigint,
}
export type OnNewScenarioResult = { 'ok' : null } |
  { 'notAuthorized' : null };
export interface OnScenarioVoteCompleteRequest { 'scenarioId' : string }
export type OnScenarioVoteCompleteResult = { 'ok' : null } |
  { 'notAuthorized' : null } |
  { 'scenarioNotFound' : null };
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
  'getPlayers' : ActorMethod<[], Array<PlayerWithId>>,
  'getScenarioVote' : ActorMethod<
    [GetScenarioVoteRequest],
    GetScenarioVoteResult
  >,
  'getWinningScenarioOption' : ActorMethod<
    [GetWinningScenarioOptionRequest],
    GetWinningScenarioOptionResult
  >,
  'onNewScenario' : ActorMethod<[OnNewScenarioRequest], OnNewScenarioResult>,
  'onScenarioVoteComplete' : ActorMethod<
    [OnScenarioVoteCompleteRequest],
    OnScenarioVoteCompleteResult
  >,
  'onSeasonComplete' : ActorMethod<[], OnSeasonCompleteResult>,
  'voteOnScenario' : ActorMethod<[VoteOnScenarioRequest], VoteOnScenarioResult>,
}
export interface VoteOnScenarioRequest {
  'scenarioId' : string,
  'option' : bigint,
}
export type VoteOnScenarioResult = { 'ok' : null } |
  { 'invalidOption' : null } |
  { 'notAuthorized' : null } |
  { 'alreadyVoted' : null } |
  { 'seasonStatusFetchError' : string } |
  { 'teamNotInScenario' : null } |
  { 'votingNotOpen' : null } |
  { 'scenarioNotFound' : null };
export interface _SERVICE extends TeamActor {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
