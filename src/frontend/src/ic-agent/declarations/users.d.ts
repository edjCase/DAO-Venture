import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export type AddTeamOwnerError = { 'notAuthorized' : null } |
  { 'onOtherTeam' : bigint } |
  { 'teamNotFound' : null };
export interface AddTeamOwnerRequest {
  'votingPower' : bigint,
  'userId' : Principal,
  'teamId' : bigint,
}
export type AddTeamOwnerResult = { 'ok' : null } |
  { 'err' : AddTeamOwnerError };
export type AwardPointsError = { 'notAuthorized' : null };
export interface AwardPointsRequest { 'userId' : Principal, 'points' : bigint }
export type AwardPointsResult = { 'ok' : null } |
  { 'err' : AwardPointsError };
export type GetStatsResult = { 'ok' : UserStats } |
  { 'err' : null };
export type GetTeamOwnersRequest = { 'all' : null } |
  { 'team' : bigint };
export type GetTeamOwnersResult = { 'ok' : Array<UserVotingInfo> };
export type GetUserError = { 'notAuthorized' : null } |
  { 'notFound' : null };
export interface GetUserLeaderboardRequest {
  'count' : bigint,
  'offset' : bigint,
}
export type GetUserLeaderboardResult = { 'ok' : PagedResult };
export type GetUserResult = { 'ok' : User } |
  { 'err' : GetUserError };
export type OnSeasonEndError = { 'notAuthorized' : null };
export type OnSeasonEndResult = { 'ok' : null } |
  { 'err' : OnSeasonEndError };
export interface PagedResult {
  'data' : Array<User>,
  'count' : bigint,
  'offset' : bigint,
}
export type SetUserFavoriteTeamError = { 'notAuthorized' : null } |
  { 'alreadySet' : null } |
  { 'identityRequired' : null } |
  { 'teamNotFound' : null };
export type SetUserFavoriteTeamResult = { 'ok' : null } |
  { 'err' : SetUserFavoriteTeamError };
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
export interface UserVotingInfo {
  'id' : Principal,
  'votingPower' : bigint,
  'teamId' : bigint,
}
export interface Users {
  'addTeamOwner' : ActorMethod<[AddTeamOwnerRequest], AddTeamOwnerResult>,
  'awardPoints' : ActorMethod<[Array<AwardPointsRequest>], AwardPointsResult>,
  'get' : ActorMethod<[Principal], GetUserResult>,
  'getStats' : ActorMethod<[], GetStatsResult>,
  'getTeamOwners' : ActorMethod<[GetTeamOwnersRequest], GetTeamOwnersResult>,
  'getUserLeaderboard' : ActorMethod<
    [GetUserLeaderboardRequest],
    GetUserLeaderboardResult
  >,
  'onSeasonEnd' : ActorMethod<[], OnSeasonEndResult>,
  'setFavoriteTeam' : ActorMethod<
    [Principal, bigint],
    SetUserFavoriteTeamResult
  >,
}
export interface _SERVICE extends Users {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
