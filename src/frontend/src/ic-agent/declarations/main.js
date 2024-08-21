export const idlFactory = ({ IDL }) => {
  const ChoiceRequirement = IDL.Rec();
  const Trait = IDL.Record({
    'id' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
  });
  const Item = IDL.Record({
    'id' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
  });
  const CharacterModifier = IDL.Variant({
    'magic' : IDL.Int,
    'trait' : IDL.Text,
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
    'modifiers' : IDL.Vec(CharacterModifier),
  });
  const Race = IDL.Record({
    'id' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
    'modifiers' : IDL.Vec(CharacterModifier),
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
    'speed' : IDL.Null,
    'defense' : IDL.Null,
    'attack' : IDL.Null,
  });
  const Effect = IDL.Variant({
    'reward' : IDL.Null,
    'removeTrait' : RandomOrSpecificTextValue,
    'damage' : NatValue,
    'heal' : NatValue,
    'upgradeStat' : IDL.Tuple(CharacterStatKind, NatValue),
    'addItem' : TextValue,
    'addTrait' : TextValue,
    'removeGold' : NatValue,
    'removeItem' : RandomOrSpecificTextValue,
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
    'effects' : IDL.Vec(Effect),
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
  const ScenarioMetaData = IDL.Record({
    'id' : IDL.Text,
    'title' : IDL.Text,
    'data' : IDL.Vec(GeneratedDataField),
    'description' : IDL.Text,
    'paths' : IDL.Vec(OutcomePath),
    'imageId' : IDL.Text,
    'choices' : IDL.Vec(Choice),
    'undecidedPathId' : IDL.Text,
  });
  const AddGameContentRequest = IDL.Variant({
    'trait' : Trait,
    'item' : Item,
    'class' : Class,
    'race' : Race,
    'image' : Image,
    'scenario' : ScenarioMetaData,
  });
  const AddGameContentResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : IDL.Variant({
      'notAuthorized' : IDL.Null,
      'invalid' : IDL.Vec(IDL.Text),
    }),
  });
  const MotionContent = IDL.Record({
    'title' : IDL.Text,
    'description' : IDL.Text,
  });
  const CreateWorldProposalRequest = IDL.Variant({ 'motion' : MotionContent });
  const CreateWorldProposalError = IDL.Variant({
    'invalid' : IDL.Vec(IDL.Text),
    'notEligible' : IDL.Null,
  });
  const CreateWorldProposalResult = IDL.Variant({
    'ok' : IDL.Nat,
    'err' : CreateWorldProposalError,
  });
  const ChoiceVotingPower_1 = IDL.Record({
    'votingPower' : IDL.Nat,
    'choice' : IDL.Nat,
  });
  const VotingSummary = IDL.Record({
    'votingPowerByChoice' : IDL.Vec(ChoiceVotingPower_1),
    'undecidedVotingPower' : IDL.Nat,
    'totalVotingPower' : IDL.Nat,
  });
  const CharacterStats = IDL.Record({
    'magic' : IDL.Int,
    'speed' : IDL.Int,
    'defense' : IDL.Int,
    'attack' : IDL.Int,
  });
  const CharacterWithMetaData = IDL.Record({
    'gold' : IDL.Nat,
    'traits' : IDL.Vec(Trait),
    'class' : Class,
    'race' : Race,
    'stats' : CharacterStats,
    'items' : IDL.Vec(Item),
    'health' : IDL.Nat,
  });
  const Difficulty = IDL.Variant({
    'easy' : IDL.Null,
    'hard' : IDL.Null,
    'medium' : IDL.Null,
  });
  const ChoiceVotingPower_2 = IDL.Record({
    'votingPower' : IDL.Nat,
    'choice' : Difficulty,
  });
  const VotingSummary_1 = IDL.Record({
    'votingPowerByChoice' : IDL.Vec(ChoiceVotingPower_2),
    'undecidedVotingPower' : IDL.Nat,
    'totalVotingPower' : IDL.Nat,
  });
  const AxialCoordinate = IDL.Record({ 'q' : IDL.Int, 'r' : IDL.Int });
  const Location = IDL.Record({
    'id' : IDL.Nat,
    'scenarioId' : IDL.Nat,
    'coordinate' : AxialCoordinate,
  });
  const GameInstanceWithMetaData = IDL.Variant({
    'notStarted' : IDL.Record({
      'characterVotes' : VotingSummary,
      'characterOptions' : IDL.Vec(CharacterWithMetaData),
      'difficultyVotes' : VotingSummary_1,
    }),
    'completed' : IDL.Record({
      'turns' : IDL.Nat,
      'character' : CharacterWithMetaData,
      'difficulty' : Difficulty,
    }),
    'notInitialized' : IDL.Null,
    'inProgress' : IDL.Record({
      'character' : CharacterWithMetaData,
      'turn' : IDL.Nat,
      'locations' : IDL.Vec(Location),
      'characterLocationId' : IDL.Nat,
    }),
  });
  const ChoiceVotingPower = IDL.Record({
    'votingPower' : IDL.Nat,
    'choice' : IDL.Text,
  });
  const ScenarioVoteChoice = IDL.Record({
    'votingPower' : IDL.Nat,
    'choice' : IDL.Opt(IDL.Text),
  });
  const ScenarioVote = IDL.Record({
    'votingPowerByChoice' : IDL.Vec(ChoiceVotingPower),
    'undecidedVotingPower' : IDL.Nat,
    'totalVotingPower' : IDL.Nat,
    'yourVote' : IDL.Opt(ScenarioVoteChoice),
  });
  const GeneratedDataFieldInstanceValue = IDL.Variant({
    'nat' : IDL.Nat,
    'text' : IDL.Text,
  });
  const GeneratedDataFieldInstance = IDL.Record({
    'id' : IDL.Text,
    'value' : GeneratedDataFieldInstanceValue,
  });
  const Outcome = IDL.Record({
    'messages' : IDL.Vec(IDL.Text),
    'choiceOrUndecided' : IDL.Opt(IDL.Text),
  });
  const Scenario = IDL.Record({
    'id' : IDL.Nat,
    'voteData' : ScenarioVote,
    'metaDataId' : IDL.Text,
    'metaData' : ScenarioMetaData,
    'data' : IDL.Vec(GeneratedDataFieldInstance),
    'availableChoiceIds' : IDL.Vec(IDL.Text),
    'outcome' : IDL.Opt(Outcome),
  });
  const GetScenarioError = IDL.Variant({
    'noActiveGame' : IDL.Null,
    'notFound' : IDL.Null,
  });
  const GetScenarioResult = IDL.Variant({
    'ok' : Scenario,
    'err' : GetScenarioError,
  });
  const GetScenarioVoteRequest = IDL.Record({ 'scenarioId' : IDL.Nat });
  const GetScenarioVoteError = IDL.Variant({
    'noActiveGame' : IDL.Null,
    'scenarioNotFound' : IDL.Null,
  });
  const GetScenarioVoteResult = IDL.Variant({
    'ok' : ScenarioVote,
    'err' : GetScenarioVoteError,
  });
  const GetScenariosError = IDL.Variant({ 'noActiveGame' : IDL.Null });
  const GetScenariosResult = IDL.Variant({
    'ok' : IDL.Vec(Scenario),
    'err' : GetScenariosError,
  });
  const GetTopUsersRequest = IDL.Record({
    'count' : IDL.Nat,
    'offset' : IDL.Nat,
  });
  const Time = IDL.Int;
  const User = IDL.Record({
    'id' : IDL.Principal,
    'inWorldSince' : Time,
    'level' : IDL.Nat,
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
  const UserStats = IDL.Record({
    'totalUserLevel' : IDL.Int,
    'userCount' : IDL.Nat,
  });
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
  const ProposalContent = IDL.Variant({ 'motion' : MotionContent });
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
  const InitializeResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : IDL.Variant({
      'noTraits' : IDL.Null,
      'noItems' : IDL.Null,
      'noClasses' : IDL.Null,
      'noRaces' : IDL.Null,
      'noScenarios' : IDL.Null,
      'noImages' : IDL.Null,
      'alreadyInitialized' : IDL.Null,
    }),
  });
  const JoinError = IDL.Variant({ 'alreadyMember' : IDL.Null });
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : JoinError });
  const VoteOnNewGameRequest = IDL.Record({
    'difficulty' : Difficulty,
    'characterId' : IDL.Nat,
  });
  const VoteOnNewGameError = IDL.Variant({
    'noActiveGame' : IDL.Null,
    'invalidCharacterId' : IDL.Null,
    'alreadyVoted' : IDL.Null,
    'votingClosed' : IDL.Null,
    'alreadyStarted' : IDL.Null,
    'notEligible' : IDL.Null,
  });
  const VoteOnNewGameResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : VoteOnNewGameError,
  });
  const VoteOnScenarioRequest = IDL.Record({
    'scenarioId' : IDL.Nat,
    'value' : IDL.Text,
  });
  const VoteOnScenarioError = IDL.Variant({
    'noActiveGame' : IDL.Null,
    'alreadyVoted' : IDL.Null,
    'votingClosed' : IDL.Null,
    'invalidChoice' : IDL.Null,
    'notEligible' : IDL.Null,
    'scenarioNotFound' : IDL.Null,
    'choiceRequirementNotMet' : IDL.Null,
  });
  const VoteOnScenarioResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : VoteOnScenarioError,
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
    'addGameContent' : IDL.Func(
        [AddGameContentRequest],
        [AddGameContentResult],
        [],
      ),
    'createWorldProposal' : IDL.Func(
        [CreateWorldProposalRequest],
        [CreateWorldProposalResult],
        [],
      ),
    'getClasses' : IDL.Func([], [IDL.Vec(Class)], ['query']),
    'getGameInstance' : IDL.Func([], [GameInstanceWithMetaData], ['query']),
    'getItems' : IDL.Func([], [IDL.Vec(Item)], ['query']),
    'getRaces' : IDL.Func([], [IDL.Vec(Race)], ['query']),
    'getScenario' : IDL.Func([IDL.Nat], [GetScenarioResult], ['query']),
    'getScenarioMetaDataList' : IDL.Func(
        [],
        [IDL.Vec(ScenarioMetaData)],
        ['query'],
      ),
    'getScenarioVote' : IDL.Func(
        [GetScenarioVoteRequest],
        [GetScenarioVoteResult],
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
    'initialize' : IDL.Func([], [InitializeResult], []),
    'join' : IDL.Func([], [Result], []),
    'voteOnNewGame' : IDL.Func(
        [VoteOnNewGameRequest],
        [VoteOnNewGameResult],
        [],
      ),
    'voteOnScenario' : IDL.Func(
        [VoteOnScenarioRequest],
        [VoteOnScenarioResult],
        [],
      ),
    'voteOnWorldProposal' : IDL.Func(
        [VoteOnWorldProposalRequest],
        [VoteOnWorldProposalResult],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
