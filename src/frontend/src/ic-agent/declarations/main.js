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
  const Trait = IDL.Record({
    'id' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
  });
  const Item__1 = IDL.Record({
    'id' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
  });
  const Character = IDL.Record({
    'gold' : IDL.Nat,
    'traits' : IDL.Vec(Trait),
    'items' : IDL.Vec(Item__1),
    'health' : IDL.Nat,
  });
  const AxialCoordinate = IDL.Record({ 'q' : IDL.Int, 'r' : IDL.Int });
  const Location = IDL.Record({
    'id' : IDL.Nat,
    'scenarioId' : IDL.Nat,
    'coordinate' : AxialCoordinate,
  });
  const GameState = IDL.Record({
    'character' : Character,
    'turn' : IDL.Nat,
    'locations' : IDL.Vec(Location),
    'characterLocationId' : IDL.Nat,
  });
  const GetGameStateError = IDL.Variant({ 'noActiveGame' : IDL.Null });
  const GetGameStateResult = IDL.Variant({
    'ok' : GameState,
    'err' : GetGameStateError,
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
  const Data__4 = IDL.Record({ 'bribeCost' : IDL.Nat });
  const Data__8 = IDL.Record({});
  const Data = IDL.Record({});
  const Data__9 = IDL.Record({ 'cost' : IDL.Nat });
  const Data__1 = IDL.Record({});
  const Data__2 = IDL.Record({ 'upgradeCost' : IDL.Nat });
  const Data__6 = IDL.Record({});
  const Item = IDL.Variant({
    'echoCrystal' : IDL.Null,
    'herbs' : IDL.Null,
    'healthPotion' : IDL.Null,
    'fairyCharm' : IDL.Null,
  });
  const Trinket = IDL.Record({ 'cost' : IDL.Nat, 'item' : Item });
  const Data__3 = IDL.Record({ 'trinket' : Trinket });
  const Data__5 = IDL.Record({});
  const Data__7 = IDL.Record({});
  const ScenarioKind = IDL.Variant({
    'goblinRaidingParty' : Data__4,
    'trappedDruid' : Data__8,
    'corruptedTreant' : Data,
    'wanderingAlchemist' : Data__9,
    'darkElfAmbush' : Data__1,
    'dwarvenWeaponsmith' : Data__2,
    'mysteriousStructure' : Data__6,
    'fairyMarket' : Data__3,
    'lostElfling' : Data__5,
    'sinkingBoat' : Data__7,
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
  const JoinError = IDL.Variant({ 'alreadyMember' : IDL.Null });
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : JoinError });
  const NextTurnResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : IDL.Variant({ 'noActiveInstance' : IDL.Null }),
  });
  const StartGameError = IDL.Variant({ 'alreadyStarted' : IDL.Null });
  const StartGameResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : StartGameError,
  });
  const VoteOnScenarioRequest = IDL.Record({
    'scenarioId' : IDL.Nat,
    'value' : IDL.Text,
  });
  const VoteOnScenarioError = IDL.Variant({
    'noActiveGame' : IDL.Null,
    'proposalNotFound' : IDL.Null,
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
    'getGameState' : IDL.Func([], [GetGameStateResult], ['query']),
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
    'join' : IDL.Func([], [Result], []),
    'nextTurn' : IDL.Func([], [NextTurnResult], []),
    'startGame' : IDL.Func([], [StartGameResult], []),
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
