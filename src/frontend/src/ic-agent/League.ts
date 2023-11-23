import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import { createActor } from './Actor';
import { InterfaceFactory } from '@dfinity/candid/lib/cjs/idl';
import { IDL } from "@dfinity/candid";
import {
  CompletedMatchState,
  CompletedMatchStateIdl,
  MatchAura,
  MatchAuraIdl,
  MatchAuraWithMetaData,
  MatchAuraWithMetaDataIdl,
  MatchTeam,
  MatchTeamIdl,
  Offering,
  OfferingIdl,
  OfferingWithMetaData,
  OfferingWithMetaDataIdl,
  ScheduleMatchError,
  ScheduleMatchErrorIdl,
} from './Stadium';


export type Time = bigint;
export const TimeIdl = IDL.Int;

export type Team = {
  'id': Principal;
  'ledgerId': Principal;
  'logoUrl': string;
  'name': string;
};
export const TeamIdl = IDL.Record({
  'id': IDL.Principal,
  'ledgerId': IDL.Principal,
  'logoUrl': IDL.Text,
  'name': IDL.Text
});


export type StartSeasonRequest = {
  'startTime': bigint
};
export const StartSeasonRequestIdl = IDL.Record({
  'startTime': TimeIdl
});



export type StartSeasonResult =
  | { 'ok': null }
  | { 'alreadyStarted': null }
  | { 'stadiumScheduleError': string }
  | { 'teamFetchError': string };
export const StartSeasonResultIdl = IDL.Variant({
  'ok': IDL.Null,
  'alreadyStarted': IDL.Null,
  'stadiumScheduleError': IDL.Text,
  'teamFetchError': IDL.Text
});


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

export type MatchSchedule = {
  'team1Id': Principal;
  'team2Id': Principal;
};
export const MatchScheduleIdl = IDL.Record({
  'team1Id': IDL.Principal,
  'team2Id': IDL.Principal
});

export type ScheduledMatch = {
  'offerings': Offering[];
  'matchAura': MatchAura;
};
export const ScheduledMatchIdl = IDL.Record({
  'offerings': IDL.Vec(OfferingIdl),
  'matchAura': MatchAuraIdl
});

export type ScheduledMatchGroupStatus = {
  'matches': ScheduledMatch[];
};
export const ScheduledMatchGroupStatusIdl = IDL.Record({
  'matches': IDL.Vec(ScheduledMatchIdl)
});

export type ScheduleMatchGroupError =
  | { 'teamFetchError': string }
  | { 'matchErrors': ScheduleMatchError[] }
  | { 'noMatchesSpecified': null }
  | { 'playerFetchError': string }
  | { 'stadiumScheduleCallError': string };
export const ScheduleMatchGroupErrorIdl = IDL.Variant({
  'teamFetchError': IDL.Text,
  'matchErrors': IDL.Vec(ScheduleMatchErrorIdl),
  'noMatchesSpecified': IDL.Null,
  'playerFetchError': IDL.Text,
  'stadiumScheduleCallError': IDL.Text,
});

export type InProgressMatch = {
  'team1': MatchTeam;
  'team2': MatchTeam;
  'offerings': [OfferingWithMetaData];
  'aura': MatchAuraWithMetaData;
  'stadiumId': Principal;
};
export const InProgressMatchIdl = IDL.Record({
  'team1': MatchTeamIdl,
  'team2': MatchTeamIdl,
  'offerings': IDL.Vec(OfferingWithMetaDataIdl),
  'aura': MatchAuraWithMetaDataIdl,
  'stadiumId': IDL.Principal,
});

export type CompletedMatch = {
  'team1': MatchTeam;
  'team2': MatchTeam;
  'offerings': [OfferingWithMetaData];
  'aura': MatchAuraWithMetaData;
  'state': CompletedMatchState;
};
export const CompletedMatchIdl = IDL.Record({
  'team1': MatchTeamIdl,
  'team2': MatchTeamIdl,
  'offerings': IDL.Vec(OfferingWithMetaDataIdl),
  'aura': MatchAuraWithMetaDataIdl,
  'state': CompletedMatchStateIdl,
});

export type StartedMatch =
  | { 'inProgress': InProgressMatch }
  | { 'completed': CompletedMatch };
export const StartedMatchIdl = IDL.Variant({
  'inProgress': InProgressMatchIdl,
  'completed': CompletedMatchIdl,
});

export type InProgressMatchGroupStatus = {
  'stadiumId': Principal,
  'matches': StartedMatch[];
};
export const InProgressMatchGroupStatusIdl = IDL.Record({
  'stadiumId': IDL.Principal,
  'matches': IDL.Vec(StartedMatchIdl)
});

export type PlayedMatchGroup = {
  matches: CompletedMatch[];
};
export const PlayedMatchGroupIdl = IDL.Record({
  'matches': IDL.Vec(CompletedMatchIdl)
});

export type CompletedMatchGroupStatus =
  | { 'played': PlayedMatchGroup }
  | { 'canceled': null }
  | { 'scheduleError': ScheduleMatchGroupError };
export const CompletedMatchGroupStatusIdl = IDL.Variant({
  'played': PlayedMatchGroupIdl,
  'canceled': IDL.Null,
  'scheduleError': ScheduleMatchGroupErrorIdl,
});

export type CompletedMatchGroup = {
  'id': number;
  'time': Time;
  'matches': MatchSchedule[];
  'status': CompletedMatchGroupStatus
};
export const CompletedMatchGroupIdl = IDL.Record({
  'id': IDL.Nat32,
  'time': TimeIdl,
  'matches': IDL.Vec(MatchScheduleIdl),
  'state': CompletedMatchGroupStatusIdl
});

export type MatchGroupScheduleStatus =
  | { 'notScheduled': null }
  | { 'scheduleError': ScheduleMatchGroupError }
  | { 'scheduled': ScheduledMatchGroup }
  | { 'inProgress': InProgressMatchGroupState }
  | { 'completed': CompletedMatchGroup };

export const MatchGroupScheduleStatusIdl = IDL.Variant({
  'notScheduled': IDL.Null,
  'scheduleError': ScheduleMatchGroupErrorIdl,
  'scheduled': ScheduledMatchGroupStateIdl,
  'inProgress': InProgressMatchGroupStateIdl,
  'completed': CompletedMatchGroupStateIdl,
});

export type MatchGroupSchedule = {
  'id': number;
  'time': Time;
  'matches': MatchSchedule[];
  'status': MatchGroupScheduleStatus;
};
export const MatchGroupScheduleIdl = IDL.Record({
  'id': IDL.Nat32,
  'time': TimeIdl,
  'matches': IDL.Vec(MatchScheduleIdl),
  'status': MatchGroupScheduleStatusIdl
});

export type CompletedTeam = {
  'id': Principal;
  'name': string;
  'logoUrl': string;
};
export const CompletedTeamIdl = IDL.Record({
  'id': IDL.Principal,
  'name': IDL.Text,
  'logoUrl': IDL.Text,
});


export type CompletedSeasonSchedule = {
  'teamStandings': Principal[]; // 1st to last place
  'teams': CompletedTeam[];
  'matchGroups': CompletedMatchGroup[];
};
export const CompletedSeasonScheduleIdl = IDL.Record({
  'teamStandings': IDL.Vec(IDL.Principal),
  'teams': IDL.Vec(CompletedTeamIdl),
  'matchGroups': IDL.Vec(CompletedMatchGroupIdl)
});





export type SeasonSchedule = {
  'matchGroups': MatchGroupSchedule[];
};
export const SeasonScheduleIdl = IDL.Record({
  'matchGroups': IDL.Vec(MatchGroupScheduleIdl),
});

export type SeasonStatus =
  | { 'notStarted': null }
  | { 'starting': null }
  | { 'inProgress': SeasonSchedule }
  | { 'completed': CompletedSeasonSchedule };
export const SeasonStatusIdl = IDL.Variant({
  'notStarted': IDL.Null,
  'starting': IDL.Null,
  'inProgress': SeasonScheduleIdl,
  'completed': CompletedSeasonScheduleIdl,
});


export interface _SERVICE {
  'getTeams': ActorMethod<[], Array<Team>>,
  'getSeasonStatus': ActorMethod<[], SeasonStatus>,
  'updateLeagueCanisters': ActorMethod<[], undefined>,
  'startSeason': ActorMethod<[StartSeasonRequest], StartSeasonResult>,
  'createTeam': ActorMethod<[CreateTeamRequest], CreateTeamResult>,
  'mint': ActorMethod<[MintRequest], MintResult>,
}



export const idlFactory: InterfaceFactory = ({ }) => {

  return IDL.Service({
    'getTeams': IDL.Func([], [IDL.Vec(TeamIdl)], ['query']),
    'getSeasonStatus': IDL.Func([], [SeasonStatusIdl], ['query']),
    'updateLeagueCanisters': IDL.Func([], [], []),
    'startSeason': IDL.Func([StartSeasonRequestIdl], [StartSeasonResultIdl], []),
    'createTeam': IDL.Func([CreateTeamRequestIdl], [CreateTeamResultIdl], []),
    'mint': IDL.Func([MintRequestIdl], [MintResultIdl], []),
  });
};


const canisterId = process.env.CANISTER_ID_LEAGUE || "";
// Keep factory due to changing identity
export let leagueAgentFactory = () => createActor<_SERVICE>(canisterId, idlFactory);

