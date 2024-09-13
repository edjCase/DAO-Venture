export const idlFactory = ({ IDL }) => {
  const ChoiceRequirement = IDL.Rec();
  const AbandonGameResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : IDL.Variant({ 'noActiveGame' : IDL.Null }),
  });
  const Difficulty = IDL.Variant({
    'normal' : IDL.Null,
    'easy' : IDL.Null,
    'hard' : IDL.Null,
  });
  const CreateGameRequest = IDL.Record({ 'difficulty' : Difficulty });
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
    'noImages' : IDL.Null,
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
  const ActionEffectKind = IDL.Variant({
    'damage' : Damage,
    'heal' : Heal,
    'addStatusEffect' : StatusEffect,
    'block' : Block,
  });
  const ActionEffectTarget = IDL.Variant({
    'self' : IDL.Null,
    'targets' : IDL.Null,
  });
  const ActionEffect = IDL.Record({
    'kind' : ActionEffectKind,
    'target' : ActionEffectTarget,
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
  const Action = IDL.Record({
    'id' : IDL.Text,
    'effects' : IDL.Vec(ActionEffect),
    'name' : IDL.Text,
    'description' : IDL.Text,
    'target' : ActionTarget,
    'upgradedActionId' : IDL.Opt(IDL.Text),
  });
  const CreatureKind = IDL.Variant({
    'normal' : IDL.Null,
    'boss' : IDL.Null,
    'elite' : IDL.Null,
  });
  const UnlockRequirement = IDL.Variant({ 'acheivementId' : IDL.Text });
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
    'unlockRequirement' : IDL.Opt(UnlockRequirement),
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
    'description' : IDL.Text,
    'unlockRequirement' : IDL.Opt(UnlockRequirement),
    'image' : PixelImage,
  });
  const Class = IDL.Record({
    'id' : IDL.Text,
    'startingActionIds' : IDL.Vec(IDL.Text),
    'name' : IDL.Text,
    'description' : IDL.Text,
    'startingItemIds' : IDL.Vec(IDL.Text),
    'weaponId' : IDL.Text,
    'unlockRequirement' : IDL.Opt(UnlockRequirement),
  });
  const Race = IDL.Record({
    'id' : IDL.Text,
    'startingActionIds' : IDL.Vec(IDL.Text),
    'name' : IDL.Text,
    'description' : IDL.Text,
    'startingItemIds' : IDL.Vec(IDL.Text),
    'unlockRequirement' : IDL.Opt(UnlockRequirement),
  });
  const Zone = IDL.Record({
    'id' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
    'unlockRequirement' : IDL.Opt(UnlockRequirement),
  });
  const Achievement = IDL.Record({
    'id' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
  });
  const ImageKind = IDL.Variant({ 'png' : IDL.Null });
  const Image = IDL.Record({
    'id' : IDL.Text,
    'data' : IDL.Vec(IDL.Nat8),
    'kind' : ImageKind,
  });
  const ScenarioCategory = IDL.Variant({
    'other' : IDL.Null,
    'store' : IDL.Null,
    'combat' : IDL.Null,
  });
  const RewardPath = IDL.Variant({
    'random' : IDL.Null,
    'specificItemIds' : IDL.Vec(IDL.Text),
  });
  const NatValue = IDL.Variant({
    'raw' : IDL.Nat,
    'dataField' : IDL.Text,
    'random' : IDL.Tuple(IDL.Nat, IDL.Nat),
  });
  const TextValue = IDL.Variant({
    'raw' : IDL.Text,
    'dataField' : IDL.Text,
    'weighted' : IDL.Vec(IDL.Tuple(IDL.Text, IDL.Float64)),
  });
  const RandomOrSpecificTextValue = IDL.Variant({
    'specific' : TextValue,
    'random' : IDL.Null,
  });
  const Effect = IDL.Variant({
    'damage' : NatValue,
    'heal' : NatValue,
    'achievement' : IDL.Text,
    'addItem' : RandomOrSpecificTextValue,
    'removeGold' : NatValue,
    'removeItem' : RandomOrSpecificTextValue,
  });
  const GeneratedDataFieldNat = IDL.Record({
    'max' : IDL.Nat,
    'min' : IDL.Nat,
  });
  const GeneratedDataFieldText = IDL.Record({
    'options' : IDL.Vec(IDL.Tuple(IDL.Text, IDL.Float64)),
  });
  const GeneratedDataFieldValue = IDL.Variant({
    'nat' : GeneratedDataFieldNat,
    'text' : GeneratedDataFieldText,
  });
  const GeneratedDataField = IDL.Record({
    'id' : IDL.Text,
    'value' : GeneratedDataFieldValue,
    'name' : IDL.Text,
  });
  ChoiceRequirement.fill(
    IDL.Variant({
      'all' : IDL.Vec(ChoiceRequirement),
      'any' : IDL.Vec(ChoiceRequirement),
      'gold' : IDL.Nat,
      'item' : IDL.Text,
      'class' : IDL.Text,
      'race' : IDL.Text,
    })
  );
  const Choice = IDL.Record({
    'id' : IDL.Text,
    'effects' : IDL.Vec(Effect),
    'data' : IDL.Vec(GeneratedDataField),
    'description' : IDL.Text,
    'requirement' : IDL.Opt(ChoiceRequirement),
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
  const CombatPath = IDL.Record({ 'creatures' : IDL.Vec(CombatCreatureKind) });
  const ScenarioPathKind = IDL.Variant({
    'reward' : RewardPath,
    'choice' : ChoicePath,
    'combat' : CombatPath,
  });
  const Condition = IDL.Variant({ 'hasGold' : IDL.Nat, 'hasItem' : IDL.Text });
  const WeightedScenarioPathOption = IDL.Record({
    'weight' : IDL.Float64,
    'pathId' : IDL.Text,
    'condition' : IDL.Opt(Condition),
  });
  const ScenarioPath = IDL.Record({
    'id' : IDL.Text,
    'kind' : ScenarioPathKind,
    'description' : IDL.Text,
    'nextPathOptions' : IDL.Vec(WeightedScenarioPathOption),
  });
  const LocationKind = IDL.Variant({
    'common' : IDL.Null,
    'zoneIds' : IDL.Vec(IDL.Text),
  });
  const ScenarioMetaData = IDL.Record({
    'id' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
    'unlockRequirement' : IDL.Opt(UnlockRequirement),
    'category' : ScenarioCategory,
    'paths' : IDL.Vec(ScenarioPath),
    'imageId' : IDL.Text,
    'location' : LocationKind,
  });
  const Weapon = IDL.Record({
    'id' : IDL.Text,
    'actionIds' : IDL.Vec(IDL.Text),
    'name' : IDL.Text,
    'description' : IDL.Text,
    'unlockRequirement' : IDL.Opt(UnlockRequirement),
  });
  const ModifyGameContent = IDL.Variant({
    'action' : Action,
    'creature' : Creature,
    'item' : Item,
    'class' : Class,
    'race' : Race,
    'zone' : Zone,
    'achievement' : Achievement,
    'image' : Image,
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
  const InventorySlotWithMetaData = IDL.Record({ 'item' : IDL.Opt(Item) });
  const CharacterWithMetaData = IDL.Record({
    'maxHealth' : IDL.Nat,
    'gold' : IDL.Nat,
    'class' : Class,
    'race' : Race,
    'actions' : IDL.Vec(Action),
    'inventorySlots' : IDL.Vec(InventorySlotWithMetaData),
    'weapon' : Weapon,
    'health' : IDL.Nat,
  });
  const CompletedGameWithMetaData = IDL.Record({
    'id' : IDL.Nat,
    'startTime' : Time,
    'endTime' : Time,
    'character' : CharacterWithMetaData,
    'difficulty' : Difficulty,
    'playerId' : IDL.Principal,
    'victory' : IDL.Bool,
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
    'character' : CharacterWithMetaData,
    'victory' : IDL.Bool,
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
    'difficulty' : Difficulty,
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
  const RewardScenarioState = IDL.Record({ 'options' : IDL.Vec(RewardKind) });
  const GeneratedDataFieldInstanceValue = IDL.Variant({
    'nat' : IDL.Nat,
    'text' : IDL.Text,
  });
  const GeneratedDataFieldInstance = IDL.Record({
    'id' : IDL.Text,
    'value' : GeneratedDataFieldInstanceValue,
  });
  const Choice__1 = IDL.Record({
    'id' : IDL.Text,
    'effects' : IDL.Vec(Effect),
    'data' : IDL.Vec(GeneratedDataFieldInstance),
    'description' : IDL.Text,
  });
  const ChoiceScenarioState = IDL.Record({ 'choices' : IDL.Vec(Choice__1) });
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
    'statusEffects' : IDL.Vec(StatusEffectResult),
    'maxHealth' : IDL.Nat,
    'availableActionIds' : IDL.Vec(IDL.Text),
    'block' : IDL.Nat,
    'health' : IDL.Nat,
  });
  const CreatureCombatState = IDL.Record({
    'statusEffects' : IDL.Vec(StatusEffectResult),
    'maxHealth' : IDL.Nat,
    'availableActionIds' : IDL.Vec(IDL.Text),
    'creatureId' : IDL.Text,
    'block' : IDL.Nat,
    'health' : IDL.Nat,
  });
  const CombatScenarioState = IDL.Record({
    'character' : CharacterCombatState,
    'creatures' : IDL.Vec(CreatureCombatState),
  });
  const InProgressScenarioStateKind = IDL.Variant({
    'reward' : RewardScenarioState,
    'choice' : ChoiceScenarioState,
    'combat' : CombatScenarioState,
  });
  const InProgressScenarioState = IDL.Record({
    'kind' : InProgressScenarioStateKind,
    'nextPathOptions' : IDL.Vec(WeightedScenarioPathOption),
  });
  const ScenarioStateKind = IDL.Variant({
    'completed' : IDL.Null,
    'inProgress' : InProgressScenarioState,
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
    'choiceId' : IDL.Text,
    'kind' : ChoiceResultKind,
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
  const HeaderField = IDL.Tuple(IDL.Text, IDL.Text);
  const HttpRequest = IDL.Record({
    'url' : IDL.Text,
    'method' : IDL.Text,
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HeaderField),
  });
  const Token = IDL.Record({ 'arbitrary_data' : IDL.Text });
  const StreamingCallbackHttpResponse = IDL.Record({
    'token' : IDL.Opt(Token),
    'body' : IDL.Vec(IDL.Nat8),
  });
  const CallbackStrategy = IDL.Record({
    'token' : Token,
    'callback' : IDL.Func([Token], [StreamingCallbackHttpResponse], ['query']),
  });
  const StreamingStrategy = IDL.Variant({ 'Callback' : CallbackStrategy });
  const HttpResponse = IDL.Record({
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HeaderField),
    'upgrade' : IDL.Opt(IDL.Bool),
    'streaming_strategy' : IDL.Opt(StreamingStrategy),
    'status_code' : IDL.Nat16,
  });
  const HttpUpdateRequest = IDL.Record({
    'url' : IDL.Text,
    'method' : IDL.Text,
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HeaderField),
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
    'target' : IDL.Opt(ActionTargetResult),
    'actionId' : IDL.Text,
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
    'http_request' : IDL.Func([HttpRequest], [HttpResponse], ['query']),
    'http_request_update' : IDL.Func([HttpUpdateRequest], [HttpResponse], []),
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
