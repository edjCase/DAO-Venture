import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import { createActor } from './Actor';
import { InterfaceFactory } from '@dfinity/candid/lib/cjs/idl';


export type CreateDivisionRequest = {
  'name': string;
};
export type CreateDivisionResult = { 'ok': number } |
{ 'nameTaken': null };

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
export type MatchSchedulingError = { 'duplicateTeams': null } |
{ 'timeNotAvailable': null } |
{ 'unknown': string };
export type MatchUpStatus = { 'scheduled': number } |
{ 'failedToSchedule': MatchSchedulingError };
export interface MatchUp {
  'status': MatchUpStatus;
  'stadiumId': Principal;
  'team1': Principal;
  'team2': Principal;
};
export interface SeasonWeek {
  'matchUps': MatchUp[]
};
export interface DivisionSchedule {
  'weeks': SeasonWeek[]
};
export interface Division {
  'id': number,
  'name': string,
  'schedule': [DivisionSchedule] | []
};
export type Time = bigint;
export type ScheduleSeasonResult = { 'ok': null } |
{ 'divisionErrors': [number, DivisionScheduleError][] };
export type DivisionScheduleError = { 'missingDivision': null } |
{ 'oddNumberOfTeams': null } |
{ 'noTeamsInDivision': null } |
{ 'notEnoughStadiums': null } |
{ 'divisionNotFound': null } |
{ 'alreadyScheduled': null };
export type DivisionScheduleRequest = { 'id': number, 'start': Time };
export type ScheduleSeasonRequest = { 'divisions': DivisionScheduleRequest[] };
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
  'scheduleSeason': ActorMethod<[ScheduleSeasonRequest], ScheduleSeasonResult>,
}



export const idlFactory: InterfaceFactory = ({ IDL }) => {
  const CreateDivisionRequest = IDL.Record({
    name: IDL.Text
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

  const MatchSchedulingError = IDL.Variant({
    'duplicateTeams': IDL.Null,
    'timeNotAvailable': IDL.Null,
    'unknown': IDL.Text
  });
  const MatchUpStatus = IDL.Variant({
    'scheduled': IDL.Nat32,
    'failedToSchedule': MatchSchedulingError
  });
  const MatchUp = IDL.Record({
    'status': MatchUpStatus,
    'stadiumId': IDL.Principal,
    'team1': IDL.Principal,
    'team2': IDL.Principal
  });
  const SeasonWeek = IDL.Record({
    'matchUps': IDL.Vec(MatchUp)
  });
  const DivisionSchedule = IDL.Record({
    'weeks': IDL.Vec(SeasonWeek)
  });
  const Division = IDL.Record({
    'id': IDL.Nat32,
    'name': IDL.Text,
    'schedule': IDL.Opt(DivisionSchedule)
  });
  const Time = IDL.Int;
  const ScheduleMatchResult = IDL.Variant({
    'ok': IDL.Nat32,
    'duplicateTeams': IDL.Null,
    'timeNotAvailable': IDL.Null,
  });
  const DivisionScheduleRequest = IDL.Record({
    'id': IDL.Nat32,
    'start': Time
  });
  const ScheduleSeasonRequest = IDL.Record({
    'divisions': IDL.Vec(DivisionScheduleRequest)
  });
  const DivisionScheduleError = IDL.Variant({
    'missingDivision': IDL.Null,
    'divisionNotFound': IDL.Null,
    'oddNumberOfTeams': IDL.Null,
    'noTeamsInDivision': IDL.Null,
    'notEnoughStadiums': IDL.Null,
    'alreadyScheduled': IDL.Null,
  });
  const ScheduleSeasonResult = IDL.Variant({
    'ok': IDL.Null,
    'divisionErrors': IDL.Vec(IDL.Tuple(IDL.Nat32, DivisionScheduleError))
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
    'scheduleSeason': IDL.Func([ScheduleSeasonRequest], [ScheduleSeasonResult], []),
  });
};


const canisterId = process.env.CANISTER_ID_LEAGUE || "";
// Keep factory due to changing identity
export let leagueAgentFactory = () => createActor<_SERVICE>(canisterId, idlFactory);

