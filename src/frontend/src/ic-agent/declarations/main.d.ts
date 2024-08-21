import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export type AddGameContentRequest = { 'trait' : Trait } |
  { 'item' : Item } |
  { 'class' : Class } |
  { 'race' : Race } |
  { 'image' : Image } |
  { 'scenario' : ScenarioMetaData };
export type AddGameContentResult = { 'ok' : null } |
  { 'err' : { 'notAuthorized' : null } | { 'invalid' : Array<string> } };
export interface AxialCoordinate { 'q' : bigint, 'r' : bigint }
export interface CallbackStrategy {
  'token' : Token,
  'callback' : [Principal, string],
}
export type CharacterModifier = { 'magic' : bigint } |
  { 'trait' : string } |
  { 'gold' : bigint } |
  { 'item' : string } |
  { 'speed' : bigint } |
  { 'defense' : bigint } |
  { 'attack' : bigint } |
  { 'health' : bigint };
export type CharacterStatKind = { 'magic' : null } |
  { 'speed' : null } |
  { 'defense' : null } |
  { 'attack' : null };
export interface CharacterStats {
  'magic' : bigint,
  'speed' : bigint,
  'defense' : bigint,
  'attack' : bigint,
}
export interface CharacterWithMetaData {
  'gold' : bigint,
  'traits' : Array<Trait>,
  'class' : Class,
  'race' : Race,
  'stats' : CharacterStats,
  'items' : Array<Item>,
  'health' : bigint,
}
export interface Choice {
  'id' : string,
  'description' : string,
  'requirement' : [] | [ChoiceRequirement],
  'pathId' : string,
}
export type ChoiceRequirement = { 'all' : Array<ChoiceRequirement> } |
  { 'any' : Array<ChoiceRequirement> } |
  { 'trait' : string } |
  { 'gold' : bigint } |
  { 'item' : string } |
  { 'class' : string } |
  { 'race' : string } |
  { 'stat' : [CharacterStatKind, bigint] };
export interface ChoiceVotingPower { 'votingPower' : bigint, 'choice' : string }
export interface ChoiceVotingPower_1 {
  'votingPower' : bigint,
  'choice' : bigint,
}
export interface ChoiceVotingPower_2 {
  'votingPower' : bigint,
  'choice' : Difficulty,
}
export interface Class {
  'id' : string,
  'name' : string,
  'description' : string,
  'modifiers' : Array<CharacterModifier>,
}
export type Condition = { 'hasGold' : NatValue } |
  { 'hasItem' : TextValue } |
  { 'hasTrait' : TextValue };
export type CreateWorldProposalError = { 'invalid' : Array<string> } |
  { 'notEligible' : null };
export type CreateWorldProposalRequest = { 'motion' : MotionContent };
export type CreateWorldProposalResult = { 'ok' : bigint } |
  { 'err' : CreateWorldProposalError };
export type Difficulty = { 'easy' : null } |
  { 'hard' : null } |
  { 'medium' : null };
export type Effect = { 'reward' : null } |
  { 'removeTrait' : RandomOrSpecificTextValue } |
  { 'damage' : NatValue } |
  { 'heal' : NatValue } |
  { 'upgradeStat' : [CharacterStatKind, NatValue] } |
  { 'addItem' : TextValue } |
  { 'addTrait' : TextValue } |
  { 'removeGold' : NatValue } |
  { 'removeItem' : RandomOrSpecificTextValue };
export type GameInstanceWithMetaData = {
    'notStarted' : {
      'characterVotes' : VotingSummary,
      'characterOptions' : Array<CharacterWithMetaData>,
      'difficultyVotes' : VotingSummary_1,
    }
  } |
  {
    'completed' : {
      'turns' : bigint,
      'character' : CharacterWithMetaData,
      'difficulty' : Difficulty,
    }
  } |
  { 'notInitialized' : null } |
  {
    'inProgress' : {
      'character' : CharacterWithMetaData,
      'turn' : bigint,
      'locations' : Array<Location>,
      'characterLocationId' : bigint,
    }
  };
export interface GeneratedDataField {
  'id' : string,
  'value' : GeneratedDataFieldValue,
  'name' : string,
}
export interface GeneratedDataFieldInstance {
  'id' : string,
  'value' : GeneratedDataFieldInstanceValue,
}
export type GeneratedDataFieldInstanceValue = { 'nat' : bigint } |
  { 'text' : string };
export interface GeneratedDataFieldNat { 'max' : bigint, 'min' : bigint }
export interface GeneratedDataFieldText { 'options' : Array<[string, number]> }
export type GeneratedDataFieldValue = { 'nat' : GeneratedDataFieldNat } |
  { 'text' : GeneratedDataFieldText };
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
export type HeaderField = [string, string];
export interface HttpRequest {
  'url' : string,
  'method' : string,
  'body' : Uint8Array | number[],
  'headers' : Array<HeaderField>,
}
export interface HttpResponse {
  'body' : Uint8Array | number[],
  'headers' : Array<HeaderField>,
  'upgrade' : [] | [boolean],
  'streaming_strategy' : [] | [StreamingStrategy],
  'status_code' : number,
}
export interface HttpUpdateRequest {
  'url' : string,
  'method' : string,
  'body' : Uint8Array | number[],
  'headers' : Array<HeaderField>,
}
export interface Image {
  'id' : string,
  'data' : Uint8Array | number[],
  'kind' : ImageKind,
}
export type ImageKind = { 'png' : null };
export type InitializeResult = { 'ok' : null } |
  {
    'err' : { 'noTraits' : null } |
      { 'noItems' : null } |
      { 'noClasses' : null } |
      { 'noRaces' : null } |
      { 'noScenarios' : null } |
      { 'noImages' : null } |
      { 'alreadyInitialized' : null }
  };
export interface Item { 'id' : string, 'name' : string, 'description' : string }
export type JoinError = { 'alreadyMember' : null };
export interface Location {
  'id' : bigint,
  'scenarioId' : bigint,
  'coordinate' : AxialCoordinate,
}
export interface MotionContent { 'title' : string, 'description' : string }
export type NatValue = { 'raw' : bigint } |
  { 'dataField' : string } |
  { 'random' : [bigint, bigint] };
export interface Outcome {
  'messages' : Array<string>,
  'choiceOrUndecided' : [] | [string],
}
export interface OutcomePath {
  'id' : string,
  'effects' : Array<Effect>,
  'description' : string,
  'paths' : Array<WeightedOutcomePath>,
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
export interface Race {
  'id' : string,
  'name' : string,
  'description' : string,
  'modifiers' : Array<CharacterModifier>,
}
export type RandomOrSpecificTextValue = { 'specific' : TextValue } |
  { 'random' : null };
export type Result = { 'ok' : null } |
  { 'err' : JoinError };
export interface Scenario {
  'id' : bigint,
  'voteData' : ScenarioVote,
  'metaDataId' : string,
  'metaData' : ScenarioMetaData,
  'data' : Array<GeneratedDataFieldInstance>,
  'availableChoiceIds' : Array<string>,
  'outcome' : [] | [Outcome],
}
export interface ScenarioMetaData {
  'id' : string,
  'title' : string,
  'data' : Array<GeneratedDataField>,
  'description' : string,
  'paths' : Array<OutcomePath>,
  'imageId' : string,
  'choices' : Array<Choice>,
  'undecidedPathId' : string,
}
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
export interface StreamingCallbackHttpResponse {
  'token' : [] | [Token],
  'body' : Uint8Array | number[],
}
export type StreamingStrategy = { 'Callback' : CallbackStrategy };
export type TextValue = { 'raw' : string } |
  { 'dataField' : string } |
  { 'weighted' : Array<[string, number]> };
export type Time = bigint;
export interface Token { 'arbitrary_data' : string }
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
  { 'scenarioNotFound' : null } |
  { 'choiceRequirementNotMet' : null };
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
export interface WeightedOutcomePath {
  'weight' : number,
  'pathId' : string,
  'condition' : [] | [Condition],
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
  'addGameContent' : ActorMethod<[AddGameContentRequest], AddGameContentResult>,
  'createWorldProposal' : ActorMethod<
    [CreateWorldProposalRequest],
    CreateWorldProposalResult
  >,
  'getGameInstance' : ActorMethod<[], GameInstanceWithMetaData>,
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
  'http_request' : ActorMethod<[HttpRequest], HttpResponse>,
  'http_request_update' : ActorMethod<[HttpUpdateRequest], HttpResponse>,
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
