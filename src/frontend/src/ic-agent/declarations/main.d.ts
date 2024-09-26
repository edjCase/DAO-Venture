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
  'name' : string,
  'description' : string,
  'target' : ActionTarget,
  'scenarioEffects' : Array<ScenarioEffect>,
  'combatEffects' : Array<CombatEffect>,
}
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
export interface AddItemOutcomeEffect {
  'itemId' : string,
  'removedItemId' : [] | [string],
}
export type Attribute = { 'dexterity' : null } |
  { 'wisdom' : null } |
  { 'strength' : null } |
  { 'charisma' : null };
export interface AttributeChoiceRequirement {
  'value' : bigint,
  'attribute' : Attribute,
}
export interface AttributeScenarioEffect {
  'value' : bigint,
  'attribute' : Attribute,
}
export interface Block {
  'max' : bigint,
  'min' : bigint,
  'timing' : ActionTimingKind,
}
export interface BlockLogEntry {
  'source' : TargetKind,
  'target' : TargetKind,
  'amount' : bigint,
}
export type CharacterActionKind = { 'item' : null } |
  { 'skill' : null } |
  { 'weapon' : null };
export interface CharacterActionWithMetaData {
  'action' : Action,
  'kind' : CharacterActionKind,
}
export interface CharacterAttributes {
  'dexterity' : bigint,
  'wisdom' : bigint,
  'strength' : bigint,
  'charisma' : bigint,
}
export interface CharacterCombatState {
  'weaponActionId' : [] | [string],
  'statusEffects' : Array<StatusEffectResult>,
  'maxHealth' : bigint,
  'skillActionId' : [] | [string],
  'block' : bigint,
  'itemActionId' : [] | [string],
  'health' : bigint,
}
export interface CharacterWithMetaData {
  'maxHealth' : bigint,
  'gold' : bigint,
  'class' : Class,
  'race' : Race,
  'actions' : Array<CharacterActionWithMetaData>,
  'attributes' : CharacterAttributes,
  'inventorySlots' : Array<InventorySlotWithMetaData>,
  'weapon' : Weapon,
  'health' : bigint,
}
export interface Choice {
  'id' : string,
  'effects' : Array<PathEffect>,
  'description' : string,
  'requirement' : [] | [ChoiceRequirement],
  'nextPath' : NextPathKind,
}
export interface ChoicePath { 'choices' : Array<Choice> }
export type ChoiceRequirement = { 'itemWithTags' : Array<string> } |
  { 'gold' : bigint } |
  { 'attribute' : AttributeChoiceRequirement };
export type ChoiceResultKind = { 'complete' : null } |
  { 'death' : null };
export interface ChoiceScenarioState { 'choices' : Array<Choice> }
export interface Class {
  'id' : string,
  'startingSkillActionIds' : Array<string>,
  'name' : string,
  'description' : string,
  'startingItemIds' : Array<string>,
  'weaponId' : string,
  'unlockRequirement' : [] | [UnlockRequirement],
  'image' : PixelImage,
}
export interface CombatChoice {
  'kind' : CharacterActionKind,
  'target' : [] | [ActionTargetResult],
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
export interface CombatEffect {
  'kind' : CombatEffectKind,
  'target' : CombatEffectTarget,
}
export type CombatEffectKind = { 'damage' : Damage } |
  { 'heal' : Heal } |
  { 'addStatusEffect' : StatusEffect } |
  { 'block' : Block };
export type CombatEffectTarget = { 'self' : null } |
  { 'targets' : null };
export type CombatLogEntry = { 'damage' : DamageLogEntry } |
  { 'heal' : HealLogEntry } |
  { 'block' : BlockLogEntry } |
  { 'statusEffect' : StatusEffectLogEntry };
export interface CombatPath {
  'creatures' : Array<CombatCreatureKind>,
  'nextPath' : NextPathKind,
}
export type CombatResultKind = { 'defeat' : CombatDefeatResult } |
  { 'victory' : CombatVictoryResult } |
  { 'inProgress' : CombatScenarioState };
export interface CombatScenarioState {
  'character' : CharacterCombatState,
  'creatures' : Array<CreatureCombatState>,
  'nextPath' : NextPathKind,
}
export type CombatTurn = {};
export interface CombatVictoryResult { 'characterHealth' : bigint }
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
  'playerId' : Principal,
  'victory' : boolean,
}
export type CreateGameError = { 'noWeapons' : null } |
  { 'noCreaturesForZone' : string } |
  { 'noZones' : null } |
  { 'notAuthenticated' : null } |
  { 'noItems' : null } |
  { 'noScenariosForZone' : string } |
  { 'noClasses' : null } |
  { 'noCreatures' : null } |
  { 'noRaces' : null } |
  { 'noScenarios' : null } |
  { 'alreadyInitialized' : null };
export type CreateGameRequest = {};
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
  'actionIds' : Array<string>,
  'statusEffects' : Array<StatusEffectResult>,
  'maxHealth' : bigint,
  'creatureId' : string,
  'block' : bigint,
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
export interface DamageLogEntry {
  'source' : TargetKind,
  'target' : TargetKind,
  'amount' : bigint,
}
export type GameStateWithMetaData = {
    'starting' : StartingGameStateWithMetaData
  } |
  { 'completed' : CompletedGameStateWithMetaData } |
  { 'inProgress' : InProgressGameStateWithMetaData };
export interface GameWithMetaData {
  'id' : bigint,
  'startTime' : Time,
  'playerId' : Principal,
  'state' : GameStateWithMetaData,
}
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
export interface Heal {
  'max' : bigint,
  'min' : bigint,
  'timing' : ActionTimingKind,
}
export interface HealLogEntry {
  'source' : TargetKind,
  'target' : TargetKind,
  'amount' : bigint,
}
export interface InProgressGameStateWithMetaData {
  'turnKind' : TurnKind,
  'character' : CharacterWithMetaData,
}
export type InProgressScenarioStateKind = { 'reward' : RewardScenarioState } |
  { 'choice' : ChoiceScenarioState } |
  { 'combat' : CombatScenarioState };
export interface InventorySlotWithMetaData { 'item' : [] | [Item] }
export interface Item {
  'id' : string,
  'actionIds' : Array<string>,
  'name' : string,
  'tags' : Array<string>,
  'description' : string,
  'unlockRequirement' : [] | [UnlockRequirement],
  'image' : PixelImage,
}
export interface ItemRewardChoice { 'id' : string, 'inventorySlot' : bigint }
export type LocationKind = { 'common' : null } |
  { 'zoneIds' : Array<string> };
export type ModifyGameContent = { 'action' : Action } |
  { 'creature' : Creature } |
  { 'item' : Item } |
  { 'class' : Class } |
  { 'race' : Race } |
  { 'zone' : Zone } |
  { 'achievement' : Achievement } |
  { 'scenario' : ScenarioMetaData } |
  { 'weapon' : Weapon };
export interface MotionContent { 'title' : string, 'description' : string }
export type NatValue = { 'raw' : bigint } |
  { 'random' : [bigint, bigint] };
export type NextPathKind = { 'multi' : Array<WeightedScenarioPathOption> } |
  { 'none' : null } |
  { 'single' : string };
export interface OptionWeight { 'value' : number, 'kind' : WeightKind }
export type OutcomeEffect = { 'healthDelta' : bigint } |
  { 'maxHealthDelta' : bigint } |
  { 'text' : string } |
  { 'swapWeapon' : SwapWeaponOutcomeEffect } |
  { 'addItem' : AddItemOutcomeEffect } |
  { 'goldDelta' : bigint } |
  { 'removeItem' : string };
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
export type PathEffect = { 'damage' : NatValue } |
  { 'heal' : NatValue } |
  { 'removeItemWithTags' : Array<string> } |
  { 'achievement' : string } |
  { 'addItem' : string } |
  { 'addItemWithTags' : Array<string> } |
  { 'removeGold' : NatValue } |
  { 'removeItem' : string };
export type PeriodicEffectKind = { 'damage' : null } |
  { 'heal' : null } |
  { 'block' : null };
export interface PeriodicEffectResult {
  'kind' : PeriodicEffectKind,
  'phase' : TurnPhase,
  'amount' : bigint,
}
export interface PeriodicTiming { 'phase' : TurnPhase, 'turnDuration' : bigint }
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
  'startingSkillActionIds' : Array<string>,
  'name' : string,
  'description' : string,
  'startingItemIds' : Array<string>,
  'unlockRequirement' : [] | [UnlockRequirement],
  'image' : PixelImage,
}
export type RegisterError = { 'alreadyMember' : null };
export type RegisterResult = { 'ok' : User } |
  { 'err' : RegisterError };
export type Retaliating = { 'flat' : bigint };
export type RewardChoice = { 'gold' : bigint } |
  { 'item' : ItemRewardChoice } |
  { 'weapon' : string } |
  { 'health' : bigint };
export type RewardKind = { 'gold' : bigint } |
  { 'item' : string } |
  { 'weapon' : string } |
  { 'health' : bigint };
export interface RewardPath {
  'kind' : RewardPathKind,
  'nextPath' : NextPathKind,
}
export type RewardPathKind = { 'random' : null } |
  { 'specificItemIds' : Array<string> };
export interface RewardScenarioState {
  'options' : Array<RewardKind>,
  'nextPath' : NextPathKind,
}
export interface Scenario {
  'id' : bigint,
  'metaDataId' : string,
  'metaData' : ScenarioMetaData,
  'state' : ScenarioStateKind,
  'previousStages' : Array<ScenarioStageResult>,
}
export type ScenarioCategory = { 'other' : null } |
  { 'store' : null } |
  { 'combat' : null };
export interface ScenarioChoiceResult {
  'kind' : ChoiceResultKind,
  'choice' : Choice,
}
export interface ScenarioCombatResult {
  'log' : Array<CombatLogEntry>,
  'kind' : CombatResultKind,
}
export type ScenarioEffect = { 'attribute' : AttributeScenarioEffect };
export interface ScenarioMetaData {
  'id' : string,
  'name' : string,
  'description' : string,
  'unlockRequirement' : [] | [UnlockRequirement],
  'category' : ScenarioCategory,
  'paths' : Array<ScenarioPath>,
  'image' : PixelImage,
  'location' : LocationKind,
}
export interface ScenarioPath {
  'id' : string,
  'kind' : ScenarioPathKind,
  'description' : string,
}
export type ScenarioPathKind = { 'reward' : RewardPath } |
  { 'choice' : ChoicePath } |
  { 'combat' : CombatPath };
export interface ScenarioRewardResult { 'kind' : RewardKind }
export interface ScenarioStageResult {
  'effects' : Array<OutcomeEffect>,
  'kind' : ScenarioStageResultKind,
}
export type ScenarioStageResultKind = { 'reward' : ScenarioRewardResult } |
  { 'choice' : ScenarioChoiceResult } |
  { 'combat' : ScenarioCombatResult };
export type ScenarioStateKind = { 'completed' : null } |
  { 'inProgress' : InProgressScenarioStateKind };
export interface ScenarioTurn { 'scenarioId' : bigint }
export type SelectScenarioChoiceError = { 'invalidTarget' : null } |
  { 'targetRequired' : null } |
  { 'invalidChoice' : string } |
  { 'gameNotFound' : null } |
  { 'gameNotActive' : null } |
  { 'notScenarioTurn' : null };
export interface SelectScenarioChoiceRequest { 'choice' : StageChoiceKind }
export type SelectScenarioChoiceResult = { 'ok' : null } |
  { 'err' : SelectScenarioChoiceError };
export type StageChoiceKind = { 'reward' : RewardChoice } |
  { 'choice' : string } |
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
  'kind' : StatusEffectKind,
}
export type StatusEffectKind = { 'retaliating' : Retaliating } |
  { 'brittle' : null } |
  { 'weak' : null } |
  { 'vulnerable' : null } |
  { 'necrotic' : null } |
  { 'stunned' : null };
export interface StatusEffectLogEntry {
  'source' : TargetKind,
  'target' : TargetKind,
  'statusEffect' : StatusEffectResult,
}
export interface StatusEffectResult {
  'kind' : StatusEffectResultKind,
  'remainingTurns' : bigint,
}
export type StatusEffectResultKind = { 'retaliating' : Retaliating } |
  { 'brittle' : null } |
  { 'weak' : null } |
  { 'vulnerable' : null } |
  { 'necrotic' : null } |
  { 'stunned' : null } |
  { 'periodic' : PeriodicEffectResult };
export interface SwapWeaponOutcomeEffect {
  'removedWeaponId' : string,
  'weaponId' : string,
}
export type TargetKind = { 'creature' : bigint } |
  { 'character' : null } |
  { 'periodicEffect' : null };
export type Time = bigint;
export type TurnKind = { 'scenario' : ScenarioTurn } |
  { 'combat' : CombatTurn };
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
  'image' : PixelImage,
}
export type WeightKind = { 'raw' : null } |
  { 'attributeScaled' : Attribute };
export interface WeightedScenarioPathOption {
  'weight' : OptionWeight,
  'effects' : Array<PathEffect>,
  'description' : string,
  'pathId' : [] | [string],
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
  'getAchievements' : ActorMethod<[], Array<Achievement>>,
  'getActions' : ActorMethod<[], Array<Action>>,
  'getClasses' : ActorMethod<[], Array<Class>>,
  'getCompletedGames' : ActorMethod<[GetCompletedGamesRequest], PagedResult_2>,
  'getCreatures' : ActorMethod<[], Array<Creature>>,
  'getCurrentGame' : ActorMethod<[], GetCurrentGameResult>,
  'getItems' : ActorMethod<[], Array<Item>>,
  'getRaces' : ActorMethod<[], Array<Race>>,
  'getScenario' : ActorMethod<[GetScenarioRequest], GetScenarioResult>,
  'getScenarioMetaDataList' : ActorMethod<[], Array<ScenarioMetaData>>,
  'getScenarios' : ActorMethod<[], GetScenariosResult>,
  'getTopUsers' : ActorMethod<[GetTopUsersRequest], GetTopUsersResult>,
  'getUser' : ActorMethod<[Principal], GetUserResult>,
  'getUserStats' : ActorMethod<[], GetUserStatsResult>,
  'getUsers' : ActorMethod<[GetUsersRequest], GetUsersResult>,
  'getWeapons' : ActorMethod<[], Array<Weapon>>,
  'getWorldProposal' : ActorMethod<[bigint], GetWorldProposalResult>,
  'getWorldProposals' : ActorMethod<[bigint, bigint], PagedResult>,
  'getZones' : ActorMethod<[], Array<Zone>>,
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
