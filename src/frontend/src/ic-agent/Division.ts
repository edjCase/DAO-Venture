import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import { createActor } from './Actor';
import { InterfaceFactory } from '@dfinity/candid/lib/cjs/idl';
import { IDL } from "@dfinity/candid";
import { Team, TeamIdl } from './League';

export type Time = bigint;
export const TimeIdl = IDL.Int;

export type CreateTeamRequest = {
    'name': string,
    'logoUrl': string,
    'tokenName': string,
    'tokenSymbol': string,
};
export const CreateTeamRequestIdl = IDL.Record({
    'name': IDL.Text,
    'logoUrl': IDL.Text,
    'tokenName': IDL.Text,
    'tokenSymbol': IDL.Text,
});

export type CreateTeamResult =
    | { 'ok': Principal }
    | { 'nameTaken': null };
export const CreateTeamResultIdl = IDL.Variant({
    'ok': IDL.Principal,
    'nameTaken': IDL.Null,
});

export type ScheduleSeasonRequest = {
    'startTime': Time,
};
export const ScheduleSeasonRequestIdl = IDL.Record({
    'startTime': TimeIdl,
});

export type ScheduleError =
    | { 'missingDivision': null }
    | { 'oddNumberOfTeams': null }
    | { 'divisionNotFound': null }
    | { 'alreadyScheduled': null }
    | { 'noTeamsInDivision': null };
export const ScheduleErrorIdl = IDL.Variant({
    'missingDivision': IDL.Null,
    'oddNumberOfTeams': IDL.Null,
    'divisionNotFound': IDL.Null,
    'alreadyScheduled': IDL.Null,
    'noTeamsInDivision': IDL.Null,
});

export type ScheduleSeasonResult =
    | { 'ok': null }
    | { 'divisionErrors': ScheduleError[] };
export const ScheduleSeasonResultIdl = IDL.Variant({
    'ok': IDL.Null,
    'divisionErrors': IDL.Vec(ScheduleErrorIdl),
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
    'getTeams': ActorMethod<[], [Team]>,
    'createTeam': ActorMethod<[CreateTeamRequest], CreateTeamResult>,
    'scheduleSeason': ActorMethod<[ScheduleSeasonRequest], ScheduleSeasonResult>,
    'mint': ActorMethod<[MintRequest], MintResult>,
    'updateDivisionCanisters': ActorMethod<[], []>,
}



export const idlFactory: InterfaceFactory = ({ }) => {

    return IDL.Service({
        'getTeams': IDL.Func([], [IDL.Vec(TeamIdl)], ['query']),
        'createTeam': IDL.Func([CreateTeamRequestIdl], [CreateTeamResultIdl], []),
        'scheduleSeason': IDL.Func([ScheduleSeasonRequestIdl], [ScheduleSeasonResultIdl], []),
        'mint': IDL.Func([MintRequestIdl], [MintResultIdl], []),
        'updateDivisionCanisters': IDL.Func([], [], []),
    });
};


// Keep factory due to changing identity
export let divisionAgentFactory = (divisionId: Principal) => createActor<_SERVICE>(divisionId, idlFactory);

