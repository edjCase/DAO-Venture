import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export type CreateTeamRequest = {};
export type CreateTeamResult = { 'ok' : { 'id' : Principal } };
export type SetLeagueResult = { 'ok' : null } |
  { 'notAuthorized' : null };
export interface TeamActorInfoWithId { 'id' : Principal }
export interface _SERVICE {
  'createTeamActor' : ActorMethod<[CreateTeamRequest], CreateTeamResult>,
  'getTeams' : ActorMethod<[], Array<TeamActorInfoWithId>>,
  'setLeague' : ActorMethod<[Principal], SetLeagueResult>,
  'updateCanisters' : ActorMethod<[], undefined>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
