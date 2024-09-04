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
    'noTraits' : IDL.Null,
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
  const UnlockRequirement = IDL.Variant({ 'acheivementId' : IDL.Text });
  const PixelData = IDL.Record({
    'count' : IDL.Nat,
    'paletteIndex' : IDL.Opt(IDL.Nat8),
  });
  const PixelImage = IDL.Record({
    'palette' : IDL.Vec(IDL.Tuple(IDL.Nat8, IDL.Nat8, IDL.Nat8)),
    'pixelData' : IDL.Vec(PixelData),
  });
  const Trait = IDL.Record({
    'id' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
    'unlockRequirement' : IDL.Opt(UnlockRequirement),
    'image' : PixelImage,
  });
  const CreatureKind = IDL.Variant({
    'normal' : IDL.Null,
    'boss' : IDL.Null,
    'elite' : IDL.Null,
  });
  const CreatureLocationKind = IDL.Variant({
    'common' : IDL.Null,
    'zoneIds' : IDL.Vec(IDL.Text),
  });
  const Creature = IDL.Record({
    'id' : IDL.Text,
    'magic' : IDL.Int,
    'maxHealth' : IDL.Nat,
    'kind' : CreatureKind,
    'name' : IDL.Text,
    'description' : IDL.Text,
    'speed' : IDL.Int,
    'weaponId' : IDL.Text,
    'defense' : IDL.Int,
    'unlockRequirement' : IDL.Opt(UnlockRequirement),
    'attack' : IDL.Int,
    'location' : CreatureLocationKind,
    'health' : IDL.Nat,
  });
  const Item = IDL.Record({
    'id' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
    'unlockRequirement' : IDL.Opt(UnlockRequirement),
    'image' : PixelImage,
  });
  const CharacterModifier = IDL.Variant({
    'magic' : IDL.Int,
    'trait' : IDL.Text,
    'maxHealth' : IDL.Int,
    'gold' : IDL.Nat,
    'item' : IDL.Text,
    'speed' : IDL.Int,
    'defense' : IDL.Int,
    'attack' : IDL.Int,
    'health' : IDL.Int,
  });
  const Class = IDL.Record({
    'id' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
    'weaponId' : IDL.Text,
    'unlockRequirement' : IDL.Opt(UnlockRequirement),
    'modifiers' : IDL.Vec(CharacterModifier),
  });
  const Race = IDL.Record({
    'id' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
    'unlockRequirement' : IDL.Opt(UnlockRequirement),
    'modifiers' : IDL.Vec(CharacterModifier),
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
  const ScenarioCategory = IDL.Variant({
    'other' : IDL.Null,
    'store' : IDL.Null,
    'combat' : IDL.Null,
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
  const NatValue = IDL.Variant({
    'raw' : IDL.Nat,
    'dataField' : IDL.Text,
    'random' : IDL.Tuple(IDL.Nat, IDL.Nat),
  });
  const CharacterStatKind = IDL.Variant({
    'magic' : IDL.Null,
    'maxHealth' : IDL.Null,
    'speed' : IDL.Null,
    'defense' : IDL.Null,
    'attack' : IDL.Null,
  });
  const Effect = IDL.Variant({
    'reward' : IDL.Null,
    'removeTrait' : RandomOrSpecificTextValue,
    'damage' : NatValue,
    'heal' : NatValue,
    'achievement' : IDL.Text,
    'upgradeStat' : IDL.Tuple(CharacterStatKind, NatValue),
    'addItem' : TextValue,
    'addTrait' : TextValue,
    'removeGold' : NatValue,
    'removeItem' : RandomOrSpecificTextValue,
  });
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
  const CombatPath = IDL.Record({ 'creature' : CombatCreatureKind });
  const OutcomePathKind = IDL.Variant({
    'effects' : IDL.Vec(Effect),
    'combat' : CombatPath,
  });
  const Condition = IDL.Variant({
    'hasGold' : NatValue,
    'hasItem' : TextValue,
    'hasTrait' : TextValue,
  });
  const WeightedOutcomePath = IDL.Record({
    'weight' : IDL.Float64,
    'pathId' : IDL.Text,
    'condition' : IDL.Opt(Condition),
  });
  const OutcomePath = IDL.Record({
    'id' : IDL.Text,
    'kind' : OutcomePathKind,
    'description' : IDL.Text,
    'paths' : IDL.Vec(WeightedOutcomePath),
  });
  ChoiceRequirement.fill(
    IDL.Variant({
      'all' : IDL.Vec(ChoiceRequirement),
      'any' : IDL.Vec(ChoiceRequirement),
      'trait' : IDL.Text,
      'gold' : IDL.Nat,
      'item' : IDL.Text,
      'class' : IDL.Text,
      'race' : IDL.Text,
      'stat' : IDL.Tuple(CharacterStatKind, IDL.Nat),
    })
  );
  const Choice = IDL.Record({
    'id' : IDL.Text,
    'description' : IDL.Text,
    'requirement' : IDL.Opt(ChoiceRequirement),
    'pathId' : IDL.Text,
  });
  const LocationKind = IDL.Variant({
    'common' : IDL.Null,
    'zoneIds' : IDL.Vec(IDL.Text),
  });
  const ScenarioMetaData = IDL.Record({
    'id' : IDL.Text,
    'data' : IDL.Vec(GeneratedDataField),
    'name' : IDL.Text,
    'description' : IDL.Text,
    'unlockRequirement' : IDL.Opt(UnlockRequirement),
    'category' : ScenarioCategory,
    'paths' : IDL.Vec(OutcomePath),
    'imageId' : IDL.Text,
    'choices' : IDL.Vec(Choice),
    'location' : LocationKind,
  });
  const CharacterStatKind__1 = IDL.Variant({
    'magic' : IDL.Null,
    'gold' : IDL.Null,
    'speed' : IDL.Null,
    'defense' : IDL.Null,
    'attack' : IDL.Null,
    'health' : IDL.Record({ 'inverse' : IDL.Bool }),
  });
  const WeaponAttribute = IDL.Variant({
    'damage' : IDL.Null,
    'attacks' : IDL.Null,
    'criticalChance' : IDL.Null,
    'maxDamage' : IDL.Null,
    'minDamage' : IDL.Null,
    'criticalMultiplier' : IDL.Null,
    'accuracy' : IDL.Null,
  });
  const StatModifier = IDL.Record({
    'characterStat' : CharacterStatKind__1,
    'factor' : IDL.Float64,
    'attribute' : WeaponAttribute,
  });
  const WeaponStats = IDL.Record({
    'attacks' : IDL.Nat,
    'criticalChance' : IDL.Nat,
    'maxDamage' : IDL.Nat,
    'minDamage' : IDL.Nat,
    'statModifiers' : IDL.Vec(StatModifier),
    'criticalMultiplier' : IDL.Nat,
    'accuracy' : IDL.Int,
  });
  const WeaponRequirement = IDL.Variant({
    'magic' : IDL.Int,
    'maxHealth' : IDL.Nat,
    'speed' : IDL.Int,
    'defense' : IDL.Int,
    'attack' : IDL.Int,
  });
  const Weapon = IDL.Record({
    'id' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
    'baseStats' : WeaponStats,
    'unlockRequirement' : IDL.Opt(UnlockRequirement),
    'requirements' : IDL.Vec(WeaponRequirement),
  });
  const ModifyGameContent = IDL.Variant({
    'trait' : Trait,
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
  const CharacterWithMetaData = IDL.Record({
    'magic' : IDL.Int,
    'maxHealth' : IDL.Nat,
    'gold' : IDL.Nat,
    'traits' : IDL.Vec(Trait),
    'class' : Class,
    'race' : Race,
    'speed' : IDL.Int,
    'defense' : IDL.Int,
    'items' : IDL.Vec(Item),
    'attack' : IDL.Int,
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
  const CombatTurn__1 = IDL.Record({});
  const TurnKind = IDL.Variant({
    'scenario' : ScenarioTurn,
    'combat' : CombatTurn__1,
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
  const GeneratedDataFieldInstanceValue = IDL.Variant({
    'nat' : IDL.Nat,
    'text' : IDL.Text,
  });
  const GeneratedDataFieldInstance = IDL.Record({
    'id' : IDL.Text,
    'value' : GeneratedDataFieldInstanceValue,
  });
  const AttackerKind = IDL.Variant({
    'creature' : IDL.Null,
    'character' : IDL.Null,
  });
  const HitResult = IDL.Record({ 'damage' : IDL.Nat });
  const AttackResult = IDL.Variant({ 'hit' : HitResult, 'miss' : IDL.Null });
  const CombatTurn = IDL.Record({
    'attacker' : AttackerKind,
    'attacks' : IDL.Vec(AttackResult),
  });
  const CombatResultKind = IDL.Variant({
    'maxTurnsReached' : IDL.Null,
    'defeat' : IDL.Null,
    'victory' : IDL.Null,
  });
  const CombatResult = IDL.Record({
    'turns' : IDL.Vec(CombatTurn),
    'healthDelta' : IDL.Int,
    'kind' : CombatResultKind,
  });
  const OutcomeLogEntry = IDL.Variant({
    'speedDelta' : IDL.Int,
    'removeTrait' : IDL.Text,
    'healthDelta' : IDL.Int,
    'maxHealthDelta' : IDL.Int,
    'text' : IDL.Text,
    'defenseDelta' : IDL.Int,
    'attackDelta' : IDL.Int,
    'addItem' : IDL.Text,
    'addTrait' : IDL.Text,
    'goldDelta' : IDL.Int,
    'removeItem' : IDL.Text,
    'combat' : CombatResult,
    'magicDelta' : IDL.Int,
  });
  const Outcome = IDL.Record({
    'log' : IDL.Vec(OutcomeLogEntry),
    'choiceId' : IDL.Text,
  });
  const Scenario = IDL.Record({
    'id' : IDL.Nat,
    'metaDataId' : IDL.Text,
    'metaData' : ScenarioMetaData,
    'data' : IDL.Vec(GeneratedDataFieldInstance),
    'availableChoiceIds' : IDL.Vec(IDL.Text),
    'outcome' : IDL.Opt(Outcome),
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
  const SelectScenarioChoiceRequest = IDL.Record({ 'choiceId' : IDL.Text });
  const SelectScenarioChoiceError = IDL.Variant({
    'invalidChoice' : IDL.Null,
    'gameNotFound' : IDL.Null,
    'gameNotActive' : IDL.Null,
    'choiceRequirementNotMet' : IDL.Null,
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
    'getClasses' : IDL.Func([], [IDL.Vec(Class)], ['query']),
    'getCompletedGames' : IDL.Func(
        [GetCompletedGamesRequest],
        [PagedResult_2],
        ['query'],
      ),
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
    'getTraits' : IDL.Func([], [IDL.Vec(Trait)], ['query']),
    'getUser' : IDL.Func([IDL.Principal], [GetUserResult], ['query']),
    'getUserStats' : IDL.Func([], [GetUserStatsResult], ['query']),
    'getUsers' : IDL.Func([GetUsersRequest], [GetUsersResult], ['query']),
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
