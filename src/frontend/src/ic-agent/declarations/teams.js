export const idlFactory = ({ IDL }) => {
  const AddTraitToTeamOk = IDL.Record({ 'hadTrait' : IDL.Bool });
  const AddTraitToTeamError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'traitNotFound' : IDL.Null,
    'teamNotFound' : IDL.Null,
  });
  const AddTraitToTeamResult = IDL.Variant({
    'ok' : AddTraitToTeamOk,
    'err' : AddTraitToTeamError,
  });
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
    'invalid' : IDL.Vec(IDL.Text),
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
  const CreateTeamError = IDL.Variant({
    'nameTaken' : IDL.Null,
    'notAuthorized' : IDL.Null,
  });
  const CreateTeamResult = IDL.Variant({
    'ok' : IDL.Nat,
    'err' : CreateTeamError,
  });
  const CreateTeamTraitRequest = IDL.Record({
    'id' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
  });
  const CreateTeamTraitError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'invalid' : IDL.Vec(IDL.Text),
    'idTaken' : IDL.Null,
  });
  const CreateTeamTraitResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : CreateTeamTraitError,
  });
  const GetCyclesError = IDL.Variant({ 'notAuthorized' : IDL.Null });
  const GetCyclesResult = IDL.Variant({
    'ok' : IDL.Nat,
    'err' : GetCyclesError,
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
  const GetProposalError = IDL.Variant({
    'proposalNotFound' : IDL.Null,
    'teamNotFound' : IDL.Null,
  });
  const GetProposalResult = IDL.Variant({
    'ok' : Proposal,
    'err' : GetProposalError,
  });
  const PagedResult = IDL.Record({
    'data' : IDL.Vec(Proposal),
    'count' : IDL.Nat,
    'offset' : IDL.Nat,
  });
  const GetProposalsError = IDL.Variant({ 'teamNotFound' : IDL.Null });
  const GetProposalsResult = IDL.Variant({
    'ok' : PagedResult,
    'err' : GetProposalsError,
  });
  const Trait = IDL.Record({
    'id' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
  });
  const Link = IDL.Record({ 'url' : IDL.Text, 'name' : IDL.Text });
  const Team = IDL.Record({
    'id' : IDL.Nat,
    'motto' : IDL.Text,
    'traits' : IDL.Vec(Trait),
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
  const OnSeasonEndError = IDL.Variant({ 'notAuthorized' : IDL.Null });
  const OnSeasonEndResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : OnSeasonEndError,
  });
  const RemoveTraitFromTeamOk = IDL.Record({ 'hadTrait' : IDL.Bool });
  const RemoveTraitFromTeamError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'traitNotFound' : IDL.Null,
    'teamNotFound' : IDL.Null,
  });
  const RemoveTraitFromTeamResult = IDL.Variant({
    'ok' : RemoveTraitFromTeamOk,
    'err' : RemoveTraitFromTeamError,
  });
  const UpdateTeamColorError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'teamNotFound' : IDL.Null,
  });
  const UpdateTeamColorResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : UpdateTeamColorError,
  });
  const UpdateTeamDescriptionError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'teamNotFound' : IDL.Null,
  });
  const UpdateTeamDescriptionResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : UpdateTeamDescriptionError,
  });
  const UpdateTeamEnergyError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'teamNotFound' : IDL.Null,
  });
  const UpdateTeamEnergyResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : UpdateTeamEnergyError,
  });
  const UpdateTeamEntropyError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'teamNotFound' : IDL.Null,
  });
  const UpdateTeamEntropyResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : UpdateTeamEntropyError,
  });
  const UpdateTeamLogoError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'teamNotFound' : IDL.Null,
  });
  const UpdateTeamLogoResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : UpdateTeamLogoError,
  });
  const UpdateTeamMottoError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'teamNotFound' : IDL.Null,
  });
  const UpdateTeamMottoResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : UpdateTeamMottoError,
  });
  const UpdateTeamNameError = IDL.Variant({
    'nameTaken' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'teamNotFound' : IDL.Null,
  });
  const UpdateTeamNameResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : UpdateTeamNameError,
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
  const TeamsActor = IDL.Service({
    'addTraitToTeam' : IDL.Func(
        [IDL.Nat, IDL.Text],
        [AddTraitToTeamResult],
        [],
      ),
    'createProposal' : IDL.Func(
        [IDL.Nat, CreateProposalRequest],
        [CreateProposalResult],
        [],
      ),
    'createTeam' : IDL.Func([CreateTeamRequest], [CreateTeamResult], []),
    'createTeamTrait' : IDL.Func(
        [CreateTeamTraitRequest],
        [CreateTeamTraitResult],
        [],
      ),
    'getCycles' : IDL.Func([], [GetCyclesResult], []),
    'getEntropyThreshold' : IDL.Func([], [IDL.Nat], ['query']),
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
    'getTraits' : IDL.Func([], [IDL.Vec(Trait)], ['query']),
    'onMatchGroupComplete' : IDL.Func(
        [OnMatchGroupCompleteRequest],
        [Result],
        [],
      ),
    'onSeasonEnd' : IDL.Func([], [OnSeasonEndResult], []),
    'removeTraitFromTeam' : IDL.Func(
        [IDL.Nat, IDL.Text],
        [RemoveTraitFromTeamResult],
        [],
      ),
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
  return TeamsActor;
};
export const init = ({ IDL }) => {
  return [IDL.Principal, IDL.Principal, IDL.Principal];
};
