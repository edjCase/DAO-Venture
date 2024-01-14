import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import { createActor } from './Actor';
import { FieldPosition as FieldPositionModel } from '../models/FieldPosition';
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


export interface CreatePlayerFluffRequest {
  'name': string,
  'genesis': string;
  'quirks': string[];
  'likes': string[];
  'dislikes': string[];
};
export const CreatePlayerFluffRequestIdl = IDL.Record({
  'name': IDL.Text,
  'genesis': IDL.Text,
  'quirks': IDL.Vec(IDL.Text),
  'likes': IDL.Vec(IDL.Text),
  'dislikes': IDL.Vec(IDL.Text),
});


export type Player = {
  id: number;
  name: string;
  genesis: string;
  quirks: string[];
  likes: string[];
  dislikes: string[];
  teamId: [Principal] | [];
  skills: PlayerSkills;
  position: FieldPosition;
};
export const PlayerIdl = IDL.Record({
  id: IDL.Nat32,
  name: IDL.Text,
  genesis: IDL.Text,
  quirks: IDL.Vec(IDL.Text),
  likes: IDL.Vec(IDL.Text),
  dislikes: IDL.Vec(IDL.Text),
  teamId: IDL.Opt(IDL.Principal),
  skills: PlayerSkillsIdl,
  position: FieldPositionIdl
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


export type CreatePlayerFluffResult =
  { 'created': null }
  | { 'invalid': InvalidError[] };
export const CreatePlayerFluffResultIdl = IDL.Variant({
  'created': IDL.Null,
  'invalid': IDL.Vec(InvalidErrorIdl)
});








export interface _SERVICE {
  'createFluff': ActorMethod<[CreatePlayerFluffRequest], CreatePlayerFluffResult>,
  'getAllPlayers': ActorMethod<[], Array<Player>>,
  'getPlayer': ActorMethod<[number], GetPlayerResult>,
  'getTeamPlayers': ActorMethod<[[] | [Principal]], Array<Player>>,
  'setPlayerTeam': ActorMethod<
    [number, [] | [Principal]],
    SetPlayerTeamResult
  >
}


export const idlFactory: InterfaceFactory = ({ IDL }) => {
  return IDL.Service({
    'createFluff': IDL.Func([CreatePlayerFluffRequestIdl], [CreatePlayerFluffResultIdl], []),
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
