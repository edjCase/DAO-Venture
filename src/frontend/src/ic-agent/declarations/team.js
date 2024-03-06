export const idlFactory = ({ IDL }) => {
  const GetCyclesResult = IDL.Variant({
    'ok' : IDL.Nat,
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
    'getCycles' : IDL.Func([], [GetCyclesResult], []),
    'getPlayers' : IDL.Func([], [IDL.Vec(PlayerWithId)], ['composite_query']),
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
    'voteOnScenario' : IDL.Func(
        [VoteOnScenarioRequest],
        [VoteOnScenarioResult],
        [],
      ),
  });
  return TeamActor;
};
export const init = ({ IDL }) => { return [IDL.Principal, IDL.Principal]; };
