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
export interface Action {
  'id' : string,
  'effects' : Array<ActionEffect>,
  'name' : string,
  'description' : string,
}
export interface ActionEffect {
  'kind' : ActionEffectKind,
  'target' : ActionTarget,
}
export type ActionEffectKind = { 'damage' : Damage } |
  { 'heal' : Heal } |
  { 'addStatusEffect' : StatusEffect } |
  { 'block' : Block };
export interface ActionTarget {
  'scope' : ActionTargetScope,
  'selection' : ActionTargetSelection,
}
export type ActionTargetResult = { 'creature' : bigint } |
  { 'character' : null };
export type ActionTargetScope = { 'any' : null } |
  { 'ally' : null } |
  { 'enemy' : null };
export type ActionTargetSelection = { 'all' : null } |
  { 'random' : { 'count' : bigint } } |
  { 'chosen' : null };
export type ActionTimingKind = { 'periodic' : PeriodicTiming } |
  { 'immediate' : null };
export interface Block {
  'max' : bigint,
  'min' : bigint,
  'timing' : ActionTimingKind,
}
export interface CallbackStrategy {
  'token' : Token,
  'callback' : [Principal, string],
}
export interface CharacterCombatState {
  'shield' : bigint,
  'statusEffects' : Array<StatusEffectResult>,
  'availableActionIds' : Array<string>,
}
export interface CharacterWithMetaData {
  'maxHealth' : bigint,
  'gold' : bigint,
  'traits' : Array<Trait>,
  'class' : Class,
  'race' : Race,
  'actions' : Array<Action>,
  'items' : Array<Item>,
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
  { 'race' : string };
export interface ChoiceScenarioState { 'choiceIds' : Array<string> }
export interface Class {
  'id' : string,
  'actionIds' : Array<string>,
  'name' : string,
  'description' : string,
  'weaponId' : string,
  'unlockRequirement' : [] | [UnlockRequirement],
  'startingTraitIds' : Array<string>,
}
export interface CombatChoice {
  'target' : [] | [ActionTargetResult],
  'actionId' : string,
}
export interface CombatCreatureFilter {
  'location' : CombatCreatureLocationFilter,
}
export type CombatCreatureKind = { 'id' : string } |
  { 'filter' : CombatCreatureFilter };
export type CombatCreatureLocationFilter = { 'any' : null } |
  { 'zone' : string } |
  { 'common' : null };
export interface CombatDefeatResult { 'creatures' : Array<CreatureCombatState> }
export interface CombatPath { 'creatures' : Array<CombatCreatureKind> }
export interface CombatResult {
  'turns' : Array<CombatTurn>,
  'healthDelta' : bigint,
  'victory' : boolean,
}
export interface CombatScenarioState {
  'character' : CharacterCombatState,
  'creatures' : Array<CreatureCombatState>,
}
export type CombatTurn = { 'action' : string } |
  { 'nothing' : null };
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
  'actionIds' : Array<string>,
  'maxHealth' : bigint,
  'kind' : CreatureKind,
  'name' : string,
  'description' : string,
  'weaponId' : string,
  'unlockRequirement' : [] | [UnlockRequirement],
  'location' : CreatureLocationKind,
  'health' : bigint,
}
export interface CreatureCombatState {
  'shield' : bigint,
  'statusEffects' : Array<StatusEffectResult>,
  'maxHealth' : bigint,
  'availableActionIds' : Array<string>,
  'creatureId' : string,
  'health' : bigint,
}
export type CreatureKind = { 'normal' : null } |
  { 'boss' : null } |
  { 'elite' : null };
export type CreatureLocationKind = { 'common' : null } |
  { 'zoneIds' : Array<string> };
export interface Damage {
  'max' : bigint,
  'min' : bigint,
  'timing' : ActionTimingKind,
}
export type Difficulty = { 'normal' : null } |
  { 'easy' : null } |
  { 'hard' : null };
export type Effect = { 'reward' : null } |
  { 'removeTrait' : RandomOrSpecificTextValue } |
  { 'damage' : NatValue } |
  { 'heal' : NatValue } |
  { 'achievement' : string } |
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
export interface Heal {
  'max' : bigint,
  'min' : bigint,
  'timing' : ActionTimingKind,
}
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
export type OutcomeEffect = { 'removeTrait' : string } |
  { 'healthDelta' : bigint } |
  { 'maxHealthDelta' : bigint } |
  { 'text' : string } |
  { 'addItem' : string } |
  { 'addTrait' : string } |
  { 'goldDelta' : bigint } |
  { 'removeItem' : string } |
  { 'combat' : CombatResult };
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
export type PeriodicEffectKind = { 'damage' : null } |
  { 'heal' : null } |
  { 'block' : null };
export interface PeriodicEffectResult {
  'kind' : PeriodicEffectKind,
  'phase' : TurnPhase,
  'amount' : bigint,
}
export interface PeriodicTiming {
  'remainingTurns' : bigint,
  'phase' : TurnPhase,
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
  'actionIds' : Array<string>,
  'name' : string,
  'description' : string,
  'unlockRequirement' : [] | [UnlockRequirement],
  'startingTraitIds' : Array<string>,
}
export type RandomOrSpecificTextValue = { 'specific' : TextValue } |
  { 'random' : null };
export type RegisterError = { 'alreadyMember' : null };
export type RegisterResult = { 'ok' : User } |
  { 'err' : RegisterError };
export type Retaliating = { 'flat' : bigint };
export interface Scenario {
  'id' : bigint,
  'metaDataId' : string,
  'metaData' : ScenarioMetaData,
  'data' : Array<GeneratedDataFieldInstance>,
  'state' : ScenarioStateKind,
  'previousStages' : Array<ScenarioStageResult>,
}
export type ScenarioCategory = { 'other' : null } |
  { 'store' : null } |
  { 'combat' : null };
export interface ScenarioChoiceResult {
  'choiceId' : string,
  'kind' : ScenarioChoiceResultKind,
}
export type ScenarioChoiceResultKind = { 'startCombat' : CombatScenarioState } |
  { 'complete' : null } |
  { 'choice' : ChoiceScenarioState } |
  { 'death' : null };
export type ScenarioCombatResult = { 'defeat' : CombatDefeatResult } |
  { 'victory' : null } |
  { 'inProgress' : CombatScenarioState };
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
export interface ScenarioStageResult {
  'effects' : Array<OutcomeEffect>,
  'kind' : ScenarioStageResultKind,
}
export type ScenarioStageResultKind = { 'choice' : ScenarioChoiceResult } |
  { 'combat' : ScenarioCombatResult };
export type ScenarioStateKind = { 'complete' : null } |
  { 'choice' : ChoiceScenarioState } |
  { 'combat' : CombatScenarioState };
export interface ScenarioTurn { 'scenarioId' : bigint }
export type SelectScenarioChoiceError = { 'invalidTarget' : null } |
  { 'targetRequired' : null } |
  { 'invalidChoice' : null } |
  { 'gameNotFound' : null } |
  { 'gameNotActive' : null } |
  { 'notScenarioTurn' : null };
export interface SelectScenarioChoiceRequest { 'choice' : StageChoiceKind }
export type SelectScenarioChoiceResult = { 'ok' : null } |
  { 'err' : SelectScenarioChoiceError };
export type StageChoiceKind = { 'choice' : string } |
  { 'combat' : CombatChoice };
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
export interface StatusEffect {
  'duration' : [] | [bigint],
  'kind' : StatusEffectKind__1,
}
export type StatusEffectKind = { 'retaliating' : Retaliating } |
  { 'weak' : null } |
  { 'vulnerable' : null } |
  { 'stunned' : null } |
  { 'periodic' : PeriodicEffectResult };
export type StatusEffectKind__1 = { 'retaliating' : Retaliating } |
  { 'weak' : null } |
  { 'vulnerable' : null } |
  { 'stunned' : null };
export interface StatusEffectResult {
  'kind' : StatusEffectKind,
  'remainingTurns' : bigint,
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
export type TurnPhase = { 'end' : null } |
  { 'start' : null };
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
  'actionIds' : Array<string>,
  'name' : string,
  'description' : string,
  'unlockRequirement' : [] | [UnlockRequirement],
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
