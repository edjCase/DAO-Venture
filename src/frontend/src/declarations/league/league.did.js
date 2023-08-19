export const idlFactory = ({ IDL }) => {
  const CreateStadiumResult = IDL.Variant({ 'ok' : IDL.Principal });
  const CreateTeamResult = IDL.Variant({
    'ok' : IDL.Principal,
    'nameTaken' : IDL.Null,
  });
  const StadiumInfo = IDL.Record({ 'id' : IDL.Principal, 'name' : IDL.Text });
  const TeamInfo = IDL.Record({ 'id' : IDL.Principal, 'name' : IDL.Text });
  const Time = IDL.Int;
  const ScheduleMatchResult = IDL.Variant({
    'ok' : IDL.Null,
    'stadiumNotFound' : IDL.Null,
    'timeNotAvailable' : IDL.Null,
  });
  return IDL.Service({
    'createStadium' : IDL.Func([IDL.Text], [CreateStadiumResult], []),
    'createTeam' : IDL.Func([IDL.Text], [CreateTeamResult], []),
    'getStadiums' : IDL.Func([], [IDL.Vec(StadiumInfo)], ['query']),
    'getTeams' : IDL.Func([], [IDL.Vec(TeamInfo)], ['query']),
    'scheduleMatch' : IDL.Func(
        [IDL.Principal, IDL.Vec(IDL.Principal), Time],
        [ScheduleMatchResult],
        [],
      ),
    'updateLeagueCanisters' : IDL.Func([], [], []),
  });
};
export const init = ({ IDL }) => { return []; };
