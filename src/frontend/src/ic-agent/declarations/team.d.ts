import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface AddMemberRequest { 'id' : Principal }
export type AddMemberResult = { 'ok' : null } |
  { 'notAuthorized' : null } |
  { 'alreadyExists' : null };
export interface CreateProposalRequest { 'content' : ProposalContent }
export type CreateProposalResult = { 'ok' : bigint } |
  { 'notAuthorized' : null };
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
export interface Member { 'id' : Principal, 'votingPower' : bigint }
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
export interface Proposal {
  'id' : bigint,
  'status' : ProposalStatus,
  'content' : ProposalContent,
  'timeStart' : bigint,
  'votes' : Array<[Principal, Vote]>,
  'endTimerId' : [] | [bigint],
  'proposer' : Principal,
  'timeEnd' : bigint,
}
export type ProposalContent = {
    'trainPlayer' : { 'playerId' : number, 'skill' : Skill }
  };
export type ProposalStatus = { 'open' : null } |
  { 'rejected' : null } |
  { 'executed' : null };
export type Skill = { 'battingAccuracy' : null } |
  { 'throwingAccuracy' : null } |
  { 'speed' : null } |
  { 'catching' : null } |
  { 'battingPower' : null } |
  { 'defense' : null } |
  { 'throwingPower' : null };
export interface TeamActor {
  'addMember' : ActorMethod<[AddMemberRequest], AddMemberResult>,
  'createProposal' : ActorMethod<[CreateProposalRequest], CreateProposalResult>,
  'getCycles' : ActorMethod<[], GetCyclesResult>,
  'getMember' : ActorMethod<[Principal], [] | [Member]>,
  'getMembers' : ActorMethod<[], Array<Member>>,
  'getProposal' : ActorMethod<[bigint], [] | [Proposal]>,
  'getProposals' : ActorMethod<[], Array<Proposal>>,
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
  'voteOnProposal' : ActorMethod<[VoteOnProposalRequest], VoteOnProposalResult>,
  'voteOnScenario' : ActorMethod<[VoteOnScenarioRequest], VoteOnScenarioResult>,
}
export interface Vote { 'value' : [] | [boolean], 'votingPower' : bigint }
export interface VoteOnProposalRequest {
  'vote' : boolean,
  'proposalId' : bigint,
}
export type VoteOnProposalResult = { 'ok' : null } |
  { 'proposalNotFound' : null } |
  { 'notAuthorized' : null } |
  { 'alreadyVoted' : null } |
  { 'votingClosed' : null };
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
