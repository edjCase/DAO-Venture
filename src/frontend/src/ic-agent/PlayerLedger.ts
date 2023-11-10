import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import { createActor } from './Actor';
import { FieldPosition as FieldPositionModel } from '../models/FieldPosition';
import { Deity as DeityModel } from '../models/Deity';
import { toJsonString } from '../utils/JsonUtil';
import { InterfaceFactory } from '@dfinity/candid/lib/cjs/idl';
import { IDL } from "@dfinity/candid";

export type FieldPosition = { 'firstBase': null }
  | { 'secondBase': null }
  | { 'thirdBase': null }
  | { 'pitcher': null }
  | { 'shortStop': null }
  | { 'leftField': null }
  | { 'centerField': null }
  | { 'rightField': null };
export const FieldPositionIdl = IDL.Variant({
  'firstBase': IDL.Null,
  'secondBase': IDL.Null,
  'thirdBase': IDL.Null,
  'pitcher': IDL.Null,
  'shortStop': IDL.Null,
  'leftField': IDL.Null,
  'centerField': IDL.Null,
  'rightField': IDL.Null,
});

export type Deity =
  | { 'indulgence': null }
  | { 'mischief': null }
  | { 'pestilence': null }
  | { 'war': null };
export const DeityIdl = IDL.Variant({
  'indulgence': IDL.Null,
  'mischief': IDL.Null,
  'pestilence': IDL.Null,
  'war': IDL.Null
});

export type PlayerSkills = {
  'battingAccuracy': number,
  'battingPower': number,
  'catching': number,
  'defense': number,
  'piety': number,
  'speed': number,
  'throwingAccuracy': number,
  'throwingPower': number
};
export const PlayerSkillsIdl = IDL.Record({
  'battingAccuracy': IDL.Int,
  'battingPower': IDL.Int,
  'catching': IDL.Int,
  'defense': IDL.Int,
  'piety': IDL.Int,
  'speed': IDL.Int,
  'throwingAccuracy': IDL.Int,
  'throwingPower': IDL.Int
});


export interface CreatePlayerRequest {
  'name': string,
  'teamId': [] | [Principal],
  'position': FieldPosition,
  'deity': Deity,
  'skills': PlayerSkills
};
export const CreatePlayerRequestIdl = IDL.Record({
  'name': IDL.Text,
  'teamId': IDL.Opt(IDL.Principal),
  'position': FieldPositionIdl,
  'deity': DeityIdl,
  'skills': PlayerSkillsIdl
});

export interface Player {
  'id': number,
  'name': string,
  'teamId': [] | [Principal],
  'position': FieldPosition,
  'deity': Deity,
  'skills': PlayerSkills
};
export const PlayerIdl = IDL.Record({
  'id': IDL.Nat32,
  'name': IDL.Text,
  'teamId': IDL.Opt(IDL.Principal),
  'position': FieldPositionIdl,
  'deity': DeityIdl,
  'skills': PlayerSkillsIdl
});

export type GetPlayerResult =
  { 'ok': Player }
  | { 'notFound': null };
export const GetPlayerResultIdl = IDL.Variant({
  'ok': PlayerIdl,
  'notFound': IDL.Null
});

export type SetPlayerTeamResult = {
  'ok': null
} | {
  'playerNotFound': null
};
export const SetPlayerTeamResultIdl = IDL.Variant({
  'ok': IDL.Null,
  'playerNotFound': IDL.Null
});

export type InvalidError = { 'nameTaken': null }
  | { 'nameNotSpecified': null };
const InvalidErrorIdl = IDL.Variant({
  'nameTaken': IDL.Null,
  'nameNotSpecified': IDL.Null,
});


export type CreatePlayerResult =
  { 'created': number }
  | { 'invalid': InvalidError[] };
export const CreatePlayerResultIdl = IDL.Variant({
  'created': IDL.Nat32,
  'invalid': IDL.Vec(InvalidErrorIdl)
});








export interface _SERVICE {
  'create': ActorMethod<[CreatePlayerRequest], CreatePlayerResult>,
  'getAllPlayers': ActorMethod<[], Array<Player>>,
  'getPlayer': ActorMethod<[number], GetPlayerResult>,
  'getTeamPlayers': ActorMethod<[[] | [Principal]], Array<Player>>,
  'setPlayerTeam': ActorMethod<
    [number, [] | [Principal]],
    SetPlayerTeamResult
  >,
}


export const idlFactory: InterfaceFactory = ({ IDL }) => {
  return IDL.Service({
    'create': IDL.Func([CreatePlayerRequestIdl], [CreatePlayerResultIdl], []),
    'getAllPlayers': IDL.Func([], [IDL.Vec(PlayerIdl)], ['query']),
    'getPlayer': IDL.Func([IDL.Nat32], [GetPlayerResultIdl], ['query']),
    'getTeamPlayers': IDL.Func([IDL.Opt(IDL.Principal)], [IDL.Vec(PlayerIdl)], ['query']),
    'setPlayerTeam': IDL.Func(
      [IDL.Nat32, IDL.Opt(IDL.Principal)],
      [SetPlayerTeamResultIdl],
      [],
    ),
  });
};
const canisterId = process.env.CANISTER_ID_PLAYERLEDGER || "";
// Keep factory due to changing identity
export const playerLedgerAgentFactory = () => createActor<_SERVICE>(canisterId, idlFactory);

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

  throw new Error("Invalid position: " + toJsonString(position));
}
export function mapDeity(deity: DeityModel): Deity {
  switch (deity) {
    case DeityModel.War:
      return { war: null };
    case DeityModel.Pestilence:
      return { pestilence: null };
    case DeityModel.Mischief:
      return { mischief: null };
    case DeityModel.Indulgence:
      return { indulgence: null };
    default:
      throw "Invalid deity: " + deity;
  }
};
export function unMapDeity(deity: Deity): DeityModel {
  if ('war' in deity) {
    return DeityModel.War;
  }
  if ('pestilence' in deity) {
    return DeityModel.Pestilence;
  }
  if ('mischief' in deity) {
    return DeityModel.Mischief;
  }
  if ('indulgence' in deity) {
    return DeityModel.Indulgence;
  }

  throw new Error("Invalid deity: " + toJsonString(deity));
}
