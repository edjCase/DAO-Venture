export const idlFactory = ({ IDL }) => {
  const CreateStadiumResult = IDL.Variant({
    'ok' : IDL.Principal,
    'stadiumCreationError' : IDL.Text,
  });
  const StadiumActorInfoWithId = IDL.Record({ 'id' : IDL.Principal });
  const SetLeagueResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
  });
  return IDL.Service({
    'createStadiumActor' : IDL.Func([], [CreateStadiumResult], []),
    'getStadiums' : IDL.Func([], [IDL.Vec(StadiumActorInfoWithId)], []),
    'setLeague' : IDL.Func([IDL.Principal], [SetLeagueResult], []),
    'updateCanisters' : IDL.Func([], [], []),
  });
};
export const init = ({ IDL }) => { return []; };
