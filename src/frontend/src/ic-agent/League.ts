import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import { createActor } from './Actor';
import { InterfaceFactory } from '@dfinity/candid/lib/cjs/idl';
import { IDL } from "@dfinity/candid";
import { ScheduleDivisionErrorResult, ScheduleDivisionErrorResultIdl, ScheduleMatchGroupErrorIdl, SeasonSchedule, SeasonScheduleIdl, ScheduleDivisionError as StadiumScheduleDivisionError } from './Stadium';


export type Time = bigint;
export const TimeIdl = IDL.Int;

export type Team = {
  'divisionId': number;
  'id': Principal;
  'ledgerId': Principal;
  'logoUrl': string;
  'name': string;
};
export const TeamIdl = IDL.Record({
  'divisionId': IDL.Nat32,
  'id': IDL.Principal,
  'ledgerId': IDL.Principal,
  'logoUrl': IDL.Text,
  'name': IDL.Text
});

export type DivisionScheduleRequest = {
  'id': number;
  'startTime': Time;
};
export const DivisionScheduleRequestIdl = IDL.Record({
  'id': IDL.Nat32,
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
  'id': number;
  'name': string;
};
export const DivisionIdl = IDL.Record({
  'id': IDL.Nat32,
  'name': IDL.Text
});


export type CreateDivisionResult = {
  'ok': number
} | {
  'nameTake': null
} | {
  'noStadiumsExist': null
};
export const CreateDivisionResultIdl = IDL.Variant({
  'ok': IDL.Nat32,
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


export type CreateTeamRequest = {
  'name': string,
  'logoUrl': string,
  'tokenName': string,
  'tokenSymbol': string,
  'divisionId': number,
};
export const CreateTeamRequestIdl = IDL.Record({
  'name': IDL.Text,
  'logoUrl': IDL.Text,
  'tokenName': IDL.Text,
  'tokenSymbol': IDL.Text,
  'divisionId': IDL.Nat32,
});

export type CreateTeamResult =
  | { 'ok': Principal }
  | { 'nameTaken': null }
  | { 'divisionNotFound': null };
export const CreateTeamResultIdl = IDL.Variant({
  'ok': IDL.Principal,
  'nameTaken': IDL.Null,
  'divisionNotFound': IDL.Null,
});

export type MintRequest = {
  'amount': bigint,
  'teamId': Principal,
};
export const MintRequestIdl = IDL.Record({
  'amount': IDL.Nat,
  'teamId': IDL.Principal,
});

export type TransferError =
  | { 'insufficientBalance': null }
  | { 'transferFailed': null };
export const TransferErrorIdl = IDL.Variant({
  'insufficientBalance': IDL.Null,
  'transferFailed': IDL.Null,
});

export type MintResult =
  | { 'ok': bigint }
  | { 'teamNotFound': null }
  | { 'transferError': TransferError };
export const MintResultIdl = IDL.Variant({
  'ok': IDL.Nat,
  'teamNotFound': IDL.Null,
  'transferError': TransferErrorIdl,
});



export interface _SERVICE {
  'createStadium': ActorMethod<[], CreateStadiumResult>,
  'getStadiums': ActorMethod<[], Array<Stadium>>,
  'createDivision': ActorMethod<[CreateDivisionRequest], CreateDivisionResult>,
  'getTeams': ActorMethod<[], Array<Team>>,
  'getDivisions': ActorMethod<[], Array<Division>>,
  'getSeasonSchedule': ActorMethod<[], [] | [SeasonSchedule]>,
  'updateLeagueCanisters': ActorMethod<[], undefined>,
  'scheduleSeason': ActorMethod<[ScheduleSeasonRequest], ScheduleSeasonResult>,
  'createTeam': ActorMethod<[CreateTeamRequest], CreateTeamResult>,
  'mint': ActorMethod<[MintRequest], MintResult>,
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
    'scheduleSeason': IDL.Func([ScheduleSeasonRequestIdl], [ScheduleSeasonResultIdl], []),
    'createTeam': IDL.Func([CreateTeamRequestIdl], [CreateTeamResultIdl], []),
    'mint': IDL.Func([MintRequestIdl], [MintResultIdl], []),
  });
};


const canisterId = process.env.CANISTER_ID_LEAGUE || "";
// Keep factory due to changing identity
export let leagueAgentFactory = () => createActor<_SERVICE>(canisterId, idlFactory);

