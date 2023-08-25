import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import { createActor } from './Actor';

export interface Player { 'name': string }
export interface PlayerCreationOptions {
  'name': string,
  'teamId': [] | [Principal],
}
export interface PlayerInfo { 'player': Player, 'teamId': [] | [Principal] }
export interface PlayerInfoWithId {
  'id': number,
  'name': string,
  'teamId': [] | [Principal],
}
export interface _SERVICE {
  'create': ActorMethod<[PlayerCreationOptions], number>,
  'getAllPlayers': ActorMethod<[], Array<PlayerInfoWithId>>,
  'getPlayer': ActorMethod<
    [number],
    { 'ok': PlayerInfoWithId } |
    { 'notFound': null }
  >,
  'getTeamPlayers': ActorMethod<[[] | [Principal]], Array<PlayerInfoWithId>>,
  'setPlayerTeam': ActorMethod<
    [number, [] | [Principal]],
    { 'ok': null } |
    { 'playerNotFound': null }
  >,
}


export const idlFactory = ({ IDL }) => {
  const PlayerCreationOptions = IDL.Record({
    'name': IDL.Text,
    'teamId': IDL.Opt(IDL.Principal),
  });
  const PlayerInfoWithId = IDL.Record({
    'id': IDL.Nat32,
    'name': IDL.Text,
    'teamId': IDL.Opt(IDL.Principal),
  });
  const PlayerInfo = IDL.Record({
    'name': IDL.Text,
    'teamId': IDL.Opt(IDL.Principal),
  });
  return IDL.Service({
    'create': IDL.Func([PlayerCreationOptions], [IDL.Nat32], []),
    'getAllPlayers': IDL.Func([], [IDL.Vec(PlayerInfoWithId)], ['query']),
    'getPlayer': IDL.Func(
      [IDL.Nat32],
      [IDL.Variant({ 'ok': PlayerInfo, 'notFound': IDL.Null })],
      ['query'],
    ),
    'getTeamPlayers': IDL.Func(
      [IDL.Opt(IDL.Principal)],
      [IDL.Vec(PlayerInfoWithId)],
      ['query'],
    ),
    'setPlayerTeam': IDL.Func(
      [IDL.Nat32, IDL.Opt(IDL.Principal)],
      [IDL.Variant({ 'ok': IDL.Null, 'playerNotFound': IDL.Null })],
      [],
    ),
  });
};
const canisterId = process.env.CANISTER_ID_PLAYERLEDGER;
export const playerLedgerAgent = createActor<_SERVICE>(canisterId, idlFactory);