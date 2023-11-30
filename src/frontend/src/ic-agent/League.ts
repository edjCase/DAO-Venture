import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import { createActor } from './Actor';
import { InterfaceFactory, Nat } from '@dfinity/candid/lib/cjs/idl';
import { IDL } from "@dfinity/candid";
import { LogEntry, LogEntryIdl, SeasonStatus, SeasonStatusIdl } from '../models/Season';
import { Offering, OfferingIdl } from '../models/Offering';
import { MatchAura, MatchAuraIdl } from '../models/MatchAura';
import { Player, PlayerIdl } from './PlayerLedger';
import { TeamId, TeamIdIdl, TeamIdOrTie, TeamIdOrTieIdl, Team, TeamIdl } from '../models/Team';
export type Time = bigint;
export const TimeIdl = IDL.Int;
export type Nat = bigint;
export type Nat32 = number;
export type Nat64 = number;
export type Int = number;
export type Bool = boolean;
export type Text = string;

export type OnMatchGroupStartRequest = {
  id: Nat;
};
export const OnMatchGroupStartRequestIdl = IDL.Record({
  id: IDL.Nat,
});

export type OnMatchGroupStartError =
  | { notAuthorized: null }
  | { matchGroupNotFound: null }
  | { notScheduledYet: null }
  | { alreadyStarted: null };
export const OnMatchGroupStartErrorIdl = IDL.Variant({
  notAuthorized: IDL.Null,
  matchGroupNotFound: IDL.Null,
  notScheduledYet: IDL.Null,
  alreadyStarted: IDL.Null,
});

export type TeamStartData = {
  offering: Offering;
  championId: Nat32;
  players: Player[];
};
export const TeamStartDataIdl = IDL.Record({
  offering: OfferingIdl,
  championId: IDL.Nat32,
  players: IDL.Vec(PlayerIdl),
});

export type MatchStartData = {
  team1: TeamStartData;
  team2: TeamStartData;
  aura: MatchAura;
};
export const MatchStartDataIdl = IDL.Record({
  team1: TeamStartDataIdl,
  team2: TeamStartDataIdl,
  aura: MatchAuraIdl,
});

export type MatchStartOrSkipData =
  | { start: MatchStartData }
  | { absentTeam: TeamId }
  | { allAbsent: null };
export const MatchStartOrSkipDataIdl = IDL.Variant({
  start: MatchStartDataIdl,
  absentTeam: TeamIdIdl,
  allAbsent: IDL.Null,
});

export type MatchGroupStartData = {
  matches: MatchStartOrSkipData[];
};
export const MatchGroupStartDataIdl = IDL.Record({
  matches: IDL.Vec(MatchStartOrSkipDataIdl),
});

export type StartSeasonRequest = {
  startTime: Time;
};
export const StartSeasonRequestIdl = IDL.Record({
  startTime: TimeIdl,
});

export type StartSeasonResult =
  | { ok: null }
  | { alreadyStarted: null }
  | { noStadiumsExist: null }
  | { seedGenerationError: Text }
  | { noTeams: null }
  | { oddNumberOfTeams: null };
export const StartSeasonResultIdl = IDL.Variant({
  ok: IDL.Null,
  alreadyStarted: IDL.Null,
  noStadiumsExist: IDL.Null,
  seedGenerationError: IDL.Text,
  noTeams: IDL.Null,
  oddNumberOfTeams: IDL.Null,
});

export type CloseSeasonResult =
  | { ok: null }
  | { seasonInProgress: null }
  | { notAuthorized: null }
  | { seasonNotOpen: null };
export const CloseSeasonResultIdl = IDL.Variant({
  ok: IDL.Null,
  seasonInProgress: IDL.Null,
  notAuthorized: IDL.Null,
  seasonNotOpen: IDL.Null,
});


export type PlayedMatchState = {
  team1Score: Int;
  team2Score: Int;
  winner: TeamIdOrTie;
  log: LogEntry[];
};
export const PlayedMatchStateIdl = IDL.Record({
  team1Score: IDL.Int,
  team2Score: IDL.Int,
  winner: TeamIdOrTieIdl,
  log: IDL.Vec(LogEntryIdl),
});

export type FailedMatchState = {
  message: Text;
  log: LogEntry[];
};
export const FailedMatchStateIdl = IDL.Record({
  message: IDL.Text,
  log: IDL.Vec(LogEntryIdl),
});

export type CompletedMatch =
  | { absentTeam: TeamId }
  | { allAbsent: null }
  | { played: PlayedMatchState }
  | { failed: FailedMatchState };
export const CompletedMatchIdl = IDL.Variant({
  absentTeam: TeamIdIdl,
  allAbsent: IDL.Null,
  played: PlayedMatchStateIdl,
  failed: FailedMatchStateIdl,
});

export type OnMatchGroupCompleteRequest = {
  id: Nat;
  matches: CompletedMatch[];
};
export const OnMatchGroupCompleteRequestIdl = IDL.Record({
  id: IDL.Nat,
  matches: IDL.Vec(CompletedMatchIdl),
});

export type OnMatchGroupCompleteResult =
  | { ok: null }
  | { seasonNotOpen: null }
  | { matchGroupNotFound: null }
  | { matchGroupNotInProgress: null }
  | { seedGenerationError: Text }
  | { notAuthorized: null };
export const OnMatchGroupCompleteResultIdl = IDL.Variant({
  ok: IDL.Null,
  seasonNotOpen: IDL.Null,
  matchGroupNotFound: IDL.Null,
  matchGroupNotInProgress: IDL.Null,
  seedGenerationError: IDL.Text,
  notAuthorized: IDL.Null,
});

export type CreateTeamRequest = {
  name: Text;
  logoUrl: Text;
  tokenName: Text;
  tokenSymbol: Text;
};
export const CreateTeamRequestIdl = IDL.Record({
  name: IDL.Text,
  logoUrl: IDL.Text,
  tokenName: IDL.Text,
  tokenSymbol: IDL.Text,
});

export type CreateTeamResult =
  | { ok: Principal }
  | { nameTaken: null }
  | { noStadiumsExist: null };
export const CreateTeamResultIdl = IDL.Variant({
  ok: IDL.Principal,
  nameTaken: IDL.Null,
  noStadiumsExist: IDL.Null,
});

export type MintRequest = {
  amount: Nat;
  teamId: Principal;
};
export const MintRequestIdl = IDL.Record({
  amount: IDL.Nat,
  teamId: IDL.Principal,
});

export type TimeError =
  | { TooOld: null }
  | { CreatedInFuture: { ledger_time: Nat64 } };
export const TimeErrorIdl = IDL.Variant({
  TooOld: IDL.Null,
  CreatedInFuture: IDL.Record({ ledger_time: IDL.Nat64 }),
});

export type TransferError =
  | TimeError
  | { BadFee: { expected_fee: Nat } }
  | { BadBurn: { min_burn_amount: Nat } }
  | { InsufficientFunds: { balance: Nat } }
  | { Duplicate: { duplicate_of: Nat } }
  | { TemporarilyUnavailable: null }
  | { GenericError: { error_code: Nat; message: Text } };
export const TransferErrorIdl = IDL.Variant({
  TooOld: IDL.Null,
  CreatedInFuture: IDL.Record({ ledger_time: IDL.Nat64 }),
  BadFee: IDL.Record({ expected_fee: IDL.Nat }),
  BadBurn: IDL.Record({ min_burn_amount: IDL.Nat }),
  InsufficientFunds: IDL.Record({ balance: IDL.Nat }),
  Duplicate: IDL.Record({ duplicate_of: IDL.Nat }),
  TemporarilyUnavailable: IDL.Null,
  GenericError: IDL.Record({ error_code: IDL.Nat, message: IDL.Text }),
});

export type MintResult =
  | { ok: Nat }
  | { teamNotFound: null }
  | { transferError: TransferError };
export const MintResultIdl = IDL.Variant({
  ok: IDL.Nat,
  teamNotFound: IDL.Null,
  transferError: TransferErrorIdl,
});

export type OnMatchGroupStartResult =
  | OnMatchGroupStartError
  | { ok: MatchGroupStartData };
export const OnMatchGroupStartResultIdl = IDL.Variant({
  notAuthorized: IDL.Null,
  matchGroupNotFound: IDL.Null,
  notScheduledYet: IDL.Null,
  alreadyStarted: IDL.Null,
  ok: MatchGroupStartDataIdl,
});


export interface _SERVICE {
  'getTeams': ActorMethod<[], Array<Team>>,
  'getSeasonStatus': ActorMethod<[], SeasonStatus>,
  'startSeason': ActorMethod<[StartSeasonRequest], StartSeasonResult>,
  'closeSeason': ActorMethod<[], CloseSeasonResult>,
  'createTeam': ActorMethod<[CreateTeamRequest], CreateTeamResult>,
  'mint': ActorMethod<[MintRequest], MintResult>,
  'updateLeagueCanisters': ActorMethod<[], undefined>,
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

