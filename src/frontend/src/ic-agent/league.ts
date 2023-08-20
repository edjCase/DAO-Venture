import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import { createActor } from './actor';

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



export const idlFactory = ({ IDL }) => {
  const CreateStadiumResult = IDL.Variant({ 'ok' : IDL.Principal });
  const CreateTeamResult = IDL.Variant({
    'ok' : IDL.Principal,
    'nameTaken' : IDL.Null,
  });
  const StadiumInfo = IDL.Record({ 'id' : IDL.Principal, 'name' : IDL.Text });
  const TeamInfo = IDL.Record({ 'id' : IDL.Principal, 'name' : IDL.Text });
  const Time = IDL.Int;
  const ScheduleMatchResult = IDL.Variant({
    'ok' : IDL.Null,
    'stadiumNotFound' : IDL.Null,
    'timeNotAvailable' : IDL.Null,
  });
  return IDL.Service({
    'createStadium' : IDL.Func([IDL.Text], [CreateStadiumResult], []),
    'createTeam' : IDL.Func([IDL.Text], [CreateTeamResult], []),
    'getStadiums' : IDL.Func([], [IDL.Vec(StadiumInfo)], ['query']),
    'getTeams' : IDL.Func([], [IDL.Vec(TeamInfo)], ['query']),
    'scheduleMatch' : IDL.Func(
        [IDL.Principal, IDL.Vec(IDL.Principal), Time],
        [ScheduleMatchResult],
        [],
      ),
    'updateLeagueCanisters' : IDL.Func([], [], []),
  });
};


const canisterId = process.env.CANISTER_ID_LEAGUE;
export const agent = createActor<_SERVICE>(canisterId, idlFactory, {});