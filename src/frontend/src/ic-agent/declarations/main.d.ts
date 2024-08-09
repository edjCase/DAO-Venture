import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface AxialCoordinate { 'q' : bigint, 'r' : bigint }
export type Choice = {};
export interface ChoiceVotingPower {
  'votingPower' : bigint,
  'choice' : ScenarioChoiceKind,
}
export type CreateWorldProposalError = { 'notAuthorized' : null } |
  { 'invalid' : Array<string> };
export type CreateWorldProposalRequest = { 'motion' : MotionContent };
export type CreateWorldProposalResult = { 'ok' : bigint } |
  { 'err' : CreateWorldProposalError };
export interface GetAllScenariosRequest { 'count' : bigint, 'offset' : bigint }
export interface GetAllScenariosResult {
  'data' : Array<Scenario>,
  'count' : bigint,
  'totalCount' : bigint,
  'offset' : bigint,
}
export type GetScenarioError = { 'notStarted' : null } |
  { 'notFound' : null };
export type GetScenarioResult = { 'ok' : Scenario } |
  { 'err' : GetScenarioError };
export type GetScenarioVoteError = { 'notEligible' : null } |
  { 'scenarioNotFound' : null };
export interface GetScenarioVoteRequest { 'scenarioId' : bigint }
export type GetScenarioVoteResult = { 'ok' : ScenarioVote } |
  { 'err' : GetScenarioVoteError };
export interface GetTopUsersRequest { 'count' : bigint, 'offset' : bigint }
export type GetTopUsersResult = { 'ok' : PagedResult_1 };
export type GetUserError = { 'notAuthorized' : null } |
  { 'notFound' : null };
export type GetUserResult = { 'ok' : User } |
  { 'err' : GetUserError };
export type GetUserStatsResult = { 'ok' : UserStats } |
  { 'err' : null };
export type GetUsersRequest = { 'all' : null };
export type GetUsersResult = { 'ok' : Array<User> };
export type GetWorldError = { 'worldNotInitialized' : null };
export type GetWorldProposalError = { 'proposalNotFound' : null };
export type GetWorldProposalResult = { 'ok' : WorldProposal } |
  { 'err' : GetWorldProposalError };
export type GetWorldResult = { 'ok' : World } |
  { 'err' : GetWorldError };
export type InitializeWorldError = { 'alreadyInitialized' : null };
export type JoinWorldError = { 'notAuthorized' : null } |
  { 'alreadyWorldMember' : null };
export type LocationKind = { 'resource' : ResourceLocation } |
  { 'town' : TownLocation } |
  { 'unexplored' : UnexploredLocation };
export interface MetaData { 'structureName' : string }
export interface MotionContent { 'title' : string, 'description' : string }
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
export interface Proposal {
  'id' : bigint,
  'status' : ProposalStatus_1,
  'content' : ProposalContent__1,
  'timeStart' : bigint,
  'votes' : Array<[Principal, Vote_1]>,
  'endTimerId' : [] | [bigint],
  'timeEnd' : [] | [bigint],
  'proposerId' : Principal,
}
export type ProposalContent = { 'motion' : MotionContent };
export type ProposalContent__1 = {};
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
export type ProposalStatus_1 = {
    'failedToExecute' : {
      'executingTime' : Time,
      'error' : string,
      'failedTime' : Time,
      'choice' : [] | [Choice],
    }
  } |
  { 'open' : null } |
  { 'executing' : { 'executingTime' : Time, 'choice' : [] | [Choice] } } |
  {
    'executed' : {
      'executingTime' : Time,
      'choice' : [] | [Choice],
      'executedTime' : Time,
    }
  };
export type ResourceKind = { 'food' : null } |
  { 'gold' : null } |
  { 'wood' : null } |
  { 'stone' : null };
export interface ResourceLocation {
  'kind' : ResourceKind,
  'claimedByTownIds' : Array<bigint>,
  'rarity' : ResourceRarity,
}
export type ResourceRarity = { 'rare' : null } |
  { 'common' : null } |
  { 'uncommon' : null };
export type Result = { 'ok' : null } |
  { 'err' : JoinWorldError };
export type Result_1 = { 'ok' : null } |
  { 'err' : InitializeWorldError };
export interface Scenario { 'id' : bigint, 'kind' : ScenarioKind }
export type ScenarioChoiceKind = { 'mysteriousStructure' : Choice };
export interface ScenarioData { 'metaData' : MetaData, 'proposal' : Proposal }
export type ScenarioKind = { 'mysteriousStructure' : ScenarioData };
export interface ScenarioVote {
  'votingPowerByChoice' : Array<ChoiceVotingPower>,
  'undecidedVotingPower' : bigint,
  'totalVotingPower' : bigint,
  'yourVote' : [] | [ScenarioVoteChoice],
}
export interface ScenarioVoteChoice {
  'votingPower' : bigint,
  'choice' : [] | [ScenarioChoiceKind],
}
export type Time = bigint;
export interface TownLocation { 'townId' : bigint }
export interface UnexploredLocation {
  'explorationNeeded' : bigint,
  'currentExploration' : bigint,
}
export interface User {
  'id' : Principal,
  'inWorldSince' : Time,
  'level' : bigint,
}
export interface UserStats { 'totalUserLevel' : bigint, 'userCount' : bigint }
export interface Vote { 'votingPower' : bigint, 'choice' : [] | [boolean] }
export type VoteOnScenarioError = { 'proposalNotFound' : null } |
  { 'notAuthorized' : null } |
  { 'alreadyVoted' : null } |
  { 'votingClosed' : null } |
  { 'invalidChoice' : null } |
  { 'scenarioNotFound' : null };
export interface VoteOnScenarioRequest {
  'scenarioId' : bigint,
  'value' : ScenarioChoiceKind,
}
export type VoteOnScenarioResult = { 'ok' : null } |
  { 'err' : VoteOnScenarioError };
export type VoteOnWorldProposalError = { 'proposalNotFound' : null } |
  { 'notAuthorized' : null } |
  { 'alreadyVoted' : null } |
  { 'votingClosed' : null };
export interface VoteOnWorldProposalRequest {
  'vote' : boolean,
  'proposalId' : bigint,
}
export type VoteOnWorldProposalResult = { 'ok' : null } |
  { 'err' : VoteOnWorldProposalError };
export interface Vote_1 { 'votingPower' : bigint, 'choice' : [] | [Choice] }
export interface World {
  'nextDayStartTime' : bigint,
  'daysElapsed' : bigint,
  'progenitor' : Principal,
  'locations' : Array<WorldLocation>,
}
export interface WorldLocation {
  'id' : bigint,
  'kind' : LocationKind,
  'coordinate' : AxialCoordinate,
}
export interface WorldProposal {
  'id' : bigint,
  'status' : ProposalStatus,
  'content' : ProposalContent,
  'timeStart' : bigint,
  'votes' : Array<[Principal, Vote]>,
  'endTimerId' : [] | [bigint],
  'timeEnd' : [] | [bigint],
  'proposerId' : Principal,
}
export interface _SERVICE {
  'createWorldProposal' : ActorMethod<
    [CreateWorldProposalRequest],
    CreateWorldProposalResult
  >,
  'getAllScenarios' : ActorMethod<
    [GetAllScenariosRequest],
    GetAllScenariosResult
  >,
  'getProgenitor' : ActorMethod<[], [] | [Principal]>,
  'getScenario' : ActorMethod<[bigint], GetScenarioResult>,
  'getScenarioVote' : ActorMethod<
    [GetScenarioVoteRequest],
    GetScenarioVoteResult
  >,
  'getTopUsers' : ActorMethod<[GetTopUsersRequest], GetTopUsersResult>,
  'getUser' : ActorMethod<[Principal], GetUserResult>,
  'getUserStats' : ActorMethod<[], GetUserStatsResult>,
  'getUsers' : ActorMethod<[GetUsersRequest], GetUsersResult>,
  'getWorld' : ActorMethod<[], GetWorldResult>,
  'getWorldProposal' : ActorMethod<[bigint], GetWorldProposalResult>,
  'getWorldProposals' : ActorMethod<[bigint, bigint], PagedResult>,
  'intializeWorld' : ActorMethod<[], Result_1>,
  'joinWorld' : ActorMethod<[], Result>,
  'voteOnScenario' : ActorMethod<[VoteOnScenarioRequest], VoteOnScenarioResult>,
  'voteOnWorldProposal' : ActorMethod<
    [VoteOnWorldProposalRequest],
    VoteOnWorldProposalResult
  >,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
