import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import { createActor } from './Actor';
import { FieldPosition as FieldPositionModel } from '../models/FieldPosition';

export type FieldPosition = { 'firstBase': null }
  | { 'secondBase': null }
  | { 'thirdBase': null }
  | { 'pitcher': null }
  | { 'shortStop': null }
  | { 'leftField': null }
  | { 'centerField': null }
  | { 'rightField': null };

export interface PlayerCreationOptions {
  'name': string,
  'teamId': [] | [Principal],
  'position': FieldPosition
}
export interface PlayerInfo {
  'name': string,
  'teamId': [] | [Principal],
  'position': FieldPosition
}
export interface PlayerInfoWithId extends PlayerInfo { 'id': number }
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
  const position = IDL.Variant({
    'firstBase': IDL.Null,
    'secondBase': IDL.Null,
    'thirdBase': IDL.Null,
    'pitcher': IDL.Null,
    'shortStop': IDL.Null,
    'leftField': IDL.Null,
    'centerField': IDL.Null,
    'rightField': IDL.Null,
  });
  const PlayerCreationOptions = IDL.Record({
    'name': IDL.Text,
    'teamId': IDL.Opt(IDL.Principal),
    'position': position
  });
  const PlayerInfoWithId = IDL.Record({
    'id': IDL.Nat32,
    'name': IDL.Text,
    'teamId': IDL.Opt(IDL.Principal),
    'position': position
  });
  const PlayerInfo = IDL.Record({
    'name': IDL.Text,
    'teamId': IDL.Opt(IDL.Principal),
    'position': position
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

export function mapPosition(position: FieldPositionModel): FieldPosition {
  switch (position) {
    case FieldPositionModel.Pitcher:
      return { pitcher: null };
    case FieldPositionModel.FirstBase:
      return { firstBase: null };
    case FieldPositionModel.SecondBase:
      return { secondBase: null };
    case FieldPositionModel.ThirdBase:
      return { thirdBase: null };
    case FieldPositionModel.ShortStop:
      return { shortStop: null };
    case FieldPositionModel.LeftField:
      return { leftField: null };
    case FieldPositionModel.CenterField:
      return { centerField: null };
    case FieldPositionModel.RightField:
      return { rightField: null };
    default:
      throw "Invalid position: " + position;
  }
};
export function unMapPosition(position: FieldPosition): FieldPositionModel {
  if ('pitcher' in position) {
    return FieldPositionModel.Pitcher;
  }
  if ('firstBase' in position) {
    return FieldPositionModel.FirstBase;
  }
  if ('secondBase' in position) {
    return FieldPositionModel.SecondBase;
  }
  if ('thirdBase' in position) {
    return FieldPositionModel.ThirdBase;
  }
  if ('shortStop' in position) {
    return FieldPositionModel.ShortStop;
  }
  if ('leftField' in position) {
    return FieldPositionModel.LeftField;
  }
  if ('centerField' in position) {
    return FieldPositionModel.CenterField;
  }
  if ('rightField' in position) {
    return FieldPositionModel.RightField;
  }

  throw new Error("Invalid position: " + JSON.stringify(position));
}
