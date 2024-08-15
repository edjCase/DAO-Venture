import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface AxialCoordinate { 'q' : bigint, 'r' : bigint }
export interface Character {
  'gold' : bigint,
  'traits' : Array<Trait>,
  'items' : Array<Item>,
  'health' : bigint,
}
export interface ChoiceVotingPower { 'votingPower' : bigint, 'choice' : string }
export type CreateWorldProposalError = { 'invalid' : Array<string> } |
  { 'notEligible' : null };
export type CreateWorldProposalRequest = { 'motion' : MotionContent };
export type CreateWorldProposalResult = { 'ok' : bigint } |
  { 'err' : CreateWorldProposalError };
export interface Data {
  'size' : string,
  'unusualFeature' : string,
  'structureName' : string,
  'material' : string,
  'condition' : string,
}
export interface GameState {
  'character' : Character,
  'turn' : bigint,
  'locations' : Array<Location>,
  'characterLocationId' : bigint,
}
export type GetGameStateError = { 'noActiveGame' : null };
export type GetGameStateResult = { 'ok' : GameState } |
  { 'err' : GetGameStateError };
export type GetScenarioError = { 'noActiveGame' : null } |
  { 'notFound' : null };
export type GetScenarioResult = { 'ok' : Scenario } |
  { 'err' : GetScenarioError };
export type GetScenarioVoteError = { 'noActiveGame' : null } |
  { 'scenarioNotFound' : null };
export interface GetScenarioVoteRequest { 'scenarioId' : bigint }
export type GetScenarioVoteResult = { 'ok' : ScenarioVote } |
  { 'err' : GetScenarioVoteError };
export type GetScenariosError = { 'noActiveGame' : null };
export type GetScenariosResult = { 'ok' : Array<Scenario> } |
  { 'err' : GetScenariosError };
export interface GetTopUsersRequest { 'count' : bigint, 'offset' : bigint }
export type GetTopUsersResult = { 'ok' : PagedResult_1 };
export type GetUserError = { 'notFound' : null };
export type GetUserResult = { 'ok' : User } |
  { 'err' : GetUserError };
export type GetUserStatsResult = { 'ok' : UserStats } |
  { 'err' : null };
export type GetUsersRequest = { 'all' : null };
export type GetUsersResult = { 'ok' : Array<User> };
export type GetWorldProposalError = { 'proposalNotFound' : null };
export type GetWorldProposalResult = { 'ok' : WorldProposal } |
  { 'err' : GetWorldProposalError };
export interface Item { 'id' : string, 'name' : string, 'description' : string }
export type JoinError = { 'alreadyMember' : null };
export interface Location {
  'id' : bigint,
  'scenarioId' : bigint,
  'coordinate' : AxialCoordinate,
}
export interface MotionContent { 'title' : string, 'description' : string }
export type NextTurnResult = { 'ok' : null } |
  { 'err' : { 'noActiveInstance' : null } };
export interface Outcome {
  'messages' : Array<string>,
  'choice' : [] | [string],
}
export interface PagedResult {
  'data' : Array<WorldProposal>,
  'count' : bigint,
  'totalCount' : bigint,
  'offset' : bigint,
}
export interface PagedResult_1 {
  'data' : Array<User>,
  'count' : bigint,
  'totalCount' : bigint,
  'offset' : bigint,
}
export type ProposalContent = { 'motion' : MotionContent };
export type ProposalStatus = {
    'failedToExecute' : {
      'executingTime' : Time,
      'error' : string,
      'failedTime' : Time,
      'choice' : [] | [boolean],
    }
  } |
  { 'open' : null } |
  { 'executing' : { 'executingTime' : Time, 'choice' : [] | [boolean] } } |
  {
    'executed' : {
      'executingTime' : Time,
      'choice' : [] | [boolean],
      'executedTime' : Time,
    }
  };
export type Result = { 'ok' : null } |
  { 'err' : JoinError };
export interface Scenario {
  'id' : bigint,
  'title' : string,
  'voteData' : ScenarioVote,
  'kind' : ScenarioKind,
  'description' : string,
  'outcome' : [] | [Outcome],
  'options' : Array<ScenarioOption>,
}
export type ScenarioKind = { 'mysteriousStructure' : Data };
export interface ScenarioOption { 'id' : string, 'description' : string }
export interface ScenarioVote {
  'votingPowerByChoice' : Array<ChoiceVotingPower>,
  'undecidedVotingPower' : bigint,
  'totalVotingPower' : bigint,
  'yourVote' : [] | [ScenarioVoteChoice],
}
export interface ScenarioVoteChoice {
  'votingPower' : bigint,
  'choice' : [] | [string],
}
export type StartGameError = { 'alreadyStarted' : null };
export type StartGameResult = { 'ok' : null } |
  { 'err' : StartGameError };
export type Time = bigint;
export interface Trait {
  'id' : string,
  'name' : string,
  'description' : string,
}
export interface User {
  'id' : Principal,
  'inWorldSince' : Time,
  'level' : bigint,
}
export interface UserStats { 'totalUserLevel' : bigint, 'userCount' : bigint }
export interface Vote { 'votingPower' : bigint, 'choice' : [] | [boolean] }
export type VoteOnScenarioError = { 'noActiveGame' : null } |
  { 'proposalNotFound' : null } |
  { 'alreadyVoted' : null } |
  { 'votingClosed' : null } |
  { 'invalidChoice' : null } |
  { 'notEligible' : null } |
  { 'scenarioNotFound' : null };
export interface VoteOnScenarioRequest {
  'scenarioId' : bigint,
  'value' : string,
}
export type VoteOnScenarioResult = { 'ok' : null } |
  { 'err' : VoteOnScenarioError };
export type VoteOnWorldProposalError = { 'proposalNotFound' : null } |
  { 'alreadyVoted' : null } |
  { 'votingClosed' : null } |
  { 'notEligible' : null };
export interface VoteOnWorldProposalRequest {
  'vote' : boolean,
  'proposalId' : bigint,
}
export type VoteOnWorldProposalResult = { 'ok' : null } |
  { 'err' : VoteOnWorldProposalError };
export interface WorldProposal {
  'id' : bigint,
  'status' : ProposalStatus,
  'content' : ProposalContent,
  'timeStart' : bigint,
  'votes' : Array<[Principal, Vote]>,
  'timeEnd' : [] | [bigint],
  'proposerId' : Principal,
}
export interface _SERVICE {
  'createWorldProposal' : ActorMethod<
    [CreateWorldProposalRequest],
    CreateWorldProposalResult
  >,
  'getGameState' : ActorMethod<[], GetGameStateResult>,
  'getScenario' : ActorMethod<[bigint], GetScenarioResult>,
  'getScenarioVote' : ActorMethod<
    [GetScenarioVoteRequest],
    GetScenarioVoteResult
  >,
  'getScenarios' : ActorMethod<[], GetScenariosResult>,
  'getTopUsers' : ActorMethod<[GetTopUsersRequest], GetTopUsersResult>,
  'getUser' : ActorMethod<[Principal], GetUserResult>,
  'getUserStats' : ActorMethod<[], GetUserStatsResult>,
  'getUsers' : ActorMethod<[GetUsersRequest], GetUsersResult>,
  'getWorldProposal' : ActorMethod<[bigint], GetWorldProposalResult>,
  'getWorldProposals' : ActorMethod<[bigint, bigint], PagedResult>,
  'join' : ActorMethod<[], Result>,
  'nextTurn' : ActorMethod<[], NextTurnResult>,
  'startGame' : ActorMethod<[], StartGameResult>,
  'voteOnScenario' : ActorMethod<[VoteOnScenarioRequest], VoteOnScenarioResult>,
  'voteOnWorldProposal' : ActorMethod<
    [VoteOnWorldProposalRequest],
    VoteOnWorldProposalResult
  >,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
