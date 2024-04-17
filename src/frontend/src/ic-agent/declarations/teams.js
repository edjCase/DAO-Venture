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
  const FieldPosition = IDL.Variant({
    'rightField' : IDL.Null,
    'leftField' : IDL.Null,
    'thirdBase' : IDL.Null,
    'pitcher' : IDL.Null,
    'secondBase' : IDL.Null,
    'shortStop' : IDL.Null,
    'centerField' : IDL.Null,
    'firstBase' : IDL.Null,
  });
  const TrainContent = IDL.Record({
    'skill' : Skill,
    'position' : FieldPosition,
  });
  const ChangeLogoContent = IDL.Record({ 'logoUrl' : IDL.Text });
  const ChangeNameContent = IDL.Record({ 'name' : IDL.Text });
  const ChangeMottoContent = IDL.Record({ 'motto' : IDL.Text });
  const ModifyLinkContent = IDL.Record({
    'url' : IDL.Opt(IDL.Text),
    'name' : IDL.Text,
  });
  const ChangeColorContent = IDL.Record({
    'color' : IDL.Tuple(IDL.Nat8, IDL.Nat8, IDL.Nat8),
  });
  const SwapPlayerPositionsContent = IDL.Record({
    'position1' : FieldPosition,
    'position2' : FieldPosition,
  });
  const ChangeDescriptionContent = IDL.Record({ 'description' : IDL.Text });
  const ProposalContent = IDL.Variant({
    'train' : TrainContent,
    'changeLogo' : ChangeLogoContent,
    'changeName' : ChangeNameContent,
    'changeMotto' : ChangeMottoContent,
    'modifyLink' : ModifyLinkContent,
    'changeColor' : ChangeColorContent,
    'swapPlayerPositions' : SwapPlayerPositionsContent,
    'changeDescription' : ChangeDescriptionContent,
  });
  const CreateProposalRequest = IDL.Record({ 'content' : ProposalContent });
  const CreateProposalResult = IDL.Variant({
    'ok' : IDL.Nat,
    'notAuthorized' : IDL.Null,
    'teamNotFound' : IDL.Null,
  });
  const CreateTeamRequest = IDL.Record({});
  const CreateTeamResult = IDL.Variant({
    'ok' : IDL.Record({ 'id' : IDL.Nat }),
    'notAuthorized' : IDL.Null,
  });
  const GetCyclesResult = IDL.Variant({
    'ok' : IDL.Nat,
    'notAuthorized' : IDL.Null,
  });
  const Link = IDL.Record({ 'url' : IDL.Text, 'name' : IDL.Text });
  const TeamLinks = IDL.Record({ 'links' : IDL.Vec(Link), 'teamId' : IDL.Nat });
  const GetLinksResult = IDL.Variant({ 'ok' : IDL.Vec(TeamLinks) });
  const Vote = IDL.Record({
    'value' : IDL.Opt(IDL.Bool),
    'votingPower' : IDL.Nat,
  });
  const Time = IDL.Int;
  const ProposalStatusLogEntry = IDL.Variant({
    'failedToExecute' : IDL.Record({ 'time' : Time, 'error' : IDL.Text }),
    'rejected' : IDL.Record({ 'time' : Time }),
    'executing' : IDL.Record({ 'time' : Time }),
    'executed' : IDL.Record({ 'time' : Time }),
  });
  const Proposal = IDL.Record({
    'id' : IDL.Nat,
    'content' : ProposalContent,
    'timeStart' : IDL.Int,
    'votes' : IDL.Vec(IDL.Tuple(IDL.Principal, Vote)),
    'statusLog' : IDL.Vec(ProposalStatusLogEntry),
    'endTimerId' : IDL.Opt(IDL.Nat),
    'proposer' : IDL.Principal,
    'timeEnd' : IDL.Int,
  });
  const GetProposalResult = IDL.Variant({
    'ok' : Proposal,
    'proposalNotFound' : IDL.Null,
    'teamNotFound' : IDL.Null,
  });
  const PagedResult = IDL.Record({
    'data' : IDL.Vec(Proposal),
    'count' : IDL.Nat,
    'offset' : IDL.Nat,
  });
  const GetProposalsResult = IDL.Variant({
    'ok' : PagedResult,
    'teamNotFound' : IDL.Null,
  });
  const GetScenarioVoteRequest = IDL.Record({ 'scenarioId' : IDL.Nat });
  const ScenarioVote = IDL.Record({
    'option' : IDL.Opt(IDL.Nat),
    'votingPower' : IDL.Nat,
  });
  const GetScenarioVoteResult = IDL.Variant({
    'ok' : ScenarioVote,
    'notEligible' : IDL.Null,
    'scenarioNotFound' : IDL.Null,
  });
  const GetScenarioVotingResultsRequest = IDL.Record({
    'scenarioId' : IDL.Nat,
  });
  const ScenarioTeamVotingResult = IDL.Record({
    'option' : IDL.Nat,
    'teamId' : IDL.Nat,
  });
  const ScenarioVotingResults = IDL.Record({
    'teamOptions' : IDL.Vec(ScenarioTeamVotingResult),
  });
  const GetScenarioVotingResultsResult = IDL.Variant({
    'ok' : ScenarioVotingResults,
    'notAuthorized' : IDL.Null,
    'scenarioNotFound' : IDL.Null,
  });
  const EnergyDividend = IDL.Record({ 'teamId' : IDL.Nat, 'energy' : IDL.Nat });
  const OnScenarioEndRequest = IDL.Record({
    'scenarioId' : IDL.Nat,
    'energyDividends' : IDL.Vec(EnergyDividend),
  });
  const OnScenarioEndResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'scenarioNotFound' : IDL.Null,
  });
  const OnScenarioStartRequest = IDL.Record({
    'scenarioId' : IDL.Nat,
    'optionCount' : IDL.Nat,
  });
  const OnScenarioStartResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
  });
  const OnSeasonEndResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
  });
  const SetLeagueResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
  });
  const UpdateTeamEnergyResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'teamNotFound' : IDL.Null,
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
    'teamNotFound' : IDL.Null,
  });
  const VoteOnScenarioRequest = IDL.Record({
    'scenarioId' : IDL.Nat,
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
    'teamNotFound' : IDL.Null,
    'scenarioNotFound' : IDL.Null,
  });
  return IDL.Service({
    'createProposal' : IDL.Func(
        [IDL.Nat, CreateProposalRequest],
        [CreateProposalResult],
        [],
      ),
    'createTeam' : IDL.Func([CreateTeamRequest], [CreateTeamResult], []),
    'getCycles' : IDL.Func([], [GetCyclesResult], []),
    'getLinks' : IDL.Func([], [GetLinksResult], ['query']),
    'getProposal' : IDL.Func(
        [IDL.Nat, IDL.Nat],
        [GetProposalResult],
        ['query'],
      ),
    'getProposals' : IDL.Func(
        [IDL.Nat, IDL.Nat, IDL.Nat],
        [GetProposalsResult],
        ['query'],
      ),
    'getScenarioVote' : IDL.Func(
        [GetScenarioVoteRequest],
        [GetScenarioVoteResult],
        ['query'],
      ),
    'getScenarioVotingResults' : IDL.Func(
        [GetScenarioVotingResultsRequest],
        [GetScenarioVotingResultsResult],
        [],
      ),
    'onScenarioEnd' : IDL.Func(
        [OnScenarioEndRequest],
        [OnScenarioEndResult],
        [],
      ),
    'onScenarioStart' : IDL.Func(
        [OnScenarioStartRequest],
        [OnScenarioStartResult],
        [],
      ),
    'onSeasonEnd' : IDL.Func([], [OnSeasonEndResult], []),
    'setLeague' : IDL.Func([IDL.Principal], [SetLeagueResult], []),
    'updateTeamEnergy' : IDL.Func(
        [IDL.Nat, IDL.Int],
        [UpdateTeamEnergyResult],
        [],
      ),
    'voteOnProposal' : IDL.Func(
        [IDL.Nat, VoteOnProposalRequest],
        [VoteOnProposalResult],
        [],
      ),
    'voteOnScenario' : IDL.Func(
        [VoteOnScenarioRequest],
        [VoteOnScenarioResult],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
