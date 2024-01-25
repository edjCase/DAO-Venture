import type { Principal } from '@dfinity/principal';
import { IDL } from "@dfinity/candid";
import { Offering, OfferingIdl, OfferingWithMetaData, OfferingWithMetaDataIdl } from './Offering';
import { MatchAura, MatchAuraIdl, MatchAuraWithMetaData, MatchAuraWithMetaDataIdl } from './MatchAura';
import { TeamId, TeamIdOrTie, TeamIdOrTieIdl } from './Team';
import { Injury } from './Player';
import { Trait, TraitIdl } from './Trait';
import { Curse, CurseIdl } from './Curse';
import { Blessing, BlessingIdl } from './Blessing';
import { Base, BaseIdl } from './Base';

export type Time = bigint;
export const TimeIdl = IDL.Int;
export type Nat = bigint;
export type Nat32 = number;
export type Int = bigint;
export type Bool = boolean;
export type Text = string;
export type PlayerId = Nat32;

export type Roll = {
    value: number;
    crit: boolean
};
export const RollIdl = IDL.Record({
    value: IDL.Nat,
    crit: IDL.Bool,
});

export type SwingOutcome =
    | { foul: null }
    | { strike: null }
    | { hit: null };
export const SwingOutcomeIdl = IDL.Variant({
    foul: IDL.Null,
    strike: IDL.Null,
    hit: IDL.Null,
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
    | { newRound: { offenseTeamId: TeamId; atBatPlayerId: PlayerId } }
    | { injury: { playerId: number; injury: Injury } }
    | { death: { playerId: number } }
    | { curse: { playerId: number; curse: Curse } }
    | { blessing: { playerId: number; blessing: Blessing } }
    | { score: { teamId: TeamId; amount: number } }
    | { newBatter: { playerId: PlayerId } }
    | { out: { playerId: PlayerId; reason: OutReason } }
    | { matchEnd: { reason: MatchEndReason } }
    | { safeAtBase: { playerId: PlayerId; base: Base } }
    | { hitByBall: { playerId: PlayerId; throwingPlayerId: PlayerId } };
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
    catch_: IDL.Record({
        playerId: IDL.Nat32,
        roll: RollIdl,
        difficulty: RollIdl,
    }),
    newRound: IDL.Record({
        offenseTeamId: TeamIdOrTieIdl,
        atBatPlayerId: IDL.Nat32,
    }),
    injury: IDL.Record({
        playerId: IDL.Nat32,
        injury: IDL.Variant({
            none: IDL.Null,
            mild: IDL.Null,
            moderate: IDL.Null,
            severe: IDL.Null,
        }),
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
        amount: IDL.Nat,
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
        throwingPlayerId: IDL.Nat32,
    })
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

export type TeamInfo = {
    id: Principal;
    name: Text;
    logoUrl: Text;
};
export const TeamInfoIdl = IDL.Record({
    id: IDL.Principal,
    name: IDL.Text,
    logoUrl: IDL.Text,
});

export type TeamAssignment =
    | { predetermined: TeamInfo }
    | { seasonStanding: Nat }
    | { winnerOfMatch: Nat };
export const TeamAssignmentIdl = IDL.Variant({
    predetermined: TeamInfoIdl,
    seasonStanding: IDL.Nat,
    winnerOfMatch: IDL.Nat,
});

export type NotScheduledMatch = {
    team1: TeamAssignment;
    team2: TeamAssignment;
};
export const NotScheduledMatchIdl = IDL.Record({
    team1: TeamAssignmentIdl,
    team2: TeamAssignmentIdl,
});

export type ScheduledMatch = {
    team1: TeamInfo;
    team2: TeamInfo;
    offeringOptions: OfferingWithMetaData[];
    aura: MatchAuraWithMetaData;
};
export const ScheduledMatchIdl = IDL.Record({
    team1: TeamInfoIdl,
    team2: TeamInfoIdl,
    offeringOptions: IDL.Vec(OfferingWithMetaDataIdl),
    aura: MatchAuraWithMetaDataIdl,
});

export type InProgressMatchTeam = TeamInfo & {
    offering: Offering;
};
export const InProgressMatchTeamIdl = IDL.Record({
    id: IDL.Principal,
    name: IDL.Text,
    logoUrl: IDL.Text,
    offering: OfferingIdl,
});

export type InProgressMatch = {
    team1: InProgressMatchTeam;
    team2: InProgressMatchTeam;
    aura: MatchAura;
};
export const InProgressMatchIdl = IDL.Record({
    team1: InProgressMatchTeamIdl,
    team2: InProgressMatchTeamIdl,
    aura: MatchAuraIdl,
});

export type CompletedMatchTeam = TeamInfo & {
    offering: Offering;
    score: Int;
};
export const CompletedMatchTeamIdl = IDL.Record({
    id: IDL.Principal,
    name: IDL.Text,
    logoUrl: IDL.Text,
    offering: OfferingIdl,
    score: IDL.Int,
});

export type PlayerMatchStats = {
    playerId: Nat32;
    offenseStats: {
        atBats: Nat;
        hits: Nat;
        runs: Nat;
        runsBattedIn: Nat;
        strikeouts: Nat;
    };
    defenseStats: {
        catches: Nat;
        missedCatches: Nat;
        outs: Nat;
        assists: Nat;
    };
};
export const PlayerMatchStatsIdl = IDL.Record({
    playerId: IDL.Nat32,
    offenseStats: IDL.Record({
        atBats: IDL.Nat,
        hits: IDL.Nat,
        runs: IDL.Nat,
        runsBattedIn: IDL.Nat,
        strikeouts: IDL.Nat,
    }),
    defenseStats: IDL.Record({
        catches: IDL.Nat,
        missedCatches: IDL.Nat,
        outs: IDL.Nat,
        assists: IDL.Nat,
    }),
});


export type CompletedMatch = {
    team1: CompletedMatchTeam;
    team2: CompletedMatchTeam;
    aura: MatchAura;
    log: MatchLog;
    winner: TeamIdOrTie;
    playerStats: PlayerMatchStats[];
};
export const CompletedMatchIdl = IDL.Record({
    team1: CompletedMatchTeamIdl,
    team2: CompletedMatchTeamIdl,
    aura: MatchAuraIdl,
    log: MatchLogIdl,
    winner: TeamIdOrTieIdl,
    playerStats: PlayerMatchStatsIdl,
});

export type CompletedSeasonTeam = TeamInfo & {
    standing: Nat;
    wins: Nat;
    losses: Nat;
    totalScore: Int;
};
export const CompletedSeasonTeamIdl = IDL.Record({
    id: IDL.Principal,
    name: IDL.Text,
    logoUrl: IDL.Text,
    standing: IDL.Nat,
    wins: IDL.Nat,
    losses: IDL.Nat,
    totalScore: IDL.Int,
});

export type NotScheduledMatchGroup = {
    time: Time;
    matches: NotScheduledMatch[];
};
export const NotScheduledMatchGroupIdl = IDL.Record({
    time: TimeIdl,
    matches: IDL.Vec(NotScheduledMatchIdl),
});


export type ScheduledMatchGroup = {
    time: Time;
    matches: ScheduledMatch[];
};
export const ScheduledMatchGroupIdl = IDL.Record({
    time: TimeIdl,
    matches: IDL.Vec(ScheduledMatchIdl),
});

export type InProgressMatchGroup = {
    time: Time;
    stadiumId: Principal;
    matches: InProgressMatch[];
};
export const InProgressMatchGroupIdl = IDL.Record({
    time: TimeIdl,
    stadiumId: IDL.Principal,
    matches: IDL.Vec(InProgressMatchIdl),
});

export type CompletedMatchGroup = {
    time: Time;
    matches: CompletedMatch[];
};
export const CompletedMatchGroupIdl = IDL.Record({
    time: TimeIdl,
    matches: IDL.Vec(CompletedMatchIdl),
});

export type CompletedSeason = {
    teams: CompletedSeasonTeam[];
    matchGroups: CompletedMatchGroup[];
};
export const CompletedSeasonIdl = IDL.Record({
    teams: IDL.Vec(CompletedSeasonTeamIdl),
    matchGroups: IDL.Vec(CompletedMatchGroupIdl),
});

export type InProgressSeasonMatchGroupVariant =
    | { notScheduled: NotScheduledMatchGroup }
    | { scheduled: ScheduledMatchGroup }
    | { inProgress: InProgressMatchGroup }
    | { completed: CompletedMatchGroup };
export const InProgressSeasonMatchGroupVariantIdl = IDL.Variant({
    notScheduled: NotScheduledMatchGroupIdl,
    scheduled: ScheduledMatchGroupIdl,
    inProgress: InProgressMatchGroupIdl,
    completed: CompletedMatchGroupIdl,
});

export type TeamStandingInfo = {
    id: Principal;
    wins: Nat;
    losses: Nat;
    totalScore: Int;
};
export const TeamStandingInfoIdl = IDL.Record({
    id: IDL.Principal,
    wins: IDL.Nat,
    losses: IDL.Nat,
    totalScore: IDL.Int,
});

export type InProgressSeason = {
    matchGroups: InProgressSeasonMatchGroupVariant[];
    teamStandings: [TeamStandingInfo[]] | [];
};
export const InProgressSeasonIdl = IDL.Record({
    matchGroups: IDL.Vec(InProgressSeasonMatchGroupVariantIdl),
    teamStandings: IDL.Opt(IDL.Vec(TeamStandingInfoIdl)),
});



export type SeasonStatus =
    | { notStarted: null }
    | { starting: null }
    | { inProgress: InProgressSeason }
    | { completed: CompletedSeason };
export const SeasonStatusIdl = IDL.Variant({
    notStarted: IDL.Null,
    starting: IDL.Null,
    inProgress: InProgressSeasonIdl,
    completed: CompletedSeasonIdl,
});
