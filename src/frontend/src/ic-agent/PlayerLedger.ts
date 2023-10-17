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
export interface PlayerWithId extends PlayerInfo { 'id': number }

export type InvalidError = { 'nameTaken': null }
  | { 'nameNotSpecified': null };


export type CreateResult =
  { 'created': number }
  | { 'invalid': InvalidError[] }

export interface _SERVICE {
  'create': ActorMethod<[PlayerCreationOptions], CreateResult>,
  'getAllPlayers': ActorMethod<[], Array<PlayerWithId>>,
  'getPlayer': ActorMethod<
    [number],
    { 'ok': PlayerWithId } |
    { 'notFound': null }
  >,
  'getTeamPlayers': ActorMethod<[[] | [Principal]], Array<PlayerWithId>>,
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
  const InvalidError = IDL.Variant({
    'nameTaken': IDL.Null,
    'nameNotSpecified': IDL.Null,
  });
  const CreateResult = IDL.Variant({
    'created': IDL.Nat32,
    'invalid': IDL.Vec(InvalidError)
  });
  return IDL.Service({
    'create': IDL.Func([PlayerCreationOptions], [CreateResult], []),
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
