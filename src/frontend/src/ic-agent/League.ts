import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import { createActor } from './Actor';
import { InterfaceFactory } from '@dfinity/candid/lib/cjs/idl';
import { IDL } from "@dfinity/candid";
import { CompletedMatchGroupState, CompletedMatchGroupStateIdl, MatchAura, MatchAuraIdl, Offering, OfferingIdl } from './Stadium';


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

export type StartSeasonRequest = {
  'divisions': DivisionScheduleRequest[];
};
export const StartSeasonRequestIdl = IDL.Record({
  'divisions': IDL.Vec(DivisionScheduleRequestIdl)
});

export type StartDivisionSeasonError =
  | { 'divisionNotFound': null }
  | { 'noMatchGroupSpecified': null }
  | { 'noTeamsInDivision': null }
  | { 'oddNumberOfTeams': null }
export const ScheduleDivisionErrorIdl = IDL.Variant({
  'divisionNotFound': IDL.Null,
  'noMatchGroupsSpecified': IDL.Null,
  'noTeamsInDivision': IDL.Null,
  'oddNumberOfTeams': IDL.Null
});

export type StartDivisionSeasonErrorResult = {
  id: number;
  error: StartDivisionSeasonError;
};
export const StartDivisionErrorResultIdl = IDL.Record({
  'id': IDL.Nat32,
  'error': ScheduleDivisionErrorIdl
});


export type StartSeasonResult =
  | { 'ok': null }
  | { 'divisionErrors': StartDivisionSeasonErrorResult[] }
  | { 'noDivisionSpecified': null }
  | { 'alreadyStarted': null }
  | { 'noStadiumsExist': null }
  | { 'stadiumScheduleError': string }
  | { 'teamFetchError': string };
export const StartSeasonResultIdl = IDL.Variant({
  'ok': IDL.Null,
  'divisionErrors': IDL.Vec(StartDivisionErrorResultIdl),
  'noDivisionSpecified': IDL.Null,
  'alreadyStarted': IDL.Null,
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

export type DivisionSchedule = {
  'id': number;
  'matchGroupIds': number[];
};
export const DivisionScheduleIdl = IDL.Record({
  'id': IDL.Nat32,
  'matchGroupIds': IDL.Vec(IDL.Nat32)
});

export type MatchSchedule = {
  'team1Id': Principal;
  'team2Id': Principal;
};
export const MatchScheduleIdl = IDL.Record({
  'team1Id': IDL.Principal,
  'team2Id': IDL.Principal
});

export type OpenMatchScheduleStatus = {
  'offerings': Offering[];
  'matchAura': MatchAura;
};
export const OpenMatchScheduleStatusIdl = IDL.Record({
  'offerings': IDL.Vec(OfferingIdl),
  'matchAura': MatchAuraIdl
});

export type OpenMatchGroupScheduleStatus = {
  'matches': OpenMatchScheduleStatus[];
};
export const OpenMatchGroupScheduleStatusIdl = IDL.Record({
  'matches': IDL.Vec(OpenMatchScheduleStatusIdl)
});


export type MatchGroupScheduleStatus = {
  'notOpen': null;
  'open': OpenMatchGroupScheduleStatus;
  'completed': CompletedMatchGroupState;
};
export const MatchGroupScheduleStatusIdl = IDL.Variant({
  'notOpen': IDL.Null,
  'open': OpenMatchGroupScheduleStatusIdl,
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

export type SeasonSchedule = {
  'divisions': DivisionSchedule[];
  'matchGroups': MatchGroupSchedule[];
};
export const SeasonScheduleIdl = IDL.Record({
  'divisions': IDL.Vec(DivisionScheduleIdl),
  'matchGroups': IDL.Vec(MatchGroupScheduleIdl),
});

// public type MatchGroupSchedule = {
//   id : Nat32;
//   time : Time.Time;
//   matches : [MatchSchedule];
//   status : MatchGroupScheduleStatus;
// };
// public type MatchGroupScheduleWithId = MatchGroupSchedule and {
//   id : Nat32;
// };

// public type MatchGroupScheduleStatus = {
//   #notOpen;
//   #open : OpenMatchGroupScheduleStatus;
//   #completed : Stadium.CompletedMatchGroupState;
// };

// public type OpenMatchGroupScheduleStatus = {
//   matches : [OpenMatchScheduleStatus];
// };

// public type OpenMatchScheduleStatus = {
//   offerings : [Stadium.Offering];
//   matchAura : Stadium.MatchAura;
// };

// public type MatchSchedule = {
//   team1Id : Principal;
//   team2Id : Principal;
// };

// public type StartDivisionSeasonRequest = {
//   id : Nat32;
//   startTime : Time.Time;
// };

// public type StartSeasonRequest = {
//   divisions : [StartDivisionSeasonRequest];
// };

// public type StartDivisionSeasionErrorResult = {
//   id : Nat32;
//   error : StartDivisionSeasonError;
// };

// public type StartSeasonResult = {
//   #ok;
//   #divisionErrors : [StartDivisionSeasonErrorResult];
//   #noDivisionSpecified;
//   #alreadyStarted;
//   #noStadiumsExist;
//   #stadiumScheduleError : Stadium.ScheduleMatchGroupsError or {
//       #unknown : Text;
//   };
// };

// public type StartDivisionSeasonError = {
//   #divisionNotFound;
//   #noMatchGroupSpecified;
//   #oddNumberOfTeams;
//   #noTeamsInDivision;
// };
// public type StartDivisionSeasonErrorResult = {
//   id : Nat32;
//   error : StartDivisionSeasonError;
// };



export interface _SERVICE {
  'createStadium': ActorMethod<[], CreateStadiumResult>,
  'getStadiums': ActorMethod<[], Array<Stadium>>,
  'createDivision': ActorMethod<[CreateDivisionRequest], CreateDivisionResult>,
  'getTeams': ActorMethod<[], Array<Team>>,
  'getDivisions': ActorMethod<[], Array<Division>>,
  'getSeasonSchedule': ActorMethod<[], [] | [SeasonSchedule]>,
  'updateLeagueCanisters': ActorMethod<[], undefined>,
  'startSeason': ActorMethod<[StartSeasonRequest], StartSeasonResult>,
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
    'startSeason': IDL.Func([StartSeasonRequestIdl], [StartSeasonResultIdl], []),
    'createTeam': IDL.Func([CreateTeamRequestIdl], [CreateTeamResultIdl], []),
    'mint': IDL.Func([MintRequestIdl], [MintResultIdl], []),
  });
};


const canisterId = process.env.CANISTER_ID_LEAGUE || "";
// Keep factory due to changing identity
export let leagueAgentFactory = () => createActor<_SERVICE>(canisterId, idlFactory);

