import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface AxialCoordinate { 'q' : bigint, 'r' : bigint }
export interface CharacterState {
  'gold' : bigint,
  'traits' : Array<TraitState>,
  'class' : ClassState,
  'race' : RaceState,
  'stats' : CharacterStats,
  'items' : Array<ItemState>,
  'health' : bigint,
}
export interface CharacterStats {
  'magic' : bigint,
  'speed' : bigint,
  'defense' : bigint,
  'attack' : bigint,
}
export interface ChoiceVotingPower { 'votingPower' : bigint, 'choice' : string }
export interface ChoiceVotingPower_1 {
  'votingPower' : bigint,
  'choice' : bigint,
}
export interface ChoiceVotingPower_2 {
  'votingPower' : bigint,
  'choice' : Difficulty,
}
export interface ClassState { 'name' : string, 'description' : string }
export type CreateWorldProposalError = { 'invalid' : Array<string> } |
  { 'notEligible' : null };
export type CreateWorldProposalRequest = { 'motion' : MotionContent };
export type CreateWorldProposalResult = { 'ok' : bigint } |
  { 'err' : CreateWorldProposalError };
export type Data = {};
export type Data__1 = {};
export interface Data__10 {
  'reforgeCost' : bigint,
  'upgradeCost' : bigint,
  'craftCost' : bigint,
}
export type Data__11 = {};
export type Data__12 = {};
export interface Data__13 {
  'inspirationCost' : bigint,
  'talesCost' : bigint,
  'requestCost' : bigint,
}
export interface Data__14 { 'cost' : bigint }
export interface Data__2 {
  'blessingCost' : bigint,
  'communeCost' : bigint,
  'healingCost' : bigint,
}
export interface Data__3 { 'upgradeCost' : bigint }
export interface Data__4 {
  'communeCost' : bigint,
  'harvestCost' : bigint,
  'meditationCost' : bigint,
}
export interface Data__5 { 'trinket' : Trinket }
export interface Data__6 { 'bribeCost' : bigint }
export interface Data__7 {
  'mapCost' : bigint,
  'skillCost' : bigint,
  'studyCost' : bigint,
}
export type Data__8 = {};
export type Data__9 = {};
export type Difficulty = { 'easy' : null } |
  { 'hard' : null } |
  { 'medium' : null };
export type GameState = {
    'notStarted' : {
      'characterVotes' : VotingSummary,
      'characterOptions' : Array<CharacterState>,
      'difficultyVotes' : VotingSummary_1,
    }
  } |
  {
    'completed' : {
      'turns' : bigint,
      'character' : CharacterState,
      'difficulty' : Difficulty,
    }
  } |
  { 'notInitialized' : null } |
  {
    'inProgress' : {
      'character' : CharacterState,
      'turn' : bigint,
      'locations' : Array<Location>,
      'characterLocationId' : bigint,
    }
  };
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
export type InitializeResult = { 'ok' : null } |
  { 'err' : { 'alreadyInitialized' : null } };
export type Item = { 'echoCrystal' : null } |
  { 'herbs' : null } |
  { 'treasureMap' : null } |
  { 'healthPotion' : null } |
  { 'fairyCharm' : null };
export interface ItemState { 'name' : string, 'description' : string }
export type JoinError = { 'alreadyMember' : null };
export interface Location {
  'id' : bigint,
  'scenarioId' : bigint,
  'coordinate' : AxialCoordinate,
}
export interface MotionContent { 'title' : string, 'description' : string }
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
export interface RaceState { 'name' : string, 'description' : string }
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
export type ScenarioKind = { 'goblinRaidingParty' : Data__6 } |
  { 'trappedDruid' : Data__12 } |
  { 'travelingBard' : Data__13 } |
  { 'druidicSanctuary' : Data__2 } |
  { 'corruptedTreant' : Data } |
  { 'wanderingAlchemist' : Data__14 } |
  { 'darkElfAmbush' : Data__1 } |
  { 'dwarvenWeaponsmith' : Data__3 } |
  { 'enchantedGrove' : Data__4 } |
  { 'mysticForge' : Data__10 } |
  { 'mysteriousStructure' : Data__9 } |
  { 'knowledgeNexus' : Data__7 } |
  { 'fairyMarket' : Data__5 } |
  { 'lostElfling' : Data__8 } |
  { 'sinkingBoat' : Data__11 };
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
export type Time = bigint;
export interface TraitState { 'name' : string, 'description' : string }
export interface Trinket { 'cost' : bigint, 'item' : Item }
export interface User {
  'id' : Principal,
  'inWorldSince' : Time,
  'level' : bigint,
}
export interface UserStats { 'totalUserLevel' : bigint, 'userCount' : bigint }
export interface Vote { 'votingPower' : bigint, 'choice' : [] | [boolean] }
export type VoteOnNewGameError = { 'noActiveGame' : null } |
  { 'invalidCharacterId' : null } |
  { 'alreadyVoted' : null } |
  { 'votingClosed' : null } |
  { 'alreadyStarted' : null } |
  { 'notEligible' : null };
export interface VoteOnNewGameRequest {
  'difficulty' : Difficulty,
  'characterId' : bigint,
}
export type VoteOnNewGameResult = { 'ok' : null } |
  { 'err' : VoteOnNewGameError };
export type VoteOnScenarioError = { 'noActiveGame' : null } |
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
export interface VotingSummary {
  'votingPowerByChoice' : Array<ChoiceVotingPower_1>,
  'undecidedVotingPower' : bigint,
  'totalVotingPower' : bigint,
}
export interface VotingSummary_1 {
  'votingPowerByChoice' : Array<ChoiceVotingPower_2>,
  'undecidedVotingPower' : bigint,
  'totalVotingPower' : bigint,
}
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
  'getGameState' : ActorMethod<[], GameState>,
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
  'initialize' : ActorMethod<[], InitializeResult>,
  'join' : ActorMethod<[], Result>,
  'voteOnNewGame' : ActorMethod<[VoteOnNewGameRequest], VoteOnNewGameResult>,
  'voteOnScenario' : ActorMethod<[VoteOnScenarioRequest], VoteOnScenarioResult>,
  'voteOnWorldProposal' : ActorMethod<
    [VoteOnWorldProposalRequest],
    VoteOnWorldProposalResult
  >,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
