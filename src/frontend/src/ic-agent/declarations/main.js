export const idlFactory = ({ IDL }) => {
  const MotionContent = IDL.Record({
    'title' : IDL.Text,
    'description' : IDL.Text,
  });
  const CreateWorldProposalRequest = IDL.Variant({ 'motion' : MotionContent });
  const CreateWorldProposalError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'invalid' : IDL.Vec(IDL.Text),
  });
  const CreateWorldProposalResult = IDL.Variant({
    'ok' : IDL.Nat,
    'err' : CreateWorldProposalError,
  });
  const GetAllScenariosRequest = IDL.Record({
    'count' : IDL.Nat,
    'offset' : IDL.Nat,
  });
  const MetaData = IDL.Record({ 'structureName' : IDL.Text });
  const Time = IDL.Int;
  const Choice = IDL.Record({});
  const ProposalStatus_1 = IDL.Variant({
    'failedToExecute' : IDL.Record({
      'executingTime' : Time,
      'error' : IDL.Text,
      'failedTime' : Time,
      'choice' : IDL.Opt(Choice),
    }),
    'open' : IDL.Null,
    'executing' : IDL.Record({
      'executingTime' : Time,
      'choice' : IDL.Opt(Choice),
    }),
    'executed' : IDL.Record({
      'executingTime' : Time,
      'choice' : IDL.Opt(Choice),
      'executedTime' : Time,
    }),
  });
  const ProposalContent__1 = IDL.Record({});
  const Vote_1 = IDL.Record({
    'votingPower' : IDL.Nat,
    'choice' : IDL.Opt(Choice),
  });
  const Proposal = IDL.Record({
    'id' : IDL.Nat,
    'status' : ProposalStatus_1,
    'content' : ProposalContent__1,
    'timeStart' : IDL.Int,
    'votes' : IDL.Vec(IDL.Tuple(IDL.Principal, Vote_1)),
    'endTimerId' : IDL.Opt(IDL.Nat),
    'timeEnd' : IDL.Opt(IDL.Int),
    'proposerId' : IDL.Principal,
  });
  const ScenarioData = IDL.Record({
    'metaData' : MetaData,
    'proposal' : Proposal,
  });
  const ScenarioKind = IDL.Variant({ 'mysteriousStructure' : ScenarioData });
  const Scenario = IDL.Record({ 'id' : IDL.Nat, 'kind' : ScenarioKind });
  const GetAllScenariosResult = IDL.Record({
    'data' : IDL.Vec(Scenario),
    'count' : IDL.Nat,
    'totalCount' : IDL.Nat,
    'offset' : IDL.Nat,
  });
  const GetScenarioError = IDL.Variant({
    'notStarted' : IDL.Null,
    'notFound' : IDL.Null,
  });
  const GetScenarioResult = IDL.Variant({
    'ok' : Scenario,
    'err' : GetScenarioError,
  });
  const GetScenarioVoteRequest = IDL.Record({ 'scenarioId' : IDL.Nat });
  const ScenarioChoiceKind = IDL.Variant({ 'mysteriousStructure' : Choice });
  const ChoiceVotingPower = IDL.Record({
    'votingPower' : IDL.Nat,
    'choice' : ScenarioChoiceKind,
  });
  const ScenarioVoteChoice = IDL.Record({
    'votingPower' : IDL.Nat,
    'choice' : IDL.Opt(ScenarioChoiceKind),
  });
  const ScenarioVote = IDL.Record({
    'votingPowerByChoice' : IDL.Vec(ChoiceVotingPower),
    'undecidedVotingPower' : IDL.Nat,
    'totalVotingPower' : IDL.Nat,
    'yourVote' : IDL.Opt(ScenarioVoteChoice),
  });
  const GetScenarioVoteError = IDL.Variant({
    'notEligible' : IDL.Null,
    'scenarioNotFound' : IDL.Null,
  });
  const GetScenarioVoteResult = IDL.Variant({
    'ok' : ScenarioVote,
    'err' : GetScenarioVoteError,
  });
  const GetTopUsersRequest = IDL.Record({
    'count' : IDL.Nat,
    'offset' : IDL.Nat,
  });
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
  const GetUserError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'notFound' : IDL.Null,
  });
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
  const ResourceKind = IDL.Variant({
    'food' : IDL.Null,
    'gold' : IDL.Null,
    'wood' : IDL.Null,
    'stone' : IDL.Null,
  });
  const ResourceRarity = IDL.Variant({
    'rare' : IDL.Null,
    'common' : IDL.Null,
    'uncommon' : IDL.Null,
  });
  const ResourceLocation = IDL.Record({
    'kind' : ResourceKind,
    'claimedByTownIds' : IDL.Vec(IDL.Nat),
    'rarity' : ResourceRarity,
  });
  const TownLocation = IDL.Record({ 'townId' : IDL.Nat });
  const UnexploredLocation = IDL.Record({
    'explorationNeeded' : IDL.Nat,
    'currentExploration' : IDL.Nat,
  });
  const LocationKind = IDL.Variant({
    'resource' : ResourceLocation,
    'town' : TownLocation,
    'unexplored' : UnexploredLocation,
  });
  const AxialCoordinate = IDL.Record({ 'q' : IDL.Int, 'r' : IDL.Int });
  const WorldLocation = IDL.Record({
    'id' : IDL.Nat,
    'kind' : LocationKind,
    'coordinate' : AxialCoordinate,
  });
  const World = IDL.Record({
    'nextDayStartTime' : IDL.Nat,
    'daysElapsed' : IDL.Nat,
    'progenitor' : IDL.Principal,
    'locations' : IDL.Vec(WorldLocation),
  });
  const GetWorldError = IDL.Variant({ 'worldNotInitialized' : IDL.Null });
  const GetWorldResult = IDL.Variant({ 'ok' : World, 'err' : GetWorldError });
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
    'endTimerId' : IDL.Opt(IDL.Nat),
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
  const InitializeWorldError = IDL.Variant({ 'alreadyInitialized' : IDL.Null });
  const Result_1 = IDL.Variant({
    'ok' : IDL.Null,
    'err' : InitializeWorldError,
  });
  const JoinWorldError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'alreadyWorldMember' : IDL.Null,
  });
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : JoinWorldError });
  const VoteOnScenarioRequest = IDL.Record({
    'scenarioId' : IDL.Nat,
    'value' : ScenarioChoiceKind,
  });
  const VoteOnScenarioError = IDL.Variant({
    'proposalNotFound' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'alreadyVoted' : IDL.Null,
    'votingClosed' : IDL.Null,
    'invalidChoice' : IDL.Null,
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
    'notAuthorized' : IDL.Null,
    'alreadyVoted' : IDL.Null,
    'votingClosed' : IDL.Null,
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
    'getAllScenarios' : IDL.Func(
        [GetAllScenariosRequest],
        [GetAllScenariosResult],
        ['query'],
      ),
    'getProgenitor' : IDL.Func([], [IDL.Opt(IDL.Principal)], ['query']),
    'getScenario' : IDL.Func([IDL.Nat], [GetScenarioResult], ['query']),
    'getScenarioVote' : IDL.Func(
        [GetScenarioVoteRequest],
        [GetScenarioVoteResult],
        ['query'],
      ),
    'getTopUsers' : IDL.Func(
        [GetTopUsersRequest],
        [GetTopUsersResult],
        ['query'],
      ),
    'getUser' : IDL.Func([IDL.Principal], [GetUserResult], ['query']),
    'getUserStats' : IDL.Func([], [GetUserStatsResult], ['query']),
    'getUsers' : IDL.Func([GetUsersRequest], [GetUsersResult], ['query']),
    'getWorld' : IDL.Func([], [GetWorldResult], ['query']),
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
    'intializeWorld' : IDL.Func([], [Result_1], []),
    'joinWorld' : IDL.Func([], [Result], []),
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
