import type { Principal } from '@dfinity/principal';
import { IDL } from "@dfinity/candid";
import { MatchAura, MatchAuraIdl } from "../models/MatchAura";
import { TeamId, TeamIdIdl, TeamIdOrTieIdl } from "../models/Team";
import { ScenarioInstanceWithChoice, ScenarioInstanceWithChoiceIdl } from "../models/Scenario";
import { ActorMethod } from '@dfinity/agent';
import { InterfaceFactory } from '@dfinity/candid/lib/cjs/idl';
import { createActor } from './Actor';
import { Injury, InjuryIdl, PlayerCondition, PlayerConditionIdl, PlayerMatchStats, PlayerMatchStatsIdl, PlayerMatchStatsWithId, PlayerMatchStatsWithIdIdl, PlayerSkills, PlayerSkillsIdl } from "../models/Player";
import { CompletedMatch, CompletedMatchIdl, TeamPositions, TeamPositionsIdl } from "../models/Season";
import { Trait, TraitIdl } from '../models/Trait';
import { Curse, CurseIdl } from '../models/Curse';
import { Blessing, BlessingIdl } from '../models/Blessing';
import { Base, BaseIdl } from '../models/Base';
import { FieldPosition } from './Players';

export type Nat = bigint;
export type Nat32 = number;
export type Int = bigint;
export type Bool = boolean;
export type Text = string;
export type PlayerId = number;

export const NatIdl = IDL.Nat;
export const PlayerIdIdl = IDL.Nat32;

export type ResetTickTimerResult =
  | { ok: null }
  | { matchGroupNotFound: null };
export const ResetTickTimerResultIdl = IDL.Variant({
  ok: IDL.Null,
  matchGroupNotFound: IDL.Null,
});

export type StartMatchTeam = {
  id: Principal;
  name: Text;
  logoUrl: Text;
  scenario: ScenarioInstanceWithChoice;
  positions: TeamPositions;
};
export const StartMatchTeamIdl = IDL.Record({
  id: IDL.Principal,
  name: IDL.Text,
  logoUrl: IDL.Text,
  scenario: ScenarioInstanceWithChoiceIdl,
  positions: TeamPositionsIdl,
});

export type StartMatchRequest = {
  team1: StartMatchTeam;
  team2: StartMatchTeam;
  aura: MatchAura;
};
export const StartMatchRequestIdl = IDL.Record({
  team1: StartMatchTeamIdl,
  team2: StartMatchTeamIdl,
  aura: MatchAuraIdl,
});

export type StartMatchGroupRequest = {
  id: Nat;
  matches: StartMatchRequest[];
};
export const StartMatchGroupRequestIdl = IDL.Record({
  id: NatIdl,
  matches: IDL.Vec(StartMatchRequestIdl),
});

export type StartMatchGroupResult =
  | { ok: null }
  | { noMatchesSpecified: null };
export const StartMatchGroupResultIdl = IDL.Variant({
  ok: IDL.Null,
  noMatchesSpecified: IDL.Null,
});

export type TickMatchGroupResult =
  | { inProgress: null }
  | { matchGroupNotFound: null }
  | {
    onStartCallbackError:
    | { unknown: Text; }
    | { notScheduledYet: null; }
    | { alreadyStarted: null; }
    | { notAuthorized: null; }
    | { matchGroupNotFound: null; };
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


export type TeamState = {
  id: Principal;
  name: Text;
  logoUrl: Text;
  score: Int;
  scenario: ScenarioInstanceWithChoice;
  positions: TeamPositions;
};
export const TeamStateIdl = IDL.Record({
  id: IDL.Principal,
  name: IDL.Text,
  logoUrl: IDL.Text,
  score: IDL.Int,
  scenario: ScenarioInstanceWithChoiceIdl,
  positions: TeamPositionsIdl,
});

export type PlayerState = {
  id: PlayerId;
  name: Text;
  teamId: TeamId;
  condition: PlayerCondition;
  skills: PlayerSkills;
  matchStats: PlayerMatchStats;
};
export const PlayerStateIdl = IDL.Record({
  id: PlayerIdIdl,
  name: IDL.Text,
  teamId: TeamIdIdl,
  condition: PlayerConditionIdl,
  skills: PlayerSkillsIdl,
  matchStats: PlayerMatchStatsIdl,
});

export type BaseState = {
  atBat: PlayerId;
  firstBase: PlayerId | null;
  secondBase: PlayerId | null;
  thirdBase: PlayerId | null;
};
export const BaseStateIdl = IDL.Record({
  atBat: PlayerIdIdl,
  firstBase: IDL.Opt(PlayerIdIdl),
  secondBase: IDL.Opt(PlayerIdIdl),
  thirdBase: IDL.Opt(PlayerIdIdl),
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
  team1: TeamStateIdl,
  team2: TeamStateIdl,
  offenseTeamId: TeamIdIdl,
  aura: MatchAuraIdl,
  players: IDL.Vec(PlayerStateIdl),
  bases: BaseStateIdl,
  log: MatchLogIdl,
  outs: NatIdl,
  strikes: NatIdl,
});

export type CompletedTickResult = {
  match: CompletedMatch;
  matchStats: [PlayerMatchStatsWithId];
};
export const CompletedTickResultIdl = IDL.Record({
  match: CompletedMatchIdl,
  matchStats: IDL.Vec(PlayerMatchStatsWithIdIdl),
});

export type TickResult =
  | { inProgress: InProgressMatch }
  | { completed: CompletedTickResult };
export const TickResultIdl = IDL.Variant({
  inProgress: InProgressMatchIdl,
  completed: CompletedTickResultIdl,
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
  matches: TickResult[];
  tickTimerId: Nat;
  currentSeed: Nat32;
};
export const MatchGroupIdl = IDL.Record({
  id: NatIdl,
  matches: IDL.Vec(TickResultIdl),
  tickTimerId: NatIdl,
  currentSeed: IDL.Nat32,
});



export interface _SERVICE {
  getMatchGroup: ActorMethod<[Nat], [MatchGroup] | []>;
  tickMatchGroup: ActorMethod<[Nat], TickMatchGroupResult>;
  resetTickTimer: ActorMethod<[Nat], ResetTickTimerResult>;
  startMatchGroup: ActorMethod<[StartMatchGroupRequest], StartMatchGroupResult>;
}

export const idlFactory: InterfaceFactory = ({ IDL }) => {
  return IDL.Service({
    'getMatchGroup': IDL.Func([IDL.Nat], [IDL.Opt(MatchGroupIdl)], ['query']),
    'tickMatchGroup': IDL.Func([IDL.Nat], [TickMatchGroupResultIdl], []),
    'resetTickTimer': IDL.Func([IDL.Nat], [ResetTickTimerResultIdl], []),
    'startMatchGroup': IDL.Func([StartMatchGroupRequestIdl], [StartMatchGroupResultIdl], []),
  });
};

export const stadiumAgentFactory = (canisterId: Principal) => createActor<_SERVICE>(canisterId, idlFactory);
