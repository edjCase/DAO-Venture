import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export type CreateStadiumResult = { 'ok' : Principal };
export type CreateTeamResult = { 'ok' : Principal } |
  { 'nameTaken' : null };
export type ScheduleMatchResult = { 'ok' : null } |
  { 'stadiumNotFound' : null } |
  { 'timeNotAvailable' : null };
export interface StadiumInfo { 'id' : Principal, 'name' : string }
export interface TeamInfo { 'id' : Principal, 'name' : string }
export type Time = bigint;
export interface _SERVICE {
  'createStadium' : ActorMethod<[string], CreateStadiumResult>,
  'createTeam' : ActorMethod<[string], CreateTeamResult>,
  'getStadiums' : ActorMethod<[], Array<StadiumInfo>>,
  'getTeams' : ActorMethod<[], Array<TeamInfo>>,
  'scheduleMatch' : ActorMethod<
    [Principal, Array<Principal>, Time],
    ScheduleMatchResult
  >,
  'updateLeagueCanisters' : ActorMethod<[], undefined>,
}
