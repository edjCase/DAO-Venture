import type { Principal } from '@dfinity/principal';
import { IDL } from "@dfinity/candid";
import { Offering, OfferingIdl, OfferingWithMetaData, OfferingWithMetaDataIdl } from "../models/Offering";
import { MatchAura, MatchAuraIdl, MatchAuraWithMetaData, MatchAuraWithMetaDataIdl } from "../models/MatchAura";
import { TeamId, TeamIdIdl, TeamIdOrTie, TeamIdOrTieIdl } from "../models/Team";
import { ActorMethod } from '@dfinity/agent';
import { InterfaceFactory } from '@dfinity/candid/lib/cjs/idl';
import { createActor } from './Actor';
import { FieldPosition, FieldPositionIdl, PlayerSkills, PlayerSkillsIdl } from './PlayerLedger';
import { PlayerCondition, PlayerConditionIdl } from '../models/Player';

export type Nat = bigint;
export type Int = bigint;
export type Bool = boolean;
export type Text = string;
export type PlayerId = number;
export const PlayerIdIdl = IDL.Nat32;


export type ResetTickTimerResult =
  | { ok: null }
  | { matchGroupNotFound: null }
  | { matchGroupNotStarted: null }
  | { matchGroupComplete: null };
export const ResetTickTimerResultIdl = IDL.Variant({
  ok: IDL.Null,
  matchGroupNotFound: IDL.Null,
  matchGroupNotStarted: IDL.Null,
  matchGroupComplete: IDL.Null,
});

export type Team = {
  id: Principal;
  name: Text;
  logoUrl: Text;
  score: Int;
  offering: Offering;
  championId: PlayerId;
};
export const TeamIdl = IDL.Record({
  id: IDL.Principal,
  name: IDL.Text,
  logoUrl: IDL.Text,
  score: IDL.Int,
  offering: OfferingIdl,
  championId: PlayerIdIdl,
});


export type DefenseFieldState = {
  firstBase: PlayerId;
  secondBase: PlayerId;
  thirdBase: PlayerId;
  shortStop: PlayerId;
  pitcher: PlayerId;
  leftField: PlayerId;
  centerField: PlayerId;
  rightField: PlayerId;
};
export const DefenseFieldStateIdl = IDL.Record({
  firstBase: PlayerIdIdl,
  secondBase: PlayerIdIdl,
  thirdBase: PlayerIdIdl,
  shortStop: PlayerIdIdl,
  pitcher: PlayerIdIdl,
  leftField: PlayerIdIdl,
  centerField: PlayerIdIdl,
  rightField: PlayerIdIdl,
});

export type OffenseFieldState = {
  atBat: PlayerId;
  firstBase: [PlayerId] | [];
  secondBase: [PlayerId] | [];
  thirdBase: [PlayerId] | [];
};
export const OffenseFieldStateIdl = IDL.Record({
  atBat: PlayerIdIdl,
  firstBase: IDL.Opt(PlayerIdIdl),
  secondBase: IDL.Opt(PlayerIdIdl),
  thirdBase: IDL.Opt(PlayerIdIdl),
});

export type FieldState = {
  defense: DefenseFieldState;
  offense: OffenseFieldState;
};
export const FieldStateIdl = IDL.Record({
  defense: DefenseFieldStateIdl,
  offense: OffenseFieldStateIdl,
});

export type LogEntry = {
  message: Text;
  isImportant: Bool;
};
export const LogEntryIdl = IDL.Record({
  message: IDL.Text,
  isImportant: IDL.Bool,
});

export type PlayerState = {
  id: PlayerId;
  name: Text;
  teamId: TeamId;
  condition: PlayerCondition;
  skills: PlayerSkills;
  position: FieldPosition;
};
export const PlayerStateIdl = IDL.Record({
  id: PlayerIdIdl,
  name: IDL.Text,
  teamId: TeamIdIdl,
  condition: PlayerConditionIdl,
  skills: PlayerSkillsIdl,
  position: FieldPositionIdl,
});

export type InProgressMatch = {
  team1: Team;
  team2: Team;
  offenseTeamId: TeamId;
  aura: MatchAura;
  players: PlayerState[];
  field: FieldState;
  log: LogEntry[];
  round: Nat;
  outs: Nat;
  strikes: Nat;
};
export const InProgressMatchIdl = IDL.Record({
  offenseTeamId: TeamIdIdl,
  team1: TeamIdl,
  team2: TeamIdl,
  aura: MatchAuraIdl,
  players: IDL.Vec(PlayerStateIdl),
  field: FieldStateIdl,
  log: IDL.Vec(LogEntryIdl),
  round: IDL.Nat,
  outs: IDL.Nat,
  strikes: IDL.Nat,
});


export type PlayedMatch = {
  team1: Team;
  team2: Team;
  winner: TeamIdOrTie;
  log: LogEntry[];
};
export const PlayedMatchIdl = IDL.Record({
  team1: TeamIdl,
  team2: TeamIdl,
  winner: TeamIdOrTieIdl,
  log: IDL.Vec(LogEntryIdl),
});

export type PlayerNotFoundError = {
  id: PlayerId;
  teamId: [TeamId] | [];
};
export const PlayerNotFoundErrorIdl = IDL.Record({
  id: PlayerIdIdl,
  teamId: IDL.Opt(TeamIdIdl),
});

export type PlayerExpectedOnFieldError = {
  id: PlayerId;
  onOffense: Bool;
  description: Text;
};
export const PlayerExpectedOnFieldErrorIdl = IDL.Record({
  id: PlayerIdIdl,
  onOffense: IDL.Bool,
  description: IDL.Text,
});

export type MatchPlayer = {
  id: PlayerId;
  name: Text;
};
export const MatchPlayerIdl = IDL.Record({
  id: PlayerIdIdl,
  name: IDL.Text,
});

export type BrokenStateError =
  | { playerNotFound: PlayerNotFoundError }
  | { playerExpectedOnField: PlayerExpectedOnFieldError };
export const BrokenStateErrorIdl = IDL.Variant({
  playerNotFound: PlayerNotFoundErrorIdl,
  playerExpectedOnField: PlayerExpectedOnFieldErrorIdl,
});

export type BrokenState = {
  log: LogEntry[];
  error: BrokenStateError;
};
export const BrokenStateIdl = IDL.Record({
  log: IDL.Vec(LogEntryIdl),
  error: BrokenStateErrorIdl,
});

export type CompletedMatch =
  | { absentTeam: TeamId }
  | { allAbsent: null }
  | { played: PlayedMatch }
  | { stateBroken: BrokenState };
export const CompletedMatchIdl = IDL.Variant({
  absentTeam: TeamIdIdl,
  allAbsent: IDL.Null,
  played: PlayedMatchIdl,
  stateBroken: BrokenStateIdl,
});

export type CompletedMatchGroup = {
  matches: CompletedMatch[];
};
export const CompletedMatchGroupIdl = IDL.Record({
  matches: IDL.Vec(CompletedMatchIdl),
});

export type MatchVariant =
  | { inProgress: InProgressMatch }
  | { completed: CompletedMatch };
export const MatchVariantIdl = IDL.Variant({
  inProgress: InProgressMatchIdl,
  completed: CompletedMatchIdl,
});


export type MatchGroup = {
  id: Nat;
  tickTimerId: Nat;
  currentSeed: number;
  matches: MatchVariant[];
}
export const MatchGroupIdl = IDL.Record({
  id: IDL.Nat,
  tickTimerId: IDL.Nat,
  currentSeed: IDL.Int,
  matches: IDL.Vec(MatchVariantIdl),
});

export type MatchTeam = {
  id: Principal;
  name: Text;
  logoUrl: Text;
  predictionVotes: Nat;
  players: MatchPlayer[];
};
export const MatchTeamIdl = IDL.Record({
  id: IDL.Principal,
  name: IDL.Text,
  logoUrl: IDL.Text,
  predictionVotes: IDL.Nat,
  players: IDL.Vec(MatchPlayerIdl),
});


export type MatchWithoutState = {
  team1: MatchTeam;
  team2: MatchTeam;
  offerings: OfferingWithMetaData[];
  aura: MatchAuraWithMetaData;
};
export const MatchWithoutStateIdl = IDL.Record({
  team1: MatchTeamIdl,
  team2: MatchTeamIdl,
  offerings: IDL.Vec(OfferingWithMetaDataIdl),
  aura: MatchAuraWithMetaDataIdl,
});


export type TickMatchGroupResult =
  | { inProgress: null }
  | { matchGroupNotFound: null }
  | {
    onStartCallbackError: {
      unknown: Text
    } | { notScheduledYet: null }
    | { alreadyStarted: null }
    | { notAuthorized: null }
    | { matchGroupNotFound: null }
  }
  | { completed: null };
export const TickMatchGroupResultIdl = IDL.Variant({
  inProgress: IDL.Null,
  matchGroupNotFound: IDL.Null,
  onStartCallbackError: IDL.Variant({
    unknown: IDL.Text,
    notScheduledYet: IDL.Null,
    alreadyStarted: IDL.Null,
    notAuthorized: IDL.Null,
    matchGroupNotFound: IDL.Null,
  }),
  completed: IDL.Null,
});


export interface _SERVICE {
  'getMatchGroup': ActorMethod<[Nat], [MatchGroup] | []>;
  'tickMatchGroup': ActorMethod<[Nat], TickMatchGroupResult>;
  'resetTickTimer': ActorMethod<[Nat], ResetTickTimerResult>;
};



export const idlFactory: InterfaceFactory = ({ }) => {

  return IDL.Service({
    'getMatchGroup': IDL.Func([IDL.Nat], [IDL.Opt(MatchGroupIdl)], []),
    'tickMatchGroup': IDL.Func([IDL.Nat], [TickMatchGroupResultIdl], []),
    'resetTickTimer': IDL.Func([IDL.Nat], [ResetTickTimerResultIdl], []),
  });
};

export let stadiumAgentFactory = (stadiumId: Principal) => createActor<_SERVICE>(stadiumId, idlFactory);

