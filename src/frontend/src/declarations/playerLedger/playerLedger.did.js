export const idlFactory = ({ IDL }) => {
  const PlayerCreationOptions = IDL.Record({
    'name' : IDL.Text,
    'teamId' : IDL.Opt(IDL.Principal),
  });
  const Player = IDL.Record({ 'name' : IDL.Text });
  const PlayerInfoWithId = IDL.Record({
    'id' : IDL.Nat32,
    'player' : Player,
    'teamId' : IDL.Opt(IDL.Principal),
  });
  const PlayerInfo = IDL.Record({
    'player' : Player,
    'teamId' : IDL.Opt(IDL.Principal),
  });
  return IDL.Service({
    'create' : IDL.Func([PlayerCreationOptions], [IDL.Nat32], []),
    'getAllPlayers' : IDL.Func([], [IDL.Vec(PlayerInfoWithId)], ['query']),
    'getPlayer' : IDL.Func(
        [IDL.Nat32],
        [IDL.Variant({ 'ok' : PlayerInfo, 'notFound' : IDL.Null })],
        ['query'],
      ),
    'getTeamPlayers' : IDL.Func(
        [IDL.Opt(IDL.Principal)],
        [IDL.Vec(PlayerInfoWithId)],
        ['query'],
      ),
    'setPlayerTeam' : IDL.Func(
        [IDL.Nat32, IDL.Opt(IDL.Principal)],
        [IDL.Variant({ 'ok' : IDL.Null, 'playerNotFound' : IDL.Null })],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
