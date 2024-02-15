import type { Principal } from '@dfinity/principal';
import { IDL } from "@dfinity/candid";
import { MatchAura, MatchAuraIdl, MatchAuraWithMetaData, MatchAuraWithMetaDataIdl } from "../models/MatchAura";
import { TeamId, TeamIdIdl, TeamIdOrTie, TeamIdOrTieIdl } from "../models/Team";
import { ActorMethod } from '@dfinity/agent';
import { InterfaceFactory } from '@dfinity/candid/lib/cjs/idl';
import { createActor } from './Actor';
import { FieldPosition, PlayerSkills, PlayerSkillsIdl } from './Players';
import { Injury, InjuryIdl, PlayerCondition, PlayerConditionIdl } from '../models/Player';
import { CompletedMatchTeam, CompletedMatchTeamIdl, PlayerMatchStats, PlayerMatchStatsIdl, TeamPositions, TeamPositionsIdl } from '../models/Season';
import { Base, BaseIdl } from '../models/Base';
import { Curse, CurseIdl } from '../models/Curse';
import { Blessing, BlessingIdl } from '../models/Blessing';
import { Trait, TraitIdl } from '../models/Trait';

export type Nat = bigint;
export type Nat32 = number;
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
};
export const TeamIdl = IDL.Record({
  id: IDL.Principal,
  name: IDL.Text,
  logoUrl: IDL.Text,
});


export type TeamState = {
  id: Principal;
  name: Text;
  logoUrl: Text;
  score: Int;
  offering: Offering;
  positions: TeamPositions
};
export const TeamStateIdl = IDL.Record({
  id: IDL.Principal,
  name: IDL.Text,
  logoUrl: IDL.Text,
  score: IDL.Int,
  offering: OfferingIdl,
  positions: TeamPositionsIdl,
});


export type BaseState = {
  atBat: PlayerId;
  firstBase: [PlayerId] | [];
  secondBase: [PlayerId] | [];
  thirdBase: [PlayerId] | [];
};
export const BaseStateIdl = IDL.Record({
  atBat: PlayerIdIdl,
  firstBase: IDL.Opt(PlayerIdIdl),
  secondBase: IDL.Opt(PlayerIdIdl),
  thirdBase: IDL.Opt(PlayerIdIdl),
});


export type PlayerState = {
  id: PlayerId;
  name: Text;
  teamId: TeamId;
  condition: PlayerCondition;
  skills: PlayerSkills;
};
export const PlayerStateIdl = IDL.Record({
  id: PlayerIdIdl,
  name: IDL.Text,
  teamId: TeamIdIdl,
  condition: PlayerConditionIdl,
  skills: PlayerSkillsIdl,
});



export type Roll = {
  value: number;
  crit: boolean
};
export const RollIdl = IDL.Record({
  value: IDL.Int,
  crit: IDL.Bool,
});

export type HitLocation =
  FieldPosition
  | { stands: null };
export const HitLocationIdl = IDL.Variant({
  firstBase: IDL.Null,
  secondBase: IDL.Null,
  thirdBase: IDL.Null,
  shortStop: IDL.Null,
  leftField: IDL.Null,
  centerField: IDL.Null,
  rightField: IDL.Null,
  pitcher: IDL.Null,
  stands: IDL.Null,
});

export type SwingOutcome =
  | { foul: null }
  | { strike: null }
  | { hit: HitLocation };
export const SwingOutcomeIdl = IDL.Variant({
  foul: IDL.Null,
  strike: IDL.Null,
  hit: HitLocationIdl,
});

export type MatchEndReason =
  | { noMoreRounds: null }
  | { error: string };
export const MatchEndReasonIdl = IDL.Variant({
  noMoreRounds: IDL.Null,
  error: IDL.Text,
});

export type OutReason =
  | { ballCaught: null }
  | { strikeout: null }
  | { hitByBall: null };
export const OutReasonIdl = IDL.Variant({
  ballCaught: IDL.Null,
  strikeout: IDL.Null,
  hitByBall: IDL.Null,
});

export type MatchEvent =
  | { traitTrigger: { id: Trait; playerId: PlayerId; description: string } }
  | { offeringTrigger: { id: Offering; teamId: TeamId; description: string } }
  | { auraTrigger: { id: MatchAura; description: string } }
  | { pitch: { pitcherId: PlayerId; roll: Roll } }
  | { swing: { playerId: PlayerId; roll: Roll; pitchRoll: Roll; outcome: SwingOutcome } }
  | { catch_: { playerId: PlayerId; roll: Roll; difficulty: Roll } }
  | { teamSwap: { offenseTeamId: TeamId; atBatPlayerId: PlayerId } }
  | { injury: { playerId: number; injury: Injury } }
  | { death: { playerId: number } }
  | { curse: { playerId: number; curse: Curse } }
  | { blessing: { playerId: number; blessing: Blessing } }
  | { score: { teamId: TeamId; amount: number } }
  | { newBatter: { playerId: PlayerId } }
  | { out: { playerId: PlayerId; reason: OutReason } }
  | { matchEnd: { reason: MatchEndReason } }
  | { safeAtBase: { playerId: PlayerId; base: Base } }
  | { hitByBall: { playerId: PlayerId; } }
  | { throw_: { from: PlayerId; to: PlayerId } };
export const MatchEventIdl = IDL.Variant({
  traitTrigger: IDL.Record({
    id: TraitIdl,
    playerId: IDL.Nat32,
    description: IDL.Text,
  }),
  offeringTrigger: IDL.Record({
    id: OfferingIdl,
    teamId: TeamIdOrTieIdl,
    description: IDL.Text,
  }),
  auraTrigger: IDL.Record({
    id: MatchAuraIdl,
    description: IDL.Text,
  }),
  pitch: IDL.Record({
    pitcherId: IDL.Nat32,
    roll: RollIdl,
  }),
  swing: IDL.Record({
    playerId: IDL.Nat32,
    roll: RollIdl,
    pitchRoll: RollIdl,
    outcome: SwingOutcomeIdl,
  }),
  catch: IDL.Record({
    playerId: IDL.Nat32,
    roll: RollIdl,
    difficulty: RollIdl,
  }),
  teamSwap: IDL.Record({
    offenseTeamId: TeamIdOrTieIdl,
    atBatPlayerId: IDL.Nat32,
  }),
  injury: IDL.Record({
    playerId: IDL.Nat32,
    injury: InjuryIdl,
  }),
  death: IDL.Record({
    playerId: IDL.Nat32,
  }),
  curse: IDL.Record({
    playerId: IDL.Nat32,
    curse: CurseIdl,
  }),
  blessing: IDL.Record({
    playerId: IDL.Nat32,
    blessing: BlessingIdl,
  }),
  score: IDL.Record({
    teamId: TeamIdOrTieIdl,
    amount: IDL.Int,
  }),
  newBatter: IDL.Record({
    playerId: IDL.Nat32,
  }),
  out: IDL.Record({
    playerId: IDL.Nat32,
    reason: OutReasonIdl,
  }),
  matchEnd: IDL.Record({
    reason: MatchEndReasonIdl,
  }),
  safeAtBase: IDL.Record({
    playerId: IDL.Nat32,
    base: BaseIdl,
  }),
  hitByBall: IDL.Record({
    playerId: IDL.Nat32,
  }),
  throw: IDL.Record({
    from: IDL.Nat32,
    to: IDL.Nat32,
  }),
});


export type TurnLog = {
  events: MatchEvent[];
};
export const TurnLogIdl = IDL.Record({
  events: IDL.Vec(MatchEventIdl),
});


export type RoundLog = {
  turns: TurnLog[];
};
export const RoundLogIdl = IDL.Record({
  turns: IDL.Vec(TurnLogIdl),
});

export type MatchLog = {
  rounds: RoundLog[];
};
export const MatchLogIdl = IDL.Record({
  rounds: IDL.Vec(RoundLogIdl),
});

export type InProgressMatch = {
  team1: TeamState;
  team2: TeamState;
  offenseTeamId: TeamId;
  aura: MatchAura;
  players: PlayerState[];
  bases: BaseState;
  log: MatchLog;
  outs: Nat;
  strikes: Nat;
};
export const InProgressMatchIdl = IDL.Record({
  offenseTeamId: TeamIdIdl,
  team1: TeamStateIdl,
  team2: TeamStateIdl,
  aura: MatchAuraIdl,
  players: IDL.Vec(PlayerStateIdl),
  bases: BaseStateIdl,
  log: MatchLogIdl,
  outs: IDL.Nat,
  strikes: IDL.Nat,
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



export type CompletedMatch = {
  team1: CompletedMatchTeam;
  team2: CompletedMatchTeam;
  aura: MatchAura;
  winner: TeamIdOrTie;
  playerStats: PlayerMatchStats[];
};
export const CompletedMatchIdl = IDL.Record({
  team1: CompletedMatchTeamIdl,
  team2: CompletedMatchTeamIdl,
  aura: MatchAuraIdl,
  winner: TeamIdOrTieIdl,
  playerStats: IDL.Vec(PlayerMatchStatsIdl),
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
  currentSeed: IDL.Nat32,
  matches: IDL.Vec(MatchVariantIdl),
});

export type MatchTeam = {
  id: Principal;
  name: Text;
  logoUrl: Text;
  players: MatchPlayer[];
};
export const MatchTeamIdl = IDL.Record({
  id: IDL.Principal,
  name: IDL.Text,
  logoUrl: IDL.Text,
  players: IDL.Vec(MatchPlayerIdl),
});


export type MatchWithoutState = {
  team1: MatchTeam;
  team2: MatchTeam;
  offeringOptions: OfferingWithMetaData[];
  aura: MatchAuraWithMetaData;
};
export const MatchWithoutStateIdl = IDL.Record({
  team1: MatchTeamIdl,
  team2: MatchTeamIdl,
  offeringOptions: IDL.Vec(OfferingWithMetaDataIdl),
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

