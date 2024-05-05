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
  const CreateProposalError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'teamNotFound' : IDL.Null,
  });
  const CreateProposalResult = IDL.Variant({
    'ok' : IDL.Nat,
    'err' : CreateProposalError,
  });
  const CreateTeamRequest = IDL.Record({
    'motto' : IDL.Text,
    'name' : IDL.Text,
    'color' : IDL.Tuple(IDL.Nat8, IDL.Nat8, IDL.Nat8),
    'description' : IDL.Text,
    'logoUrl' : IDL.Text,
  });
  const CreateTeamResult = IDL.Variant({
    'ok' : IDL.Nat,
    'nameTaken' : IDL.Null,
    'notAuthorized' : IDL.Null,
  });
  const GetCyclesResult = IDL.Variant({
    'ok' : IDL.Nat,
    'notAuthorized' : IDL.Null,
  });
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
  const Link = IDL.Record({ 'url' : IDL.Text, 'name' : IDL.Text });
  const Team = IDL.Record({
    'id' : IDL.Nat,
    'motto' : IDL.Text,
    'name' : IDL.Text,
    'color' : IDL.Tuple(IDL.Nat8, IDL.Nat8, IDL.Nat8),
    'description' : IDL.Text,
    'links' : IDL.Vec(Link),
    'entropy' : IDL.Nat,
    'logoUrl' : IDL.Text,
    'energy' : IDL.Int,
  });
  const CompletedMatchTeam = IDL.Record({ 'id' : IDL.Nat, 'score' : IDL.Int });
  const MatchAura = IDL.Variant({
    'foggy' : IDL.Null,
    'moveBasesIn' : IDL.Null,
    'extraStrike' : IDL.Null,
    'moreBlessingsAndCurses' : IDL.Null,
    'fastBallsHardHits' : IDL.Null,
    'explodingBalls' : IDL.Null,
    'lowGravity' : IDL.Null,
    'doubleOrNothing' : IDL.Null,
    'windy' : IDL.Null,
    'rainy' : IDL.Null,
  });
  const TeamIdOrTie = IDL.Variant({
    'tie' : IDL.Null,
    'team1' : IDL.Null,
    'team2' : IDL.Null,
  });
  const CompletedMatch = IDL.Record({
    'team1' : CompletedMatchTeam,
    'team2' : CompletedMatchTeam,
    'aura' : MatchAura,
    'winner' : TeamIdOrTie,
  });
  const CompletedMatchGroup = IDL.Record({
    'time' : Time,
    'matches' : IDL.Vec(CompletedMatch),
  });
  const OnMatchGroupCompleteRequest = IDL.Record({
    'matchGroup' : CompletedMatchGroup,
  });
  const OnMatchGroupCompleteError = IDL.Variant({ 'notAuthorized' : IDL.Null });
  const Result = IDL.Variant({
    'ok' : IDL.Null,
    'err' : OnMatchGroupCompleteError,
  });
  const OnSeasonEndResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
  });
  const SetLeagueResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
  });
  const UpdateTeamColorResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'teamNotFound' : IDL.Null,
  });
  const UpdateTeamDescriptionResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'teamNotFound' : IDL.Null,
  });
  const UpdateTeamEnergyResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'teamNotFound' : IDL.Null,
  });
  const UpdateTeamEntropyResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'teamNotFound' : IDL.Null,
  });
  const UpdateTeamLogoResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'teamNotFound' : IDL.Null,
  });
  const UpdateTeamMottoResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'teamNotFound' : IDL.Null,
  });
  const UpdateTeamNameResult = IDL.Variant({
    'ok' : IDL.Null,
    'nameTaken' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'teamNotFound' : IDL.Null,
  });
  const VoteOnProposalRequest = IDL.Record({
    'vote' : IDL.Bool,
    'proposalId' : IDL.Nat,
  });
  const VoteOnProposalError = IDL.Variant({
    'proposalNotFound' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'alreadyVoted' : IDL.Null,
    'votingClosed' : IDL.Null,
    'teamNotFound' : IDL.Null,
  });
  const VoteOnProposalResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : VoteOnProposalError,
  });
  return IDL.Service({
    'createProposal' : IDL.Func(
        [IDL.Nat, CreateProposalRequest],
        [CreateProposalResult],
        [],
      ),
    'createTeam' : IDL.Func([CreateTeamRequest], [CreateTeamResult], []),
    'getCycles' : IDL.Func([], [GetCyclesResult], []),
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
    'getTeams' : IDL.Func([], [IDL.Vec(Team)], ['query']),
    'onMatchGroupComplete' : IDL.Func(
        [OnMatchGroupCompleteRequest],
        [Result],
        [],
      ),
    'onSeasonEnd' : IDL.Func([], [OnSeasonEndResult], []),
    'setLeague' : IDL.Func([IDL.Principal], [SetLeagueResult], []),
    'updateTeamColor' : IDL.Func(
        [IDL.Nat, IDL.Tuple(IDL.Nat8, IDL.Nat8, IDL.Nat8)],
        [UpdateTeamColorResult],
        [],
      ),
    'updateTeamDescription' : IDL.Func(
        [IDL.Nat, IDL.Text],
        [UpdateTeamDescriptionResult],
        [],
      ),
    'updateTeamEnergy' : IDL.Func(
        [IDL.Nat, IDL.Int],
        [UpdateTeamEnergyResult],
        [],
      ),
    'updateTeamEntropy' : IDL.Func(
        [IDL.Nat, IDL.Int],
        [UpdateTeamEntropyResult],
        [],
      ),
    'updateTeamLogo' : IDL.Func(
        [IDL.Nat, IDL.Text],
        [UpdateTeamLogoResult],
        [],
      ),
    'updateTeamMotto' : IDL.Func(
        [IDL.Nat, IDL.Text],
        [UpdateTeamMottoResult],
        [],
      ),
    'updateTeamName' : IDL.Func(
        [IDL.Nat, IDL.Text],
        [UpdateTeamNameResult],
        [],
      ),
    'voteOnProposal' : IDL.Func(
        [IDL.Nat, VoteOnProposalRequest],
        [VoteOnProposalResult],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
