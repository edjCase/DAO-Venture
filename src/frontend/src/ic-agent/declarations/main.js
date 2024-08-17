export const idlFactory = ({ IDL }) => {
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
  const TraitState = IDL.Record({
    'name' : IDL.Text,
    'description' : IDL.Text,
  });
  const ClassState = IDL.Record({
    'name' : IDL.Text,
    'description' : IDL.Text,
  });
  const RaceState = IDL.Record({ 'name' : IDL.Text, 'description' : IDL.Text });
  const CharacterStats = IDL.Record({
    'magic' : IDL.Int,
    'speed' : IDL.Int,
    'defense' : IDL.Int,
    'attack' : IDL.Int,
  });
  const ItemState = IDL.Record({ 'name' : IDL.Text, 'description' : IDL.Text });
  const CharacterState = IDL.Record({
    'gold' : IDL.Nat,
    'traits' : IDL.Vec(TraitState),
    'class' : ClassState,
    'race' : RaceState,
    'stats' : CharacterStats,
    'items' : IDL.Vec(ItemState),
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
  const GameState = IDL.Variant({
    'notStarted' : IDL.Record({
      'characterVotes' : VotingSummary,
      'characterOptions' : IDL.Vec(CharacterState),
      'difficultyVotes' : VotingSummary_1,
    }),
    'completed' : IDL.Record({
      'turns' : IDL.Nat,
      'character' : CharacterState,
      'difficulty' : Difficulty,
    }),
    'notInitialized' : IDL.Null,
    'inProgress' : IDL.Record({
      'character' : CharacterState,
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
  const Data__6 = IDL.Record({ 'bribeCost' : IDL.Nat });
  const Data__12 = IDL.Record({});
  const Data__13 = IDL.Record({
    'inspirationCost' : IDL.Nat,
    'talesCost' : IDL.Nat,
    'requestCost' : IDL.Nat,
  });
  const Data__2 = IDL.Record({
    'blessingCost' : IDL.Nat,
    'communeCost' : IDL.Nat,
    'healingCost' : IDL.Nat,
  });
  const Data = IDL.Record({});
  const Data__14 = IDL.Record({ 'cost' : IDL.Nat });
  const Data__1 = IDL.Record({});
  const Data__3 = IDL.Record({ 'upgradeCost' : IDL.Nat });
  const Data__4 = IDL.Record({
    'communeCost' : IDL.Nat,
    'harvestCost' : IDL.Nat,
    'meditationCost' : IDL.Nat,
  });
  const Data__10 = IDL.Record({
    'reforgeCost' : IDL.Nat,
    'upgradeCost' : IDL.Nat,
    'craftCost' : IDL.Nat,
  });
  const Data__9 = IDL.Record({});
  const Data__7 = IDL.Record({
    'mapCost' : IDL.Nat,
    'skillCost' : IDL.Nat,
    'studyCost' : IDL.Nat,
  });
  const Item = IDL.Variant({
    'echoCrystal' : IDL.Null,
    'herbs' : IDL.Null,
    'treasureMap' : IDL.Null,
    'healthPotion' : IDL.Null,
    'fairyCharm' : IDL.Null,
  });
  const Trinket = IDL.Record({ 'cost' : IDL.Nat, 'item' : Item });
  const Data__5 = IDL.Record({ 'trinket' : Trinket });
  const Data__8 = IDL.Record({});
  const Data__11 = IDL.Record({});
  const ScenarioKind = IDL.Variant({
    'goblinRaidingParty' : Data__6,
    'trappedDruid' : Data__12,
    'travelingBard' : Data__13,
    'druidicSanctuary' : Data__2,
    'corruptedTreant' : Data,
    'wanderingAlchemist' : Data__14,
    'darkElfAmbush' : Data__1,
    'dwarvenWeaponsmith' : Data__3,
    'enchantedGrove' : Data__4,
    'mysticForge' : Data__10,
    'mysteriousStructure' : Data__9,
    'knowledgeNexus' : Data__7,
    'fairyMarket' : Data__5,
    'lostElfling' : Data__8,
    'sinkingBoat' : Data__11,
  });
  const Outcome = IDL.Record({
    'messages' : IDL.Vec(IDL.Text),
    'choice' : IDL.Opt(IDL.Text),
  });
  const ScenarioOption = IDL.Record({
    'id' : IDL.Text,
    'description' : IDL.Text,
  });
  const Scenario = IDL.Record({
    'id' : IDL.Nat,
    'title' : IDL.Text,
    'voteData' : ScenarioVote,
    'kind' : ScenarioKind,
    'description' : IDL.Text,
    'outcome' : IDL.Opt(Outcome),
    'options' : IDL.Vec(ScenarioOption),
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
  const InitializeResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : IDL.Variant({ 'alreadyInitialized' : IDL.Null }),
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
    'createWorldProposal' : IDL.Func(
        [CreateWorldProposalRequest],
        [CreateWorldProposalResult],
        [],
      ),
    'getGameState' : IDL.Func([], [GameState], ['query']),
    'getScenario' : IDL.Func([IDL.Nat], [GetScenarioResult], ['query']),
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
