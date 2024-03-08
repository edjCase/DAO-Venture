export const idlFactory = ({ IDL }) => {
  const Skill = IDL.Variant({
    'battingAccuracy' : IDL.Null,
    'throwingAccuracy' : IDL.Null,
    'speed' : IDL.Null,
    'catching' : IDL.Null,
    'battingPower' : IDL.Null,
    'defense' : IDL.Null,
    'throwingPower' : IDL.Null,
  });
  const ProposalContent = IDL.Variant({
    'trainPlayer' : IDL.Record({ 'playerId' : IDL.Nat32, 'skill' : Skill }),
  });
  const CreateProposalRequest = IDL.Record({ 'content' : ProposalContent });
  const CreateProposalResult = IDL.Variant({
    'ok' : IDL.Nat,
    'notAuthorized' : IDL.Null,
  });
  const GetCyclesResult = IDL.Variant({
    'ok' : IDL.Nat,
    'notAuthorized' : IDL.Null,
  });
  const ProposalStatus = IDL.Variant({
    'open' : IDL.Null,
    'rejected' : IDL.Null,
    'executed' : IDL.Null,
  });
  const Vote = IDL.Record({
    'value' : IDL.Opt(IDL.Bool),
    'votingPower' : IDL.Nat,
  });
  const Proposal = IDL.Record({
    'id' : IDL.Nat,
    'status' : ProposalStatus,
    'content' : ProposalContent,
    'timeStart' : IDL.Int,
    'votes' : IDL.Vec(IDL.Tuple(IDL.Principal, Vote)),
    'endTimerId' : IDL.Opt(IDL.Nat),
    'proposer' : IDL.Principal,
    'timeEnd' : IDL.Int,
  });
  const GetScenarioVoteRequest = IDL.Record({ 'scenarioId' : IDL.Text });
  const GetScenarioVoteResult = IDL.Variant({
    'ok' : IDL.Opt(IDL.Nat),
    'scenarioNotFound' : IDL.Null,
  });
  const GetWinningScenarioOptionRequest = IDL.Record({
    'scenarioId' : IDL.Text,
  });
  const GetWinningScenarioOptionResult = IDL.Variant({
    'ok' : IDL.Nat,
    'noVotes' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'scenarioNotFound' : IDL.Null,
  });
  const OnNewScenarioRequest = IDL.Record({
    'scenarioId' : IDL.Text,
    'optionCount' : IDL.Nat,
  });
  const OnNewScenarioResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
  });
  const OnScenarioVoteCompleteRequest = IDL.Record({ 'scenarioId' : IDL.Text });
  const OnScenarioVoteCompleteResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'scenarioNotFound' : IDL.Null,
  });
  const OnSeasonCompleteResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
  });
  const VoteOnProposalRequest = IDL.Record({
    'vote' : IDL.Bool,
    'proposalId' : IDL.Nat,
  });
  const VoteOnProposalResult = IDL.Variant({
    'ok' : IDL.Null,
    'proposalNotFound' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'alreadyVoted' : IDL.Null,
    'votingClosed' : IDL.Null,
  });
  const VoteOnScenarioRequest = IDL.Record({
    'scenarioId' : IDL.Text,
    'option' : IDL.Nat,
  });
  const VoteOnScenarioResult = IDL.Variant({
    'ok' : IDL.Null,
    'invalidOption' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'alreadyVoted' : IDL.Null,
    'seasonStatusFetchError' : IDL.Text,
    'teamNotInScenario' : IDL.Null,
    'votingNotOpen' : IDL.Null,
    'scenarioNotFound' : IDL.Null,
  });
  const TeamActor = IDL.Service({
    'createProposal' : IDL.Func(
        [CreateProposalRequest],
        [CreateProposalResult],
        [],
      ),
    'getCycles' : IDL.Func([], [GetCyclesResult], []),
    'getProposal' : IDL.Func([IDL.Nat], [IDL.Opt(Proposal)], ['query']),
    'getProposals' : IDL.Func([], [IDL.Vec(Proposal)], ['query']),
    'getScenarioVote' : IDL.Func(
        [GetScenarioVoteRequest],
        [GetScenarioVoteResult],
        ['query'],
      ),
    'getWinningScenarioOption' : IDL.Func(
        [GetWinningScenarioOptionRequest],
        [GetWinningScenarioOptionResult],
        [],
      ),
    'onNewScenario' : IDL.Func(
        [OnNewScenarioRequest],
        [OnNewScenarioResult],
        [],
      ),
    'onScenarioVoteComplete' : IDL.Func(
        [OnScenarioVoteCompleteRequest],
        [OnScenarioVoteCompleteResult],
        [],
      ),
    'onSeasonComplete' : IDL.Func([], [OnSeasonCompleteResult], []),
    'voteOnProposal' : IDL.Func(
        [VoteOnProposalRequest],
        [VoteOnProposalResult],
        [],
      ),
    'voteOnScenario' : IDL.Func(
        [VoteOnScenarioRequest],
        [VoteOnScenarioResult],
        [],
      ),
  });
  return TeamActor;
};
export const init = ({ IDL }) => { return [IDL.Principal, IDL.Principal]; };
