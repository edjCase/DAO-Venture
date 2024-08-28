import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface Achievement {
  'id' : string,
  'name' : string,
  'description' : string,
}
export type AddGameContentRequest = { 'trait' : Trait } |
  { 'creature' : Creature } |
  { 'item' : Item } |
  { 'class' : Class } |
  { 'race' : Race } |
  { 'zone' : Zone } |
  { 'achievement' : Achievement } |
  { 'image' : Image } |
  { 'scenario' : ScenarioMetaData } |
  { 'weapon' : Weapon };
export type AddGameContentResult = { 'ok' : null } |
  { 'err' : { 'notAuthorized' : null } | { 'invalid' : Array<string> } };
export interface AddUserToGameRequest {
  'userId' : Principal,
  'gameId' : bigint,
}
export type AddUserToGameResult = { 'ok' : null } |
  {
    'err' : { 'alreadyJoined' : null } |
      { 'notAuthorized' : null } |
      { 'gameNotFound' : null }
  };
export interface AxialCoordinate { 'q' : bigint, 'r' : bigint }
export interface CallbackStrategy {
  'token' : Token,
  'callback' : [Principal, string],
}
export type CharacterModifier = { 'magic' : bigint } |
  { 'trait' : string } |
  { 'maxHealth' : bigint } |
  { 'gold' : bigint } |
  { 'item' : string } |
  { 'speed' : bigint } |
  { 'defense' : bigint } |
  { 'attack' : bigint } |
  { 'health' : bigint };
export type CharacterStatKind = { 'magic' : null } |
  { 'maxHealth' : null } |
  { 'speed' : null } |
  { 'defense' : null } |
  { 'attack' : null } |
  { 'health' : null };
export type CharacterStatKind__1 = { 'magic' : null } |
  { 'gold' : null } |
  { 'speed' : null } |
  { 'defense' : null } |
  { 'attack' : null } |
  { 'health' : { 'inverse' : boolean } };
export interface CharacterWithMetaData {
  'magic' : bigint,
  'maxHealth' : bigint,
  'gold' : bigint,
  'traits' : Array<Trait>,
  'class' : Class,
  'race' : Race,
  'speed' : bigint,
  'defense' : bigint,
  'items' : Array<Item>,
  'attack' : bigint,
  'weapon' : Weapon,
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
  'weaponId' : string,
  'unlockRequirement' : [] | [UnlockRequirement],
  'modifiers' : Array<CharacterModifier>,
}
export interface CombatCreatureFilter {
  'location' : CombatCreatureLocationFilter,
}
export type CombatCreatureKind = { 'id' : string } |
  { 'filter' : CombatCreatureFilter };
export type CombatCreatureLocationFilter = { 'any' : null } |
  { 'zone' : string } |
  { 'common' : null };
export interface CombatPath { 'creature' : CombatCreatureKind }
export interface CompletedGameStateWithMetaData {
  'startTime' : Time,
  'turns' : bigint,
  'endTime' : Time,
  'character' : CharacterWithMetaData,
  'difficulty' : Difficulty,
  'victory' : boolean,
}
export interface CompletedGameWithMetaData {
  'id' : bigint,
  'startTime' : Time,
  'turns' : bigint,
  'guestUserIds' : Array<Principal>,
  'endTime' : Time,
  'character' : CharacterWithMetaData,
  'difficulty' : Difficulty,
  'victory' : boolean,
  'hostUserId' : Principal,
}
export type Condition = { 'hasGold' : NatValue } |
  { 'hasItem' : TextValue } |
  { 'hasTrait' : TextValue };
export type CreateGameError = { 'noTraits' : null } |
  { 'noWeapons' : null } |
  { 'noCreaturesForZone' : string } |
  { 'noZones' : null } |
  { 'noItems' : null } |
  { 'noScenariosForZone' : string } |
  { 'noClasses' : null } |
  { 'noCreatures' : null } |
  { 'noRaces' : null } |
  { 'noScenarios' : null } |
  { 'noImages' : null } |
  { 'alreadyInitialized' : null };
export type CreateGameResult = { 'ok' : bigint } |
  { 'err' : CreateGameError };
export type CreateWorldProposalError = { 'invalid' : Array<string> } |
  { 'notEligible' : null };
export type CreateWorldProposalRequest = { 'motion' : MotionContent };
export type CreateWorldProposalResult = { 'ok' : bigint } |
  { 'err' : CreateWorldProposalError };
export interface Creature {
  'id' : string,
  'magic' : bigint,
  'maxHealth' : bigint,
  'kind' : CreatureKind,
  'name' : string,
  'description' : string,
  'speed' : bigint,
  'weaponId' : string,
  'defense' : bigint,
  'attack' : bigint,
  'location' : CreatureLocationKind,
  'health' : bigint,
}
export type CreatureKind = { 'normal' : null } |
  { 'boss' : null } |
  { 'elite' : null };
export type CreatureLocationKind = { 'common' : null } |
  { 'zoneIds' : Array<string> };
export type Difficulty = { 'easy' : null } |
  { 'hard' : null } |
  { 'medium' : null };
export type Effect = { 'reward' : null } |
  { 'removeTrait' : RandomOrSpecificTextValue } |
  { 'damage' : NatValue } |
  { 'heal' : NatValue } |
  { 'achievement' : string } |
  { 'upgradeStat' : [CharacterStatKind, NatValue] } |
  { 'addItem' : TextValue } |
  { 'addTrait' : TextValue } |
  { 'removeGold' : NatValue } |
  { 'removeItem' : RandomOrSpecificTextValue };
export type GameStateWithMetaData = { 'notStarted' : null } |
  { 'completed' : CompletedGameStateWithMetaData } |
  { 'voting' : VotingGameStateWithMetaData } |
  { 'inProgress' : InProgressGameStateWithMetaData };
export interface GameWithMetaData {
  'id' : bigint,
  'guestUserIds' : Array<Principal>,
  'state' : GameStateWithMetaData,
  'hostUserId' : Principal,
}
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
export type GetCurrentGameResult = { 'ok' : [] | [GameWithMetaData] } |
  { 'err' : { 'notAuthenticated' : null } };
export interface GetGameRequest { 'gameId' : bigint }
export type GetGameResult = { 'ok' : GameWithMetaData } |
  { 'err' : { 'gameNotFound' : null } };
export type GetScenarioError = { 'notFound' : null } |
  { 'gameNotFound' : null } |
  { 'gameNotActive' : null };
export interface GetScenarioRequest { 'scenarioId' : bigint, 'gameId' : bigint }
export type GetScenarioResult = { 'ok' : Scenario } |
  { 'err' : GetScenarioError };
export type GetScenarioVoteError = { 'gameNotFound' : null } |
  { 'gameNotActive' : null } |
  { 'scenarioNotFound' : null };
export interface GetScenarioVoteRequest {
  'scenarioId' : bigint,
  'gameId' : bigint,
}
export type GetScenarioVoteResult = { 'ok' : ScenarioVote } |
  { 'err' : GetScenarioVoteError };
export type GetScenariosError = { 'gameNotFound' : null } |
  { 'gameNotActive' : null };
export interface GetScenariosRequest { 'gameId' : bigint }
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
export interface InProgressGameStateWithMetaData {
  'startTime' : Time,
  'character' : CharacterWithMetaData,
  'turn' : bigint,
  'locations' : Array<Location>,
}
export interface Item { 'id' : string, 'name' : string, 'description' : string }
export type JoinError = { 'alreadyMember' : null };
export interface Location {
  'id' : bigint,
  'scenarioId' : bigint,
  'coordinate' : AxialCoordinate,
  'zoneId' : string,
}
export type LocationKind = { 'common' : null } |
  { 'zoneIds' : Array<string> };
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
  'kind' : OutcomePathKind,
  'description' : string,
  'paths' : Array<WeightedOutcomePath>,
}
export type OutcomePathKind = { 'effects' : Array<Effect> } |
  { 'combat' : CombatPath };
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
export type ScenarioCategory = { 'other' : null } |
  { 'store' : null } |
  { 'combat' : null };
export interface ScenarioMetaData {
  'id' : string,
  'data' : Array<GeneratedDataField>,
  'name' : string,
  'description' : string,
  'category' : ScenarioCategory,
  'paths' : Array<OutcomePath>,
  'imageId' : string,
  'choices' : Array<Choice>,
  'location' : LocationKind,
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
export interface StartGameVoteRequest { 'gameId' : bigint }
export type StartGameVoteResult = { 'ok' : null } |
  {
    'err' : { 'notAuthorized' : null } |
      { 'gameNotFound' : null } |
      { 'gameAlreadyStarted' : null }
  };
export interface StatModifier {
  'characterStat' : CharacterStatKind__1,
  'factor' : number,
  'attribute' : WeaponAttribute,
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
export type UnlockRequirement = { 'acheivementId' : string };
export interface User {
  'id' : Principal,
  'createTime' : Time,
  'achievementIds' : Array<string>,
  'points' : bigint,
}
export interface UserStats { 'userCount' : bigint }
export interface Vote { 'votingPower' : bigint, 'choice' : [] | [boolean] }
export type VoteOnNewGameError = { 'invalidCharacterId' : null } |
  { 'alreadyVoted' : null } |
  { 'votingClosed' : null } |
  { 'alreadyStarted' : null } |
  { 'gameNotFound' : null } |
  { 'notEligible' : null } |
  { 'gameNotActive' : null };
export interface VoteOnNewGameRequest {
  'difficulty' : Difficulty,
  'gameId' : bigint,
  'characterId' : bigint,
}
export type VoteOnNewGameResult = { 'ok' : null } |
  { 'err' : VoteOnNewGameError };
export type VoteOnScenarioError = { 'alreadyVoted' : null } |
  { 'votingClosed' : null } |
  { 'invalidChoice' : null } |
  { 'gameNotFound' : null } |
  { 'notEligible' : null } |
  { 'gameNotActive' : null } |
  { 'scenarioNotFound' : null } |
  { 'choiceRequirementNotMet' : null };
export interface VoteOnScenarioRequest {
  'scenarioId' : bigint,
  'value' : string,
  'gameId' : bigint,
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
export interface VotingGameStateWithMetaData {
  'startTime' : Time,
  'characterVotes' : VotingSummary,
  'characterOptions' : Array<CharacterWithMetaData>,
  'difficultyVotes' : VotingSummary_1,
}
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
export interface Weapon {
  'id' : string,
  'name' : string,
  'description' : string,
  'baseStats' : WeaponStats,
  'requirements' : Array<WeaponRequirement>,
}
export type WeaponAttribute = { 'damage' : null } |
  { 'attacks' : null } |
  { 'criticalChance' : null } |
  { 'maxDamage' : null } |
  { 'minDamage' : null } |
  { 'criticalMultiplier' : null } |
  { 'accuracy' : null };
export type WeaponRequirement = { 'magic' : bigint } |
  { 'maxHealth' : bigint } |
  { 'speed' : bigint } |
  { 'defense' : bigint } |
  { 'attack' : bigint };
export interface WeaponStats {
  'attacks' : bigint,
  'criticalChance' : bigint,
  'maxDamage' : bigint,
  'minDamage' : bigint,
  'statModifiers' : Array<StatModifier>,
  'criticalMultiplier' : bigint,
  'accuracy' : bigint,
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
export interface Zone { 'id' : string, 'name' : string, 'description' : string }
export interface _SERVICE {
  'addGameContent' : ActorMethod<[AddGameContentRequest], AddGameContentResult>,
  'addUserToGame' : ActorMethod<[AddUserToGameRequest], AddUserToGameResult>,
  'createGame' : ActorMethod<[], CreateGameResult>,
  'createWorldProposal' : ActorMethod<
    [CreateWorldProposalRequest],
    CreateWorldProposalResult
  >,
  'getClasses' : ActorMethod<[], Array<Class>>,
  'getCompletedGames' : ActorMethod<[], Array<CompletedGameWithMetaData>>,
  'getCurrentGame' : ActorMethod<[], GetCurrentGameResult>,
  'getGame' : ActorMethod<[GetGameRequest], GetGameResult>,
  'getItems' : ActorMethod<[], Array<Item>>,
  'getRaces' : ActorMethod<[], Array<Race>>,
  'getScenario' : ActorMethod<[GetScenarioRequest], GetScenarioResult>,
  'getScenarioMetaDataList' : ActorMethod<[], Array<ScenarioMetaData>>,
  'getScenarioVote' : ActorMethod<
    [GetScenarioVoteRequest],
    GetScenarioVoteResult
  >,
  'getScenarios' : ActorMethod<[GetScenariosRequest], GetScenariosResult>,
  'getTopUsers' : ActorMethod<[GetTopUsersRequest], GetTopUsersResult>,
  'getTraits' : ActorMethod<[], Array<Trait>>,
  'getUser' : ActorMethod<[Principal], GetUserResult>,
  'getUserStats' : ActorMethod<[], GetUserStatsResult>,
  'getUsers' : ActorMethod<[GetUsersRequest], GetUsersResult>,
  'getWorldProposal' : ActorMethod<[bigint], GetWorldProposalResult>,
  'getWorldProposals' : ActorMethod<[bigint, bigint], PagedResult>,
  'http_request' : ActorMethod<[HttpRequest], HttpResponse>,
  'http_request_update' : ActorMethod<[HttpUpdateRequest], HttpResponse>,
  'join' : ActorMethod<[], Result>,
  'startGameVote' : ActorMethod<[StartGameVoteRequest], StartGameVoteResult>,
  'voteOnNewGame' : ActorMethod<[VoteOnNewGameRequest], VoteOnNewGameResult>,
  'voteOnScenario' : ActorMethod<[VoteOnScenarioRequest], VoteOnScenarioResult>,
  'voteOnWorldProposal' : ActorMethod<
    [VoteOnWorldProposalRequest],
    VoteOnWorldProposalResult
  >,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
