import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import { createActor } from './Actor';


export type DayOfWeek = { 'monday': null } |
{ 'tuesday': null } |
{ 'wednesday': null } |
{ 'thursday': null } |
{ 'friday': null } |
{ 'saturday': null } |
{ 'sunday': null };
export type TimeOfDay = { 'hour': bigint; 'minute': bigint };
export type CreateDivisionRequest = {
  'name': string;
  'dayOfWeek': DayOfWeek;
  'timeZoneOffsetSeconds': number;
  'timeOfDay': TimeOfDay;
};
export type CreateDivisionResult = { 'ok': number } |
{ 'nameTaken': null };;
export type CreateStadiumRequest = { 'name': string };
export type CreateStadiumResult = { 'ok': Principal } | { 'nameTaken': null };
export type CreateTeamRequest = {
  'name': string;
  'logoUrl': string;
  'tokenName': string;
  'tokenSymbol': string;
  'divisionId': number;
};
export type CreateTeamResult = { 'ok': Principal } |
{ 'nameTaken': null };
export type ScheduleMatchResult = { 'ok': number } |
{ 'stadiumNotFound': null } |
{ 'timeNotAvailable': null };
export interface Stadium { 'id': Principal, 'name': string }
export interface Team { 'id': Principal, 'name': string, 'logoUrl': string }
export interface Division {
  'id': number,
  'name': string,
  'dayOfWeek': DayOfWeek,
  'timeZoneOffsetSeconds': number,
  'timeOfDay': TimeOfDay
};
export type Time = bigint;
export interface _SERVICE {
  'createStadium': ActorMethod<[CreateStadiumRequest], CreateStadiumResult>,
  'createTeam': ActorMethod<[CreateTeamRequest], CreateTeamResult>,
  'createDivision': ActorMethod<[CreateDivisionRequest], CreateDivisionResult>,
  'getStadiums': ActorMethod<[], Array<Stadium>>,
  'getTeams': ActorMethod<[], Array<Team>>,
  'getDivisions': ActorMethod<[], Array<Division>>,
  'scheduleMatch': ActorMethod<
    [Principal, [Principal, Principal], Time],
    ScheduleMatchResult
  >,
  'updateLeagueCanisters': ActorMethod<[], undefined>,
}



export const idlFactory = ({ IDL }) => {
  const DayOfWeek = IDL.Variant({
    'monday': IDL.Null,
    'tuesday': IDL.Null,
    'wednesday': IDL.Null,
    'thursday': IDL.Null,
    'friday': IDL.Null,
    'saturday': IDL.Null,
    'sunday': IDL.Null,
  });
  const TimeOfDay = IDL.Record({
    'hour': IDL.Nat,
    'minute': IDL.Nat,
  });
  const CreateDivisionRequest = IDL.Record({
    name: IDL.Text,
    dayOfWeek: DayOfWeek,
    timeZoneOffsetSeconds: IDL.Nat,
    timeOfDay: TimeOfDay
  });
  const CreateDivisionResult = IDL.Variant({
    'ok': IDL.Nat32,
    'nameTaken': IDL.Null,
  });
  const CreateStadiumRequest = IDL.Record({
    'name': IDL.Text
  });
  const CreateStadiumResult = IDL.Variant({
    'ok': IDL.Principal,
    'nameTaken': IDL.Null,
  });
  const CreateTeamRequest = IDL.Record({
    'name': IDL.Text,
    'logoUrl': IDL.Text,
    'tokenName': IDL.Text,
    'tokenSymbol': IDL.Text,
    'divisionId': IDL.Nat32
  });
  const CreateTeamResult = IDL.Variant({
    'ok': IDL.Principal,
    'nameTaken': IDL.Null,
  });
  const Stadium = IDL.Record({
    'id': IDL.Principal,
    'name': IDL.Text
  });
  const Team = IDL.Record({
    'id': IDL.Principal,
    'name': IDL.Text,
    'logoUrl': IDL.Text
  });
  const Division = IDL.Record({
    'id': IDL.Nat32,
    'name': IDL.Text,
    'dayOfWeek': DayOfWeek,
    'timeZoneOffsetSeconds': IDL.Nat,
    'timeOfDay': TimeOfDay
  });
  const Time = IDL.Int;
  const ScheduleMatchResult = IDL.Variant({
    'ok': IDL.Nat32,
    'duplicateTeams': IDL.Null,
    'timeNotAvailable': IDL.Null,
  });
  return IDL.Service({
    'createStadium': IDL.Func([CreateStadiumRequest], [CreateStadiumResult], []),
    'createTeam': IDL.Func([CreateTeamRequest], [CreateTeamResult], []),
    'createDivision': IDL.Func([CreateDivisionRequest], [CreateDivisionResult], []),
    'getStadiums': IDL.Func([], [IDL.Vec(Stadium)], ['query']),
    'getTeams': IDL.Func([], [IDL.Vec(Team)], ['query']),
    'getDivisions': IDL.Func([], [IDL.Vec(Division)], ['query']),
    'scheduleMatch': IDL.Func(
      [IDL.Principal, IDL.Tuple(IDL.Principal, IDL.Principal), Time],
      [ScheduleMatchResult],
      [],
    ),
    'updateLeagueCanisters': IDL.Func([], [], []),
  });
};


const canisterId = process.env.CANISTER_ID_LEAGUE;
// Keep factory due to changing identity
export let leagueAgentFactory = () => createActor<_SERVICE>(canisterId, idlFactory);

