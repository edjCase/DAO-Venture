import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import { createActor } from './Actor';
import { InterfaceFactory } from '@dfinity/candid/lib/cjs/idl';
import { IDL } from "@dfinity/candid";
import { ScheduleDivisionErrorResult, ScheduleDivisionErrorResultIdl, ScheduleMatchGroupErrorIdl, SeasonSchedule, SeasonScheduleIdl, ScheduleDivisionError as StadiumScheduleDivisionError } from './Stadium';


export type Time = bigint;
export const TimeIdl = IDL.Int;

export type Team = {
  'divisionId': Principal;
  'id': Principal;
  'ledgerId': Principal;
  'logoUrl': string;
  'name': string;
};
export const TeamIdl = IDL.Record({
  'divisionId': IDL.Principal,
  'id': IDL.Principal,
  'ledgerId': IDL.Principal,
  'logoUrl': IDL.Text,
  'name': IDL.Text
});

export type DivisionScheduleRequest = {
  'id': Principal;
  'startTime': Time;
};
export const DivisionScheduleRequestIdl = IDL.Record({
  'id': IDL.Principal,
  'startTime': TimeIdl
});

export type ScheduleSeasonRequest = {
  'divisions': DivisionScheduleRequest[];
};
export const ScheduleSeasonRequestIdl = IDL.Record({
  'divisions': IDL.Vec(DivisionScheduleRequestIdl)
});

export type ScheduleDivisionError =
  | StadiumScheduleDivisionError
  | { 'noTeamsInDivision': null }
  | { 'oddNumberOfTeams': null }
export const ScheduleDivisionErrorIdl = IDL.Variant({
  'divisionNotFound': IDL.Null,
  'teamFetchError': IDL.Text,
  'playerFetchError': IDL.Text,
  'matchGroupErrors': IDL.Vec(ScheduleMatchGroupErrorIdl),
  'noMatchGroupsSpecified': IDL.Null,
  'noTeamsInDivision': IDL.Null,
  'oddNumberOfTeams': IDL.Null
});


export type ScheduleSeasonResult =
  | { 'ok': null }
  | { 'divisionErrors': ScheduleDivisionErrorResult[] }
  | { 'noDivisionSpecified': null }
  | { 'alreadyScheduled': null }
  | { 'noStadiumsExist': null }
  | { 'stadiumScheduleError': string }
  | { 'teamFetchError': string };
export const ScheduleSeasonResultIdl = IDL.Variant({
  'ok': IDL.Null,
  'divisionErrors': IDL.Vec(ScheduleDivisionErrorResultIdl),
  'noDivisionSpecified': IDL.Null,
  'alreadyScheduled': IDL.Null,
  'noStadiumsExist': IDL.Null,
  'stadiumScheduleError': IDL.Text,
  'teamFetchError': IDL.Text
});


export type Division = {
  'id': Principal;
  'name': string;
};
export const DivisionIdl = IDL.Record({
  'id': IDL.Principal,
  'name': IDL.Text
});


export type CreateDivisionResult = {
  'ok': Principal
} | {
  'nameTake': null
} | {
  'noStadiumsExist': null
};
export const CreateDivisionResultIdl = IDL.Variant({
  'ok': IDL.Principal,
  'nameTaken': IDL.Null,
  'noStadiumsExist': IDL.Null,
});

export type CreateDivisionRequest = {
  'name': string;
};
export const CreateDivisionRequestIdl = IDL.Record({
  name: IDL.Text
});

export type Stadium = {
  id: Principal;
};
const Stadium = IDL.Record({
  'id': IDL.Principal
});

export type CreateStadiumResult =
  | { 'ok': Principal }
  | { 'alreadyCreated': null }
  | { 'stadiumCreationError': string; };
export const CreateStadiumResultIdl = IDL.Variant({
  'ok': IDL.Principal,
  'alreadyCreated': IDL.Null,
  'stadiumCreationError': IDL.Text
});



export interface _SERVICE {
  'createStadium': ActorMethod<[], CreateStadiumResult>,
  'getStadiums': ActorMethod<[], Array<Stadium>>,
  'createDivision': ActorMethod<[CreateDivisionRequest], CreateDivisionResult>,
  'getTeams': ActorMethod<[], Array<Team>>,
  'getDivisions': ActorMethod<[], Array<Division>>,
  'getSeasonSchedule': ActorMethod<[], [] | [SeasonSchedule]>,
  'updateLeagueCanisters': ActorMethod<[], undefined>,
  'scheduleSeason': ActorMethod<[ScheduleSeasonRequest], ScheduleSeasonResult>
}



export const idlFactory: InterfaceFactory = ({ }) => {

  return IDL.Service({
    'createStadium': IDL.Func([], [CreateStadiumResultIdl], []),
    'getStadiums': IDL.Func([], [IDL.Vec(Stadium)], ['query']),
    'createDivision': IDL.Func([CreateDivisionRequestIdl], [CreateDivisionResultIdl], []),
    'getTeams': IDL.Func([], [IDL.Vec(TeamIdl)], ['query']),
    'getDivisions': IDL.Func([], [IDL.Vec(DivisionIdl)], ['query']),
    'getSeasonSchedule': IDL.Func([], [IDL.Opt(SeasonScheduleIdl)], ['query']),
    'updateLeagueCanisters': IDL.Func([], [], []),
    'scheduleSeason': IDL.Func([ScheduleSeasonRequestIdl], [ScheduleSeasonResultIdl], [])
  });
};


const canisterId = process.env.CANISTER_ID_LEAGUE || "";
// Keep factory due to changing identity
export let leagueAgentFactory = () => createActor<_SERVICE>(canisterId, idlFactory);

