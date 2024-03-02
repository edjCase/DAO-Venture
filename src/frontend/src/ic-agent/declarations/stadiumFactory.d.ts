import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export type CreateStadiumResult = { 'ok' : Principal } |
  { 'stadiumCreationError' : string };
export type SetLeagueResult = { 'ok' : null } |
  { 'notAuthorized' : null };
export interface StadiumActorInfoWithId { 'id' : Principal }
export interface _SERVICE {
  'createStadiumActor' : ActorMethod<[], CreateStadiumResult>,
  'getStadiums' : ActorMethod<[], Array<StadiumActorInfoWithId>>,
  'setLeague' : ActorMethod<[Principal], SetLeagueResult>,
  'updateCanisters' : ActorMethod<[], undefined>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
