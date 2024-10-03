export const idlFactory = ({ IDL }) => {
  const AbandonGameResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : IDL.Variant({ 'noActiveGame' : IDL.Null }),
  });
  const CreateGameRequest = IDL.Record({});
  const CreateGameError = IDL.Variant({
    'noWeapons' : IDL.Null,
    'noCreaturesForZone' : IDL.Text,
    'noZones' : IDL.Null,
    'notAuthenticated' : IDL.Null,
    'noItems' : IDL.Null,
    'noScenariosForZone' : IDL.Text,
    'noClasses' : IDL.Null,
    'noCreatures' : IDL.Null,
    'noRaces' : IDL.Null,
    'noScenarios' : IDL.Null,
    'userNotRegistered' : IDL.Null,
    'alreadyInitialized' : IDL.Null,
  });
  const CreateGameResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : CreateGameError,
  });
  const MotionContent = IDL.Record({
    'title' : IDL.Text,
    'description' : IDL.Text,
  });
  const ActionTargetScope = IDL.Variant({
    'any' : IDL.Null,
    'ally' : IDL.Null,
    'enemy' : IDL.Null,
  });
  const ActionTargetSelection = IDL.Variant({
    'all' : IDL.Null,
    'random' : IDL.Record({ 'count' : IDL.Nat }),
    'chosen' : IDL.Null,
  });
  const ActionTarget = IDL.Record({
    'scope' : ActionTargetScope,
    'selection' : ActionTargetSelection,
  });
  const Attribute = IDL.Variant({
    'dexterity' : IDL.Null,
    'wisdom' : IDL.Null,
    'strength' : IDL.Null,
    'charisma' : IDL.Null,
  });
  const AttributeScenarioEffect = IDL.Record({
    'value' : IDL.Int,
    'attribute' : Attribute,
  });
  const ScenarioEffect = IDL.Variant({ 'attribute' : AttributeScenarioEffect });
  const TurnPhase = IDL.Variant({ 'end' : IDL.Null, 'start' : IDL.Null });
  const PeriodicTiming = IDL.Record({
    'phase' : TurnPhase,
    'turnDuration' : IDL.Nat,
  });
  const ActionTimingKind = IDL.Variant({
    'periodic' : PeriodicTiming,
    'immediate' : IDL.Null,
  });
  const Damage = IDL.Record({
    'max' : IDL.Nat,
    'min' : IDL.Nat,
    'timing' : ActionTimingKind,
  });
  const Heal = IDL.Record({
    'max' : IDL.Nat,
    'min' : IDL.Nat,
    'timing' : ActionTimingKind,
  });
  const Retaliating = IDL.Variant({ 'flat' : IDL.Nat });
  const StatusEffectKind = IDL.Variant({
    'retaliating' : Retaliating,
    'brittle' : IDL.Null,
    'weak' : IDL.Null,
    'vulnerable' : IDL.Null,
    'necrotic' : IDL.Null,
    'stunned' : IDL.Null,
  });
  const StatusEffect = IDL.Record({
    'duration' : IDL.Opt(IDL.Nat),
    'kind' : StatusEffectKind,
  });
  const Block = IDL.Record({
    'max' : IDL.Nat,
    'min' : IDL.Nat,
    'timing' : ActionTimingKind,
  });
  const CombatEffectKind = IDL.Variant({
    'damage' : Damage,
    'heal' : Heal,
    'addStatusEffect' : StatusEffect,
    'block' : Block,
  });
  const CombatEffectTarget = IDL.Variant({
    'self' : IDL.Null,
    'targets' : IDL.Null,
  });
  const CombatEffect = IDL.Record({
    'kind' : CombatEffectKind,
    'target' : CombatEffectTarget,
  });
  const Action = IDL.Record({
    'id' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
    'target' : ActionTarget,
    'scenarioEffects' : IDL.Vec(ScenarioEffect),
    'combatEffects' : IDL.Vec(CombatEffect),
  });
  const CreatureKind = IDL.Variant({
    'normal' : IDL.Null,
    'boss' : IDL.Null,
    'elite' : IDL.Null,
  });
  const UnlockRequirement = IDL.Variant({
    'achievementId' : IDL.Text,
    'none' : IDL.Null,
  });
  const CreatureLocationKind = IDL.Variant({
    'common' : IDL.Null,
    'zoneIds' : IDL.Vec(IDL.Text),
  });
  const Creature = IDL.Record({
    'id' : IDL.Text,
    'actionIds' : IDL.Vec(IDL.Text),
    'maxHealth' : IDL.Nat,
    'kind' : CreatureKind,
    'name' : IDL.Text,
    'description' : IDL.Text,
    'weaponId' : IDL.Text,
    'unlockRequirement' : UnlockRequirement,
    'location' : CreatureLocationKind,
    'health' : IDL.Nat,
  });
  const PixelData = IDL.Record({
    'count' : IDL.Nat,
    'paletteIndex' : IDL.Opt(IDL.Nat8),
  });
  const PixelImage = IDL.Record({
    'palette' : IDL.Vec(IDL.Tuple(IDL.Nat8, IDL.Nat8, IDL.Nat8)),
    'pixelData' : IDL.Vec(PixelData),
  });
  const Item = IDL.Record({
    'id' : IDL.Text,
    'actionIds' : IDL.Vec(IDL.Text),
    'name' : IDL.Text,
    'tags' : IDL.Vec(IDL.Text),
    'description' : IDL.Text,
    'unlockRequirement' : UnlockRequirement,
    'image' : PixelImage,
  });
  const Class = IDL.Record({
    'id' : IDL.Text,
    'startingSkillActionIds' : IDL.Vec(IDL.Text),
    'name' : IDL.Text,
    'description' : IDL.Text,
    'startingItemIds' : IDL.Vec(IDL.Text),
    'weaponId' : IDL.Text,
    'unlockRequirement' : UnlockRequirement,
    'image' : PixelImage,
  });
  const Race = IDL.Record({
    'id' : IDL.Text,
    'startingSkillActionIds' : IDL.Vec(IDL.Text),
    'name' : IDL.Text,
    'description' : IDL.Text,
    'startingItemIds' : IDL.Vec(IDL.Text),
    'unlockRequirement' : UnlockRequirement,
    'image' : PixelImage,
  });
  const Zone = IDL.Record({
    'id' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
    'unlockRequirement' : UnlockRequirement,
  });
  const Achievement = IDL.Record({
    'id' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
  });
  const ScenarioCategory = IDL.Variant({
    'other' : IDL.Null,
    'store' : IDL.Null,
    'combat' : IDL.Null,
  });
  const RewardPathKind = IDL.Variant({
    'random' : IDL.Null,
    'specificItemIds' : IDL.Vec(IDL.Text),
  });
  const WeightKind = IDL.Variant({
    'raw' : IDL.Null,
    'attributeScaled' : Attribute,
  });
  const OptionWeight = IDL.Record({
    'value' : IDL.Float64,
    'kind' : WeightKind,
  });
  const NatValue = IDL.Variant({
    'raw' : IDL.Nat,
    'random' : IDL.Tuple(IDL.Nat, IDL.Nat),
  });
  const PathEffect = IDL.Variant({
    'damage' : NatValue,
    'heal' : NatValue,
    'removeItemWithTags' : IDL.Vec(IDL.Text),
    'achievement' : IDL.Text,
    'addItem' : IDL.Text,
    'addItemWithTags' : IDL.Vec(IDL.Text),
    'removeGold' : NatValue,
    'removeItem' : IDL.Text,
  });
  const WeightedScenarioPathOption = IDL.Record({
    'weight' : OptionWeight,
    'effects' : IDL.Vec(PathEffect),
    'description' : IDL.Text,
    'pathId' : IDL.Opt(IDL.Text),
  });
  const NextPathKind = IDL.Variant({
    'multi' : IDL.Vec(WeightedScenarioPathOption),
    'none' : IDL.Null,
    'single' : IDL.Text,
  });
  const RewardPath = IDL.Record({
    'kind' : RewardPathKind,
    'nextPath' : NextPathKind,
  });
  const AttributeChoiceRequirement = IDL.Record({
    'value' : IDL.Int,
    'attribute' : Attribute,
  });
  const ChoiceRequirement = IDL.Variant({
    'itemWithTags' : IDL.Vec(IDL.Text),
    'gold' : IDL.Nat,
    'attribute' : AttributeChoiceRequirement,
  });
  const Choice = IDL.Record({
    'id' : IDL.Text,
    'effects' : IDL.Vec(PathEffect),
    'description' : IDL.Text,
    'requirement' : IDL.Opt(ChoiceRequirement),
    'nextPath' : NextPathKind,
  });
  const ChoicePath = IDL.Record({ 'choices' : IDL.Vec(Choice) });
  const CombatCreatureLocationFilter = IDL.Variant({
    'any' : IDL.Null,
    'zone' : IDL.Text,
    'common' : IDL.Null,
  });
  const CombatCreatureFilter = IDL.Record({
    'location' : CombatCreatureLocationFilter,
  });
  const CombatCreatureKind = IDL.Variant({
    'id' : IDL.Text,
    'filter' : CombatCreatureFilter,
  });
  const CombatPath = IDL.Record({
    'creatures' : IDL.Vec(CombatCreatureKind),
    'nextPath' : NextPathKind,
  });
  const ScenarioPathKind = IDL.Variant({
    'reward' : RewardPath,
    'choice' : ChoicePath,
    'combat' : CombatPath,
  });
  const ScenarioPath = IDL.Record({
    'id' : IDL.Text,
    'kind' : ScenarioPathKind,
    'description' : IDL.Text,
  });
  const LocationKind = IDL.Variant({
    'common' : IDL.Null,
    'zoneIds' : IDL.Vec(IDL.Text),
  });
  const ScenarioMetaData = IDL.Record({
    'id' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
    'unlockRequirement' : UnlockRequirement,
    'category' : ScenarioCategory,
    'paths' : IDL.Vec(ScenarioPath),
    'image' : PixelImage,
    'location' : LocationKind,
  });
  const Weapon = IDL.Record({
    'id' : IDL.Text,
    'actionIds' : IDL.Vec(IDL.Text),
    'name' : IDL.Text,
    'description' : IDL.Text,
    'unlockRequirement' : UnlockRequirement,
    'image' : PixelImage,
  });
  const ModifyGameContent = IDL.Variant({
    'action' : Action,
    'creature' : Creature,
    'item' : Item,
    'class' : Class,
    'race' : Race,
    'zone' : Zone,
    'achievement' : Achievement,
    'scenario' : ScenarioMetaData,
    'weapon' : Weapon,
  });
  const CreateWorldProposalRequest = IDL.Variant({
    'motion' : MotionContent,
    'modifyGameContent' : ModifyGameContent,
  });
  const CreateWorldProposalError = IDL.Variant({
    'invalid' : IDL.Vec(IDL.Text),
    'notEligible' : IDL.Null,
  });
  const CreateWorldProposalResult = IDL.Variant({
    'ok' : IDL.Nat,
    'err' : CreateWorldProposalError,
  });
  const GetCompletedGamesRequest = IDL.Record({
    'count' : IDL.Nat,
    'offset' : IDL.Nat,
  });
  const Time = IDL.Int;
  const CharacterActionKind = IDL.Variant({
    'item' : IDL.Null,
    'skill' : IDL.Null,
    'weapon' : IDL.Null,
  });
  const CharacterActionWithMetaData = IDL.Record({
    'action' : Action,
    'kind' : CharacterActionKind,
  });
  const CharacterAttributes = IDL.Record({
    'dexterity' : IDL.Int,
    'wisdom' : IDL.Int,
    'strength' : IDL.Int,
    'charisma' : IDL.Int,
  });
  const InventorySlotWithMetaData = IDL.Record({ 'item' : IDL.Opt(Item) });
  const CharacterWithMetaData = IDL.Record({
    'maxHealth' : IDL.Nat,
    'gold' : IDL.Nat,
    'class' : Class,
    'race' : Race,
    'actions' : IDL.Vec(CharacterActionWithMetaData),
    'attributes' : CharacterAttributes,
    'inventorySlots' : IDL.Vec(InventorySlotWithMetaData),
    'weapon' : Weapon,
    'health' : IDL.Nat,
  });
  const VictoryGameOutcomeWithMetaData = IDL.Record({
    'character' : CharacterWithMetaData,
    'unlockedAchievementIds' : IDL.Vec(IDL.Text),
  });
  const DeathGameOutcomeWithMetaData = IDL.Record({
    'character' : CharacterWithMetaData,
  });
  const ForfeitGameOutcomeWithMetaData = IDL.Record({
    'character' : IDL.Opt(CharacterWithMetaData),
  });
  const CompletedGameOutcomeWithMetaData = IDL.Variant({
    'victory' : VictoryGameOutcomeWithMetaData,
    'death' : DeathGameOutcomeWithMetaData,
    'forfeit' : ForfeitGameOutcomeWithMetaData,
  });
  const CompletedGameWithMetaData = IDL.Record({
    'id' : IDL.Nat,
    'startTime' : Time,
    'endTime' : Time,
    'playerId' : IDL.Principal,
    'outcome' : CompletedGameOutcomeWithMetaData,
  });
  const PagedResult_2 = IDL.Record({
    'data' : IDL.Vec(CompletedGameWithMetaData),
    'count' : IDL.Nat,
    'totalCount' : IDL.Nat,
    'offset' : IDL.Nat,
  });
  const StartingGameStateWithMetaData = IDL.Record({
    'characterOptions' : IDL.Vec(CharacterWithMetaData),
  });
  const CompletedGameStateWithMetaData = IDL.Record({
    'endTime' : Time,
    'outcome' : CompletedGameOutcomeWithMetaData,
  });
  const ScenarioTurn = IDL.Record({ 'scenarioId' : IDL.Nat });
  const CombatTurn = IDL.Record({});
  const TurnKind = IDL.Variant({
    'scenario' : ScenarioTurn,
    'combat' : CombatTurn,
  });
  const InProgressGameStateWithMetaData = IDL.Record({
    'turnKind' : TurnKind,
    'character' : CharacterWithMetaData,
  });
  const GameStateWithMetaData = IDL.Variant({
    'starting' : StartingGameStateWithMetaData,
    'completed' : CompletedGameStateWithMetaData,
    'inProgress' : InProgressGameStateWithMetaData,
  });
  const GameWithMetaData = IDL.Record({
    'id' : IDL.Nat,
    'startTime' : Time,
    'playerId' : IDL.Principal,
    'state' : GameStateWithMetaData,
  });
  const GetCurrentGameResult = IDL.Variant({
    'ok' : IDL.Opt(GameWithMetaData),
    'err' : IDL.Variant({ 'notAuthenticated' : IDL.Null }),
  });
  const GetScenarioRequest = IDL.Record({ 'scenarioId' : IDL.Nat });
  const RewardKind = IDL.Variant({
    'gold' : IDL.Nat,
    'item' : IDL.Text,
    'weapon' : IDL.Text,
    'health' : IDL.Nat,
  });
  const RewardScenarioState = IDL.Record({
    'options' : IDL.Vec(RewardKind),
    'nextPath' : NextPathKind,
  });
  const ChoiceScenarioState = IDL.Record({ 'choices' : IDL.Vec(Choice) });
  const PeriodicEffectKind = IDL.Variant({
    'damage' : IDL.Null,
    'heal' : IDL.Null,
    'block' : IDL.Null,
  });
  const PeriodicEffectResult = IDL.Record({
    'kind' : PeriodicEffectKind,
    'phase' : TurnPhase,
    'amount' : IDL.Nat,
  });
  const StatusEffectResultKind = IDL.Variant({
    'retaliating' : Retaliating,
    'brittle' : IDL.Null,
    'weak' : IDL.Null,
    'vulnerable' : IDL.Null,
    'necrotic' : IDL.Null,
    'stunned' : IDL.Null,
    'periodic' : PeriodicEffectResult,
  });
  const StatusEffectResult = IDL.Record({
    'kind' : StatusEffectResultKind,
    'remainingTurns' : IDL.Nat,
  });
  const CharacterCombatState = IDL.Record({
    'weaponActionId' : IDL.Opt(IDL.Text),
    'statusEffects' : IDL.Vec(StatusEffectResult),
    'maxHealth' : IDL.Nat,
    'skillActionId' : IDL.Opt(IDL.Text),
    'block' : IDL.Nat,
    'itemActionId' : IDL.Opt(IDL.Text),
    'health' : IDL.Nat,
  });
  const CreatureCombatState = IDL.Record({
    'actionIds' : IDL.Vec(IDL.Text),
    'statusEffects' : IDL.Vec(StatusEffectResult),
    'maxHealth' : IDL.Nat,
    'creatureId' : IDL.Text,
    'block' : IDL.Nat,
    'health' : IDL.Nat,
  });
  const CombatScenarioState = IDL.Record({
    'character' : CharacterCombatState,
    'creatures' : IDL.Vec(CreatureCombatState),
    'nextPath' : NextPathKind,
  });
  const InProgressScenarioStateKind = IDL.Variant({
    'reward' : RewardScenarioState,
    'choice' : ChoiceScenarioState,
    'combat' : CombatScenarioState,
  });
  const ScenarioStateKind = IDL.Variant({
    'completed' : IDL.Null,
    'inProgress' : InProgressScenarioStateKind,
  });
  const SwapWeaponOutcomeEffect = IDL.Record({
    'removedWeaponId' : IDL.Text,
    'weaponId' : IDL.Text,
  });
  const AddItemOutcomeEffect = IDL.Record({
    'itemId' : IDL.Text,
    'removedItemId' : IDL.Opt(IDL.Text),
  });
  const OutcomeEffect = IDL.Variant({
    'healthDelta' : IDL.Int,
    'maxHealthDelta' : IDL.Int,
    'text' : IDL.Text,
    'swapWeapon' : SwapWeaponOutcomeEffect,
    'addItem' : AddItemOutcomeEffect,
    'goldDelta' : IDL.Int,
    'removeItem' : IDL.Text,
  });
  const ScenarioRewardResult = IDL.Record({ 'kind' : RewardKind });
  const ChoiceResultKind = IDL.Variant({
    'complete' : IDL.Null,
    'death' : IDL.Null,
  });
  const ScenarioChoiceResult = IDL.Record({
    'kind' : ChoiceResultKind,
    'choice' : Choice,
  });
  const TargetKind = IDL.Variant({
    'creature' : IDL.Nat,
    'character' : IDL.Null,
    'periodicEffect' : IDL.Null,
  });
  const DamageLogEntry = IDL.Record({
    'source' : TargetKind,
    'target' : TargetKind,
    'amount' : IDL.Nat,
  });
  const HealLogEntry = IDL.Record({
    'source' : TargetKind,
    'target' : TargetKind,
    'amount' : IDL.Nat,
  });
  const BlockLogEntry = IDL.Record({
    'source' : TargetKind,
    'target' : TargetKind,
    'amount' : IDL.Nat,
  });
  const StatusEffectLogEntry = IDL.Record({
    'source' : TargetKind,
    'target' : TargetKind,
    'statusEffect' : StatusEffectResult,
  });
  const CombatLogEntry = IDL.Variant({
    'damage' : DamageLogEntry,
    'heal' : HealLogEntry,
    'block' : BlockLogEntry,
    'statusEffect' : StatusEffectLogEntry,
  });
  const CombatDefeatResult = IDL.Record({
    'creatures' : IDL.Vec(CreatureCombatState),
  });
  const CombatVictoryResult = IDL.Record({ 'characterHealth' : IDL.Nat });
  const CombatResultKind = IDL.Variant({
    'defeat' : CombatDefeatResult,
    'victory' : CombatVictoryResult,
    'inProgress' : CombatScenarioState,
  });
  const ScenarioCombatResult = IDL.Record({
    'log' : IDL.Vec(CombatLogEntry),
    'kind' : CombatResultKind,
  });
  const ScenarioStageResultKind = IDL.Variant({
    'reward' : ScenarioRewardResult,
    'choice' : ScenarioChoiceResult,
    'combat' : ScenarioCombatResult,
  });
  const ScenarioStageResult = IDL.Record({
    'effects' : IDL.Vec(OutcomeEffect),
    'kind' : ScenarioStageResultKind,
  });
  const Scenario = IDL.Record({
    'id' : IDL.Nat,
    'metaDataId' : IDL.Text,
    'metaData' : ScenarioMetaData,
    'state' : ScenarioStateKind,
    'previousStages' : IDL.Vec(ScenarioStageResult),
  });
  const GetScenarioError = IDL.Variant({
    'notFound' : IDL.Null,
    'gameNotFound' : IDL.Null,
    'gameNotActive' : IDL.Null,
  });
  const GetScenarioResult = IDL.Variant({
    'ok' : Scenario,
    'err' : GetScenarioError,
  });
  const GetScenariosError = IDL.Variant({
    'gameNotFound' : IDL.Null,
    'gameNotActive' : IDL.Null,
  });
  const GetScenariosResult = IDL.Variant({
    'ok' : IDL.Vec(Scenario),
    'err' : GetScenariosError,
  });
  const GetTopUsersRequest = IDL.Record({
    'count' : IDL.Nat,
    'offset' : IDL.Nat,
  });
  const User = IDL.Record({
    'id' : IDL.Principal,
    'createTime' : Time,
    'achievementIds' : IDL.Vec(IDL.Text),
    'points' : IDL.Nat,
  });
  const PagedResult_1 = IDL.Record({
    'data' : IDL.Vec(User),
    'count' : IDL.Nat,
    'totalCount' : IDL.Nat,
    'offset' : IDL.Nat,
  });
  const GetTopUsersResult = IDL.Variant({ 'ok' : PagedResult_1 });
  const GetUserError = IDL.Variant({ 'notFound' : IDL.Null });
  const GetUserResult = IDL.Variant({ 'ok' : User, 'err' : GetUserError });
  const UserStats = IDL.Record({ 'userCount' : IDL.Nat });
  const GetUserStatsResult = IDL.Variant({
    'ok' : UserStats,
    'err' : IDL.Null,
  });
  const GetUsersRequest = IDL.Variant({ 'all' : IDL.Null });
  const GetUsersResult = IDL.Variant({ 'ok' : IDL.Vec(User) });
  const ProposalStatus = IDL.Variant({
    'failedToExecute' : IDL.Record({
      'executingTime' : Time,
      'error' : IDL.Text,
      'failedTime' : Time,
      'choice' : IDL.Opt(IDL.Bool),
    }),
    'open' : IDL.Null,
    'executing' : IDL.Record({
      'executingTime' : Time,
      'choice' : IDL.Opt(IDL.Bool),
    }),
    'executed' : IDL.Record({
      'executingTime' : Time,
      'choice' : IDL.Opt(IDL.Bool),
      'executedTime' : Time,
    }),
  });
  const ProposalContent = IDL.Variant({
    'motion' : MotionContent,
    'modifyGameContent' : ModifyGameContent,
  });
  const Vote = IDL.Record({
    'votingPower' : IDL.Nat,
    'choice' : IDL.Opt(IDL.Bool),
  });
  const WorldProposal = IDL.Record({
    'id' : IDL.Nat,
    'status' : ProposalStatus,
    'content' : ProposalContent,
    'timeStart' : IDL.Int,
    'votes' : IDL.Vec(IDL.Tuple(IDL.Principal, Vote)),
    'timeEnd' : IDL.Opt(IDL.Int),
    'proposerId' : IDL.Principal,
  });
  const GetWorldProposalError = IDL.Variant({ 'proposalNotFound' : IDL.Null });
  const GetWorldProposalResult = IDL.Variant({
    'ok' : WorldProposal,
    'err' : GetWorldProposalError,
  });
  const PagedResult = IDL.Record({
    'data' : IDL.Vec(WorldProposal),
    'count' : IDL.Nat,
    'totalCount' : IDL.Nat,
    'offset' : IDL.Nat,
  });
  const RegisterError = IDL.Variant({ 'alreadyMember' : IDL.Null });
  const RegisterResult = IDL.Variant({ 'ok' : User, 'err' : RegisterError });
  const ItemRewardChoice = IDL.Record({
    'id' : IDL.Text,
    'inventorySlot' : IDL.Nat,
  });
  const RewardChoice = IDL.Variant({
    'gold' : IDL.Nat,
    'item' : ItemRewardChoice,
    'weapon' : IDL.Text,
    'health' : IDL.Nat,
  });
  const ActionTargetResult = IDL.Variant({
    'creature' : IDL.Nat,
    'character' : IDL.Null,
  });
  const CombatChoice = IDL.Record({
    'kind' : CharacterActionKind,
    'target' : IDL.Opt(ActionTargetResult),
  });
  const StageChoiceKind = IDL.Variant({
    'reward' : RewardChoice,
    'choice' : IDL.Text,
    'combat' : CombatChoice,
  });
  const SelectScenarioChoiceRequest = IDL.Record({
    'choice' : StageChoiceKind,
  });
  const SelectScenarioChoiceError = IDL.Variant({
    'invalidTarget' : IDL.Null,
    'targetRequired' : IDL.Null,
    'invalidChoice' : IDL.Text,
    'gameNotFound' : IDL.Null,
    'gameNotActive' : IDL.Null,
    'notScenarioTurn' : IDL.Null,
  });
  const SelectScenarioChoiceResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : SelectScenarioChoiceError,
  });
  const StartGameRequest = IDL.Record({ 'characterId' : IDL.Nat });
  const StartGameResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : IDL.Variant({
      'invalidCharacterId' : IDL.Null,
      'alreadyStarted' : IDL.Null,
      'gameNotFound' : IDL.Null,
    }),
  });
  const VoteOnWorldProposalRequest = IDL.Record({
    'vote' : IDL.Bool,
    'proposalId' : IDL.Nat,
  });
  const VoteOnWorldProposalError = IDL.Variant({
    'proposalNotFound' : IDL.Null,
    'alreadyVoted' : IDL.Null,
    'votingClosed' : IDL.Null,
    'notEligible' : IDL.Null,
  });
  const VoteOnWorldProposalResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : VoteOnWorldProposalError,
  });
  return IDL.Service({
    'abandonGame' : IDL.Func([], [AbandonGameResult], []),
    'createGame' : IDL.Func([CreateGameRequest], [CreateGameResult], []),
    'createWorldProposal' : IDL.Func(
        [CreateWorldProposalRequest],
        [CreateWorldProposalResult],
        [],
      ),
    'getAchievements' : IDL.Func([], [IDL.Vec(Achievement)], ['query']),
    'getActions' : IDL.Func([], [IDL.Vec(Action)], ['query']),
    'getClasses' : IDL.Func([], [IDL.Vec(Class)], ['query']),
    'getCompletedGames' : IDL.Func(
        [GetCompletedGamesRequest],
        [PagedResult_2],
        ['query'],
      ),
    'getCreatures' : IDL.Func([], [IDL.Vec(Creature)], ['query']),
    'getCurrentGame' : IDL.Func([], [GetCurrentGameResult], ['query']),
    'getItems' : IDL.Func([], [IDL.Vec(Item)], ['query']),
    'getRaces' : IDL.Func([], [IDL.Vec(Race)], ['query']),
    'getScenario' : IDL.Func(
        [GetScenarioRequest],
        [GetScenarioResult],
        ['query'],
      ),
    'getScenarioMetaDataList' : IDL.Func(
        [],
        [IDL.Vec(ScenarioMetaData)],
        ['query'],
      ),
    'getScenarios' : IDL.Func([], [GetScenariosResult], ['query']),
    'getTopUsers' : IDL.Func(
        [GetTopUsersRequest],
        [GetTopUsersResult],
        ['query'],
      ),
    'getUser' : IDL.Func([IDL.Principal], [GetUserResult], ['query']),
    'getUserStats' : IDL.Func([], [GetUserStatsResult], ['query']),
    'getUsers' : IDL.Func([GetUsersRequest], [GetUsersResult], ['query']),
    'getWeapons' : IDL.Func([], [IDL.Vec(Weapon)], ['query']),
    'getWorldProposal' : IDL.Func(
        [IDL.Nat],
        [GetWorldProposalResult],
        ['query'],
      ),
    'getWorldProposals' : IDL.Func(
        [IDL.Nat, IDL.Nat],
        [PagedResult],
        ['query'],
      ),
    'getZones' : IDL.Func([], [IDL.Vec(Zone)], ['query']),
    'register' : IDL.Func([], [RegisterResult], []),
    'selectScenarioChoice' : IDL.Func(
        [SelectScenarioChoiceRequest],
        [SelectScenarioChoiceResult],
        [],
      ),
    'startGame' : IDL.Func([StartGameRequest], [StartGameResult], []),
    'voteOnWorldProposal' : IDL.Func(
        [VoteOnWorldProposalRequest],
        [VoteOnWorldProposalResult],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
