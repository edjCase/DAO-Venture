import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export type AbandonGameResult = { 'ok' : null } |
  { 'err' : { 'noActiveGame' : null } };
export interface Achievement {
  'id' : string,
  'name' : string,
  'description' : string,
}
export type AttackResult = { 'hit' : HitResult } |
  { 'miss' : null };
export type AttackerKind = { 'creature' : null } |
  { 'character' : null };
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
  { 'attack' : null };
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
export interface CombatResult {
  'turns' : Array<CombatTurn>,
  'healthDelta' : bigint,
  'kind' : CombatResultKind,
}
export type CombatResultKind = { 'maxTurnsReached' : null } |
  { 'defeat' : null } |
  { 'victory' : null };
export interface CombatTurn {
  'attacker' : AttackerKind,
  'attacks' : Array<AttackResult>,
}
export type CombatTurn__1 = {};
export interface CompletedGameStateWithMetaData {
  'endTime' : Time,
  'character' : CharacterWithMetaData,
  'victory' : boolean,
}
export interface CompletedGameWithMetaData {
  'id' : bigint,
  'startTime' : Time,
  'endTime' : Time,
  'character' : CharacterWithMetaData,
  'difficulty' : Difficulty,
  'playerId' : Principal,
  'victory' : boolean,
}
export type Condition = { 'hasGold' : NatValue } |
  { 'hasItem' : TextValue } |
  { 'hasTrait' : TextValue };
export type CreateGameError = { 'noTraits' : null } |
  { 'noWeapons' : null } |
  { 'noCreaturesForZone' : string } |
  { 'noZones' : null } |
  { 'notAuthenticated' : null } |
  { 'noItems' : null } |
  { 'noScenariosForZone' : string } |
  { 'noClasses' : null } |
  { 'noCreatures' : null } |
  { 'noRaces' : null } |
  { 'noScenarios' : null } |
  { 'noImages' : null } |
  { 'alreadyInitialized' : null };
export interface CreateGameRequest { 'difficulty' : Difficulty }
export type CreateGameResult = { 'ok' : null } |
  { 'err' : CreateGameError };
export type CreateWorldProposalError = { 'invalid' : Array<string> } |
  { 'notEligible' : null };
export type CreateWorldProposalRequest = { 'motion' : MotionContent } |
  { 'modifyGameContent' : ModifyGameContent };
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
  'unlockRequirement' : [] | [UnlockRequirement],
  'attack' : bigint,
  'location' : CreatureLocationKind,
  'health' : bigint,
}
export type CreatureKind = { 'normal' : null } |
  { 'boss' : null } |
  { 'elite' : null };
export type CreatureLocationKind = { 'common' : null } |
  { 'zoneIds' : Array<string> };
export type Difficulty = { 'normal' : null } |
  { 'easy' : null } |
  { 'hard' : null };
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
export type GameStateWithMetaData = {
    'starting' : StartingGameStateWithMetaData
  } |
  { 'completed' : CompletedGameStateWithMetaData } |
  { 'inProgress' : InProgressGameStateWithMetaData };
export interface GameWithMetaData {
  'id' : bigint,
  'startTime' : Time,
  'difficulty' : Difficulty,
  'playerId' : Principal,
  'state' : GameStateWithMetaData,
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
export interface GetCompletedGamesRequest {
  'count' : bigint,
  'offset' : bigint,
}
export type GetCurrentGameResult = { 'ok' : [] | [GameWithMetaData] } |
  { 'err' : { 'notAuthenticated' : null } };
export type GetScenarioError = { 'notFound' : null } |
  { 'gameNotFound' : null } |
  { 'gameNotActive' : null };
export interface GetScenarioRequest { 'scenarioId' : bigint }
export type GetScenarioResult = { 'ok' : Scenario } |
  { 'err' : GetScenarioError };
export type GetScenariosError = { 'gameNotFound' : null } |
  { 'gameNotActive' : null };
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
export interface HitResult { 'damage' : bigint }
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
  'turnKind' : TurnKind,
  'character' : CharacterWithMetaData,
}
export interface Item {
  'id' : string,
  'name' : string,
  'description' : string,
  'unlockRequirement' : [] | [UnlockRequirement],
  'image' : PixelImage,
}
export type LocationKind = { 'common' : null } |
  { 'zoneIds' : Array<string> };
export type ModifyGameContent = { 'trait' : Trait } |
  { 'creature' : Creature } |
  { 'item' : Item } |
  { 'class' : Class } |
  { 'race' : Race } |
  { 'zone' : Zone } |
  { 'achievement' : Achievement } |
  { 'image' : Image } |
  { 'scenario' : ScenarioMetaData } |
  { 'weapon' : Weapon };
export interface MotionContent { 'title' : string, 'description' : string }
export type NatValue = { 'raw' : bigint } |
  { 'dataField' : string } |
  { 'random' : [bigint, bigint] };
export interface Outcome { 'log' : Array<OutcomeLogEntry>, 'choiceId' : string }
export type OutcomeLogEntry = { 'speedDelta' : bigint } |
  { 'removeTrait' : string } |
  { 'healthDelta' : bigint } |
  { 'maxHealthDelta' : bigint } |
  { 'text' : string } |
  { 'defenseDelta' : bigint } |
  { 'attackDelta' : bigint } |
  { 'addItem' : string } |
  { 'addTrait' : string } |
  { 'goldDelta' : bigint } |
  { 'removeItem' : string } |
  { 'combat' : CombatResult } |
  { 'magicDelta' : bigint };
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
export interface PagedResult_2 {
  'data' : Array<CompletedGameWithMetaData>,
  'count' : bigint,
  'totalCount' : bigint,
  'offset' : bigint,
}
export interface PixelData { 'count' : bigint, 'paletteIndex' : [] | [number] }
export interface PixelImage {
  'palette' : Array<[number, number, number]>,
  'pixelData' : Array<PixelData>,
}
export type ProposalContent = { 'motion' : MotionContent } |
  { 'modifyGameContent' : ModifyGameContent };
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
  'unlockRequirement' : [] | [UnlockRequirement],
  'modifiers' : Array<CharacterModifier>,
}
export type RandomOrSpecificTextValue = { 'specific' : TextValue } |
  { 'random' : null };
export type RegisterError = { 'alreadyMember' : null };
export type RegisterResult = { 'ok' : User } |
  { 'err' : RegisterError };
export interface Scenario {
  'id' : bigint,
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
  'unlockRequirement' : [] | [UnlockRequirement],
  'category' : ScenarioCategory,
  'paths' : Array<OutcomePath>,
  'imageId' : string,
  'choices' : Array<Choice>,
  'location' : LocationKind,
}
export interface ScenarioTurn { 'scenarioId' : bigint }
export type SelectScenarioChoiceError = { 'invalidChoice' : null } |
  { 'gameNotFound' : null } |
  { 'gameNotActive' : null } |
  { 'choiceRequirementNotMet' : null } |
  { 'notScenarioTurn' : null };
export interface SelectScenarioChoiceRequest { 'choiceId' : string }
export type SelectScenarioChoiceResult = { 'ok' : null } |
  { 'err' : SelectScenarioChoiceError };
export interface StartGameRequest { 'characterId' : bigint }
export type StartGameResult = { 'ok' : null } |
  {
    'err' : { 'invalidCharacterId' : null } |
      { 'alreadyStarted' : null } |
      { 'gameNotFound' : null }
  };
export interface StartingGameStateWithMetaData {
  'characterOptions' : Array<CharacterWithMetaData>,
}
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
  'unlockRequirement' : [] | [UnlockRequirement],
  'image' : PixelImage,
}
export type TurnKind = { 'scenario' : ScenarioTurn } |
  { 'combat' : CombatTurn__1 };
export type UnlockRequirement = { 'acheivementId' : string };
export interface User {
  'id' : Principal,
  'createTime' : Time,
  'achievementIds' : Array<string>,
  'points' : bigint,
}
export interface UserStats { 'userCount' : bigint }
export interface Vote { 'votingPower' : bigint, 'choice' : [] | [boolean] }
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
export interface Weapon {
  'id' : string,
  'name' : string,
  'description' : string,
  'baseStats' : WeaponStats,
  'unlockRequirement' : [] | [UnlockRequirement],
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
export interface Zone {
  'id' : string,
  'name' : string,
  'description' : string,
  'unlockRequirement' : [] | [UnlockRequirement],
}
export interface _SERVICE {
  'abandonGame' : ActorMethod<[], AbandonGameResult>,
  'createGame' : ActorMethod<[CreateGameRequest], CreateGameResult>,
  'createWorldProposal' : ActorMethod<
    [CreateWorldProposalRequest],
    CreateWorldProposalResult
  >,
  'getClasses' : ActorMethod<[], Array<Class>>,
  'getCompletedGames' : ActorMethod<[GetCompletedGamesRequest], PagedResult_2>,
  'getCurrentGame' : ActorMethod<[], GetCurrentGameResult>,
  'getItems' : ActorMethod<[], Array<Item>>,
  'getRaces' : ActorMethod<[], Array<Race>>,
  'getScenario' : ActorMethod<[GetScenarioRequest], GetScenarioResult>,
  'getScenarioMetaDataList' : ActorMethod<[], Array<ScenarioMetaData>>,
  'getScenarios' : ActorMethod<[], GetScenariosResult>,
  'getTopUsers' : ActorMethod<[GetTopUsersRequest], GetTopUsersResult>,
  'getTraits' : ActorMethod<[], Array<Trait>>,
  'getUser' : ActorMethod<[Principal], GetUserResult>,
  'getUserStats' : ActorMethod<[], GetUserStatsResult>,
  'getUsers' : ActorMethod<[GetUsersRequest], GetUsersResult>,
  'getWorldProposal' : ActorMethod<[bigint], GetWorldProposalResult>,
  'getWorldProposals' : ActorMethod<[bigint, bigint], PagedResult>,
  'http_request' : ActorMethod<[HttpRequest], HttpResponse>,
  'http_request_update' : ActorMethod<[HttpUpdateRequest], HttpResponse>,
  'register' : ActorMethod<[], RegisterResult>,
  'selectScenarioChoice' : ActorMethod<
    [SelectScenarioChoiceRequest],
    SelectScenarioChoiceResult
  >,
  'startGame' : ActorMethod<[StartGameRequest], StartGameResult>,
  'voteOnWorldProposal' : ActorMethod<
    [VoteOnWorldProposalRequest],
    VoteOnWorldProposalResult
  >,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
