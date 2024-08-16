import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface AxialCoordinate { 'q' : bigint, 'r' : bigint }
export interface Character {
  'gold' : bigint,
  'traits' : Array<Trait>,
  'stats' : CharacterStats,
  'items' : Array<Item__1>,
  'health' : bigint,
}
export interface CharacterStats {
  'magic' : bigint,
  'speed' : bigint,
  'defense' : bigint,
  'attack' : bigint,
}
export interface ChoiceVotingPower { 'votingPower' : bigint, 'choice' : string }
export type CreateWorldProposalError = { 'invalid' : Array<string> } |
  { 'notEligible' : null };
export type CreateWorldProposalRequest = { 'motion' : MotionContent };
export type CreateWorldProposalResult = { 'ok' : bigint } |
  { 'err' : CreateWorldProposalError };
export type Data = {};
export type Data__1 = {};
export interface Data__2 { 'upgradeCost' : bigint }
export interface Data__3 { 'trinket' : Trinket }
export interface Data__4 { 'bribeCost' : bigint }
export type Data__5 = {};
export type Data__6 = {};
export type Data__7 = {};
export type Data__8 = {};
export interface Data__9 { 'cost' : bigint }
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
export type Item = { 'echoCrystal' : null } |
  { 'herbs' : null } |
  { 'healthPotion' : null } |
  { 'fairyCharm' : null };
export interface Item__1 {
  'id' : string,
  'name' : string,
  'description' : string,
}
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
export type ScenarioKind = { 'goblinRaidingParty' : Data__4 } |
  { 'trappedDruid' : Data__8 } |
  { 'corruptedTreant' : Data } |
  { 'wanderingAlchemist' : Data__9 } |
  { 'darkElfAmbush' : Data__1 } |
  { 'dwarvenWeaponsmith' : Data__2 } |
  { 'mysteriousStructure' : Data__6 } |
  { 'fairyMarket' : Data__3 } |
  { 'lostElfling' : Data__5 } |
  { 'sinkingBoat' : Data__7 };
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
export interface Trinket { 'cost' : bigint, 'item' : Item }
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
