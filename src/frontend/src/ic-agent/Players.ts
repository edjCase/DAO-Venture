import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import { createActor } from './Actor';
import { FieldPositionEnum } from '../models/FieldPosition';
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
  'speed': number,
  'throwingAccuracy': number,
  'throwingPower': number
};
export const PlayerSkillsIdl = IDL.Record({
  'battingAccuracy': IDL.Int,
  'battingPower': IDL.Int,
  'catching': IDL.Int,
  'defense': IDL.Int,
  'speed': IDL.Int,
  'throwingAccuracy': IDL.Int,
  'throwingPower': IDL.Int
});


export interface CreatePlayerFluffRequest {
  'name': string,
  'title': string,
  'description': string;
  'quirks': string[];
  'likes': string[];
  'dislikes': string[];
};
export const CreatePlayerFluffRequestIdl = IDL.Record({
  'name': IDL.Text,
  'title': IDL.Text,
  'description': IDL.Text,
  'quirks': IDL.Vec(IDL.Text),
  'likes': IDL.Vec(IDL.Text),
  'dislikes': IDL.Vec(IDL.Text),
});


export type Player = {
  id: number;
  name: string;
  title: string;
  description: string;
  quirks: string[];
  likes: string[];
  dislikes: string[];
  teamId: Principal;
  skills: PlayerSkills;
  position: FieldPosition;
};
export const PlayerIdl = IDL.Record({
  id: IDL.Nat32,
  name: IDL.Text,
  title: IDL.Text,
  description: IDL.Text,
  quirks: IDL.Vec(IDL.Text),
  likes: IDL.Vec(IDL.Text),
  dislikes: IDL.Vec(IDL.Text),
  teamId: IDL.Principal,
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
const canisterId = process.env.CANISTER_ID_PLAYERS || "";
// Keep factory due to changing identity
export const playersAgentFactory = () => createActor<_SERVICE>(canisterId, idlFactory);

export function mapPosition(position: FieldPositionEnum): FieldPosition {
  switch (position) {
    case FieldPositionEnum.Pitcher:
      return { pitcher: null };
    case FieldPositionEnum.FirstBase:
      return { firstBase: null };
    case FieldPositionEnum.SecondBase:
      return { secondBase: null };
    case FieldPositionEnum.ThirdBase:
      return { thirdBase: null };
    case FieldPositionEnum.ShortStop:
      return { shortStop: null };
    case FieldPositionEnum.LeftField:
      return { leftField: null };
    case FieldPositionEnum.CenterField:
      return { centerField: null };
    case FieldPositionEnum.RightField:
      return { rightField: null };
    default:
      throw "Invalid position: " + position;
  }
};
export function unMapPosition(position: FieldPosition): FieldPositionEnum {
  if ('pitcher' in position) {
    return FieldPositionEnum.Pitcher;
  }
  if ('firstBase' in position) {
    return FieldPositionEnum.FirstBase;
  }
  if ('secondBase' in position) {
    return FieldPositionEnum.SecondBase;
  }
  if ('thirdBase' in position) {
    return FieldPositionEnum.ThirdBase;
  }
  if ('shortStop' in position) {
    return FieldPositionEnum.ShortStop;
  }
  if ('leftField' in position) {
    return FieldPositionEnum.LeftField;
  }
  if ('centerField' in position) {
    return FieldPositionEnum.CenterField;
  }
  if ('rightField' in position) {
    return FieldPositionEnum.RightField;
  }

  throw new Error("Invalid position: " + toJsonString(position));
}
