import type { Principal } from '@dfinity/principal';
import { IDL } from "@dfinity/candid";
import { Offering, OfferingIdl, OfferingWithMetaData, OfferingWithMetaDataIdl } from "../models/Offering";
import { MatchAura, MatchAuraIdl, MatchAuraWithMetaData, MatchAuraWithMetaDataIdl } from "../models/MatchAura";
import { TeamId, TeamIdIdl, TeamIdOrBoth, TeamIdOrBothIdl, TeamIdOrTie, TeamIdOrTieIdl } from "../models/Team";
import { ActorMethod } from '@dfinity/agent';
import { InterfaceFactory } from '@dfinity/candid/lib/cjs/idl';
import { createActor } from './Actor';
import { FieldPosition, FieldPositionIdl, PlayerSkills, PlayerSkillsIdl } from './PlayerLedger';
import { PlayerCondition, PlayerConditionIdl } from '../models/Player';

export type Nat = bigint;
export const NatIdl = IDL.Nat;
export type Int = number;
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

export type ScheduleMatchRequest = {
  team1Id: Principal;
  team2Id: Principal;
  offerings: Offering[];
  aura: MatchAura;
};
export const ScheduleMatchRequestIdl = IDL.Record({
  team1Id: IDL.Principal,
  team2Id: IDL.Principal,
  offerings: IDL.Vec(OfferingIdl),
  aura: MatchAuraIdl,
});

export type ScheduleMatchGroupRequest = {
  id: Nat;
  startTime: bigint;
  matches: ScheduleMatchRequest[];
};
export const ScheduleMatchGroupRequestIdl = IDL.Record({
  id: NatIdl,
  startTime: IDL.Int,
  matches: IDL.Vec(ScheduleMatchRequestIdl),
});

export type ScheduleMatchError =
  | { teamNotFound: TeamIdOrBoth };
export const ScheduleMatchErrorIdl = IDL.Variant({
  teamNotFound: TeamIdOrBothIdl,
});

export type ScheduleMatchGroupError =
  | { teamFetchError: Text }
  | { matchErrors: ScheduleMatchError[] }
  | { noMatchesSpecified: null }
  | { playerFetchError: Text };
export const ScheduleMatchGroupErrorIdl = IDL.Variant({
  teamFetchError: IDL.Text,
  matchErrors: IDL.Vec(ScheduleMatchErrorIdl),
  noMatchesSpecified: IDL.Null,
  playerFetchError: IDL.Text,
});

export type NotStartedMatchGroupState = {
  startTimerId: Nat;
};
export const NotStartedMatchGroupStateIdl = IDL.Record({
  startTimerId: NatIdl,
});

export type TeamState = {
  score: Int;
  offering: Offering;
  championId: PlayerId;
};
export const TeamStateIdl = IDL.Record({
  score: IDL.Int,
  offering: OfferingIdl,
  championId: PlayerIdIdl,
});

export type PlayerStateWithId = PlayerState & {
  id: PlayerId;
};
export const PlayerStateWithIdIdl = IDL.Record({
  teamId: TeamIdIdl,
  condition: PlayerConditionIdl,
  skills: PlayerSkillsIdl,
  position: FieldPositionIdl,
  id: PlayerIdIdl,
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
  firstBase: PlayerId | null;
  secondBase: PlayerId | null;
  thirdBase: PlayerId | null;
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

export type InProgressMatchState = {
  offenseTeamId: TeamId;
  team1: TeamState;
  team2: TeamState;
  aura: MatchAura;
  players: PlayerStateWithId[];
  field: FieldState;
  log: LogEntry[];
  round: Nat;
  outs: Nat;
  strikes: Nat;
};
export const InProgressMatchStateIdl = IDL.Record({
  offenseTeamId: TeamIdIdl,
  team1: TeamStateIdl,
  team2: TeamStateIdl,
  aura: MatchAuraIdl,
  players: IDL.Vec(PlayerStateWithIdIdl),
  field: FieldStateIdl,
  log: IDL.Vec(LogEntryIdl),
  round: NatIdl,
  outs: NatIdl,
  strikes: NatIdl,
});

export type PlayedTeamState = {
  score: Int;
};
export const PlayedTeamStateIdl = IDL.Record({
  score: IDL.Int,
});

export type PlayedMatchState = {
  team1: PlayedTeamState;
  team2: PlayedTeamState;
  winner: TeamIdOrTie;
  log: LogEntry[];
};
export const PlayedMatchStateIdl = IDL.Record({
  team1: PlayedTeamStateIdl,
  team2: PlayedTeamStateIdl,
  winner: TeamIdOrTieIdl,
  log: IDL.Vec(LogEntryIdl),
});

export type PlayerNotFoundError = {
  id: PlayerId;
  teamId: TeamId | null;
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

export type CompletedMatchState =
  | { absentTeam: TeamId }
  | { allAbsent: null }
  | { played: PlayedMatchState }
  | { stateBroken: BrokenState };
export const CompletedMatchStateIdl = IDL.Variant({
  absentTeam: TeamIdIdl,
  allAbsent: IDL.Null,
  played: PlayedMatchStateIdl,
  stateBroken: BrokenStateIdl,
});

export type StartedMatchState =
  | { inProgress: InProgressMatchState }
  | { completed: CompletedMatchState };
export const StartedMatchStateIdl = IDL.Variant({
  inProgress: InProgressMatchStateIdl,
  completed: CompletedMatchStateIdl,
});

export type InProgressMatchGroupState = {
  tickTimerId: Nat;
  currentSeed: number;
  matches: StartedMatchState[];
};
export const InProgressMatchGroupStateIdl = IDL.Record({
  tickTimerId: NatIdl,
  currentSeed: IDL.Nat32,
  matches: IDL.Vec(StartedMatchStateIdl),
});

export type CompletedMatchGroupState = {
  matches: CompletedMatchState[];
};
export const CompletedMatchGroupStateIdl = IDL.Record({
  matches: IDL.Vec(CompletedMatchStateIdl),
});

export type MatchGroupState =
  | StartedMatchGroupState
  | { notStarted: NotStartedMatchGroupState };
export const MatchGroupStateIdl = IDL.Variant({
  inProgress: InProgressMatchGroupStateIdl,
  completed: CompletedMatchGroupStateIdl,
  notStarted: NotStartedMatchGroupStateIdl,
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
  predictionVotes: NatIdl,
  players: IDL.Vec(MatchPlayerIdl),
});

export type MatchState =
  | StartedMatchState
  | { notStarted: null };
export const MatchStateIdl = IDL.Variant({
  inProgress: InProgressMatchStateIdl,
  completed: CompletedMatchStateIdl,
  notStarted: IDL.Null,
});

export type Match = MatchWithoutState & {
  state: MatchState;
};
export const MatchIdl = IDL.Record({
  team1: MatchTeamIdl,
  team2: MatchTeamIdl,
  offerings: IDL.Vec(OfferingWithMetaDataIdl),
  aura: MatchAuraWithMetaDataIdl,
  state: MatchStateIdl,
});

export type MatchGroupWithId = MatchGroup & {
  id: Nat;
};
export const MatchGroupWithIdIdl = IDL.Record({
  time: IDL.Int,
  matches: IDL.Vec(MatchIdl),
  state: MatchGroupStateIdl,
  id: NatIdl,
});

export type ScheduleMatchGroupResult =
  | ScheduleMatchGroupError
  | { ok: MatchGroupWithId };
export const ScheduleMatchGroupResultIdl = IDL.Variant({
  teamFetchError: IDL.Text,
  matchErrors: IDL.Vec(ScheduleMatchErrorIdl),
  noMatchesSpecified: IDL.Null,
  playerFetchError: IDL.Text,
  ok: MatchGroupWithIdIdl,
});

export type PlayerState = {
  teamId: TeamId;
  condition: PlayerCondition;
  skills: PlayerSkills;
  position: FieldPosition;
};
export const PlayerStateIdl = IDL.Record({
  teamId: TeamIdIdl,
  condition: PlayerConditionIdl,
  skills: PlayerSkillsIdl,
  position: FieldPositionIdl,
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



export type MatchGroup = {
  time: bigint;
  matches: Match[];
  state: MatchGroupState;
};
export const MatchGroupIdl = IDL.Record({
  time: IDL.Int,
  matches: IDL.Vec(MatchIdl),
  state: MatchGroupStateIdl,
});

export type StartedMatchGroupState =
  | { inProgress: InProgressMatchGroupState }
  | { completed: CompletedMatchGroupState };
export const StartedMatchGroupStateIdl = IDL.Variant({
  inProgress: InProgressMatchGroupStateIdl,
  completed: CompletedMatchGroupStateIdl,
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
  'getMatchGroup': ActorMethod<[Nat], MatchGroupWithId | null>;
  'tickMatchGroup': ActorMethod<[Nat], TickMatchGroupResult>;
  'scheduleMatchGroup': ActorMethod<[ScheduleMatchGroupRequest], ScheduleMatchGroupResult>;
  'resetTickTimer': ActorMethod<[Nat], ResetTickTimerResult>;
};



export const idlFactory: InterfaceFactory = ({ }) => {

  return IDL.Service({
    'getMatchGroup': IDL.Func([IDL.Nat], [IDL.Opt(MatchGroupWithIdIdl)], []),
    'tickMatchGroup': IDL.Func([IDL.Nat], [TickMatchGroupResultIdl], []),
    'scheduleMatchGroup': IDL.Func([ScheduleMatchGroupRequestIdl], [ScheduleMatchGroupResultIdl], []),
    'resetTickTimer': IDL.Func([IDL.Nat], [ResetTickTimerResultIdl], []),
  });
};


const canisterId = process.env.CANISTER_ID_STADIUM || "";
// Keep factory due to changing identity
export let leagueAgentFactory = () => createActor<_SERVICE>(canisterId, idlFactory);

