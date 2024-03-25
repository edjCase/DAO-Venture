import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface AddTeamOwnerRequest {
  'votingPower' : bigint,
  'userId' : Principal,
  'teamId' : bigint,
}
export type AddTeamOwnerResult = { 'ok' : null } |
  { 'notAuthorized' : null } |
  { 'onOtherTeam' : bigint } |
  { 'teamNotFound' : null };
export interface AwardPointsRequest { 'userId' : Principal, 'points' : bigint }
export type AwardPointsResult = { 'ok' : null } |
  { 'notAuthorized' : null };
export type GetStatsResult = { 'ok' : UserStats };
export type GetTeamOwnersRequest = { 'all' : null } |
  { 'team' : bigint };
export type GetTeamOwnersResult = { 'ok' : Array<UserVotingInfo> };
export type GetUserResult = { 'ok' : User } |
  { 'notAuthorized' : null } |
  { 'notFound' : null };
export type OnSeasonEndResult = { 'ok' : null } |
  { 'notAuthorized' : null };
export type SetUserFavoriteTeamResult = { 'ok' : null } |
  { 'notAuthorized' : null } |
  { 'alreadySet' : null } |
  { 'identityRequired' : null } |
  { 'teamNotFound' : null };
export type TeamAssociationKind = { 'fan' : null } |
  { 'owner' : { 'votingPower' : bigint } };
export interface TeamStats {
  'id' : bigint,
  'totalPoints' : bigint,
  'ownerCount' : bigint,
  'userCount' : bigint,
}
export interface User {
  'id' : Principal,
  'team' : [] | [{ 'id' : bigint, 'kind' : TeamAssociationKind }],
  'points' : bigint,
}
export interface UserStats {
  'teams' : Array<TeamStats>,
  'teamOwnerCount' : bigint,
  'totalPoints' : bigint,
  'userCount' : bigint,
}
export interface UserVotingInfo { 'id' : Principal, 'votingPower' : bigint }
export interface _SERVICE {
  'addTeamOwner' : ActorMethod<[AddTeamOwnerRequest], AddTeamOwnerResult>,
  'awardPoints' : ActorMethod<[Array<AwardPointsRequest>], AwardPointsResult>,
  'get' : ActorMethod<[Principal], GetUserResult>,
  'getStats' : ActorMethod<[], GetStatsResult>,
  'getTeamOwners' : ActorMethod<[GetTeamOwnersRequest], GetTeamOwnersResult>,
  'onSeasonEnd' : ActorMethod<[], OnSeasonEndResult>,
  'setFavoriteTeam' : ActorMethod<
    [Principal, bigint],
    SetUserFavoriteTeamResult
  >,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
