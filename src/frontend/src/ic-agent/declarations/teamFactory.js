export const idlFactory = ({ IDL }) => {
  const CreateTeamRequest = IDL.Record({});
  const CreateTeamResult = IDL.Variant({
    'ok' : IDL.Record({ 'id' : IDL.Principal }),
  });
  const TeamActorInfoWithId = IDL.Record({ 'id' : IDL.Principal });
  const SetLeagueResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
  });
  return IDL.Service({
    'createTeamActor' : IDL.Func([CreateTeamRequest], [CreateTeamResult], []),
    'getTeams' : IDL.Func([], [IDL.Vec(TeamActorInfoWithId)], []),
    'setLeague' : IDL.Func([IDL.Principal], [SetLeagueResult], []),
    'updateCanisters' : IDL.Func([], [], []),
  });
};
export const init = ({ IDL }) => { return []; };
