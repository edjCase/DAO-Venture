export const idlFactory = ({ IDL }) => {
  const GetCyclesResult = IDL.Variant({
    'ok' : IDL.Nat,
    'notAuthorized' : IDL.Null,
  });
  const GetMatchGroupVoteRequest = IDL.Record({ 'matchGroupId' : IDL.Nat });
  const MatchGroupVoteResult = IDL.Record({ 'scenarioChoice' : IDL.Nat8 });
  const GetMatchGroupVoteResult = IDL.Variant({
    'ok' : MatchGroupVoteResult,
    'noVotes' : IDL.Null,
    'notAuthorized' : IDL.Null,
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
  const Skills = IDL.Record({
    'battingAccuracy' : IDL.Int,
    'throwingAccuracy' : IDL.Int,
    'speed' : IDL.Int,
    'catching' : IDL.Int,
    'battingPower' : IDL.Int,
    'defense' : IDL.Int,
    'throwingPower' : IDL.Int,
  });
  const PlayerWithId = IDL.Record({
    'id' : IDL.Nat32,
    'title' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
    'likes' : IDL.Vec(IDL.Text),
    'teamId' : IDL.Principal,
    'position' : FieldPosition,
    'quirks' : IDL.Vec(IDL.Text),
    'dislikes' : IDL.Vec(IDL.Text),
    'skills' : Skills,
    'traitIds' : IDL.Vec(IDL.Text),
  });
  const OnSeasonCompleteResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
  });
  const VoteOnMatchGroupRequest = IDL.Record({
    'matchGroupId' : IDL.Nat,
    'scenarioChoice' : IDL.Nat8,
  });
  const InvalidVoteError = IDL.Variant({ 'invalidChoice' : IDL.Nat8 });
  const VoteOnMatchGroupResult = IDL.Variant({
    'ok' : IDL.Null,
    'teamNotInMatchGroup' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'invalid' : IDL.Vec(InvalidVoteError),
    'alreadyVoted' : IDL.Null,
    'seasonStatusFetchError' : IDL.Text,
    'matchGroupNotFound' : IDL.Null,
    'votingNotOpen' : IDL.Null,
  });
  const TeamActor = IDL.Service({
    'getCycles' : IDL.Func([], [GetCyclesResult], []),
    'getMatchGroupVote' : IDL.Func(
        [GetMatchGroupVoteRequest],
        [GetMatchGroupVoteResult],
        ['query'],
      ),
    'getPlayers' : IDL.Func([], [IDL.Vec(PlayerWithId)], ['composite_query']),
    'onSeasonComplete' : IDL.Func([], [OnSeasonCompleteResult], []),
    'voteOnMatchGroup' : IDL.Func(
        [VoteOnMatchGroupRequest],
        [VoteOnMatchGroupResult],
        [],
      ),
  });
  return TeamActor;
};
export const init = ({ IDL }) => { return [IDL.Principal, IDL.Principal]; };
