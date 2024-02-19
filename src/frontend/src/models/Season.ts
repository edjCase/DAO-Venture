import type { Principal } from '@dfinity/principal';
import { IDL } from "@dfinity/candid";
import { MatchAura, MatchAuraIdl, MatchAuraWithMetaData, MatchAuraWithMetaDataIdl } from './MatchAura';
import { TeamIdOrTie, TeamIdOrTieIdl } from './Team';
import { ScenarioInstance, ScenarioInstanceIdl, ScenarioInstanceWithChoice, ScenarioInstanceWithChoiceIdl } from './Scenario';
import { PlayerId } from './Player';

export type Time = bigint;
export const TimeIdl = IDL.Int;
export type Nat = bigint;
export type Int = bigint;
export type Bool = boolean;
export type Text = string;

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
    | { seasonStandingIndex: Nat }
    | { winnerOfMatch: Nat };
export const TeamAssignmentIdl = IDL.Variant({
    predetermined: TeamInfoIdl,
    seasonStandingIndex: IDL.Nat,
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

export type ScheduledTeamInfo = TeamInfo & {
    scenario: ScenarioInstance;
};
export const ScheduledTeamInfoIdl = IDL.Record({
    id: IDL.Principal,
    name: IDL.Text,
    logoUrl: IDL.Text,
    scenario: ScenarioInstanceIdl,
});

export type ScheduledMatch = {
    team1: ScheduledTeamInfo;
    team2: ScheduledTeamInfo;
    aura: MatchAuraWithMetaData;
};
export const ScheduledMatchIdl = IDL.Record({
    team1: ScheduledTeamInfoIdl,
    team2: ScheduledTeamInfoIdl,
    aura: MatchAuraWithMetaDataIdl,
});

export type TeamPositions = {
    firstBase: PlayerId;
    secondBase: PlayerId;
    thirdBase: PlayerId;
    shortStop: PlayerId;
    pitcher: PlayerId;
    leftField: PlayerId;
    centerField: PlayerId;
    rightField: PlayerId;
};
export const TeamPositionsIdl = IDL.Record({
    firstBase: IDL.Nat32,
    secondBase: IDL.Nat32,
    thirdBase: IDL.Nat32,
    shortStop: IDL.Nat32,
    pitcher: IDL.Nat32,
    leftField: IDL.Nat32,
    centerField: IDL.Nat32,
    rightField: IDL.Nat32,
});

export type InProgressTeam = TeamInfo & {
    scenario: ScenarioInstanceWithChoice;
    positions: TeamPositions;
};
export const InProgressTeamIdl = IDL.Record({
    id: IDL.Principal,
    name: IDL.Text,
    logoUrl: IDL.Text,
    scenario: ScenarioInstanceWithChoiceIdl,
    positions: TeamPositionsIdl,
});

export type InProgressMatch = {
    team1: InProgressTeam;
    team2: InProgressTeam;
    aura: MatchAura;
};
export const InProgressMatchIdl = IDL.Record({
    team1: InProgressTeamIdl,
    team2: InProgressTeamIdl,
    aura: MatchAuraIdl,
});

export type CompletedMatchTeam = TeamInfo & {
    scenario: ScenarioInstanceWithChoice;
    score: Int;
    positions: TeamPositions;
};
export const CompletedMatchTeamIdl = IDL.Record({
    id: IDL.Principal,
    name: IDL.Text,
    logoUrl: IDL.Text,
    scenario: ScenarioInstanceWithChoiceIdl,
    score: IDL.Int,
    positions: TeamPositionsIdl,
});

export type PlayerMatchStats = {
    battingStats: {
        atBats: Nat;
        hits: Nat;
        strikeouts: Nat;
        runs: Nat;
        homeRuns: Nat;
    };
    catchingStats: {
        successfulCatches: Nat;
        missedCatches: Nat;
        throws: Nat;
        throwOuts: Nat;
    };
    pitchingStats: {
        pitches: Nat;
        strikes: Nat;
        hits: Nat;
        strikeouts: Nat;
        runs: Nat;
        homeRuns: Nat;
    };
    injuries: Nat;
};

export const PlayerMatchStatsIdl = IDL.Record({
    battingStats: IDL.Record({
        atBats: IDL.Nat,
        hits: IDL.Nat,
        strikeouts: IDL.Nat,
        runs: IDL.Nat,
        homeRuns: IDL.Nat,
    }),
    catchingStats: IDL.Record({
        successfulCatches: IDL.Nat,
        missedCatches: IDL.Nat,
        throws: IDL.Nat,
        throwOuts: IDL.Nat,
    }),
    pitchingStats: IDL.Record({
        pitches: IDL.Nat,
        strikes: IDL.Nat,
        hits: IDL.Nat,
        strikeouts: IDL.Nat,
        runs: IDL.Nat,
        homeRuns: IDL.Nat,
    }),
    injuries: IDL.Nat,
});

export type PlayerMatchStatsWithId = PlayerMatchStats & {
    playerId: PlayerId;
};
export const PlayerMatchStatsWithIdIdl = IDL.Record({
    playerId: IDL.Nat32,
    battingStats: IDL.Record({
        atBats: IDL.Nat,
        hits: IDL.Nat,
        strikeouts: IDL.Nat,
        runs: IDL.Nat,
        homeRuns: IDL.Nat,
    }),
    catchingStats: IDL.Record({
        successfulCatches: IDL.Nat,
        missedCatches: IDL.Nat,
        throws: IDL.Nat,
        throwOuts: IDL.Nat,
    }),
    pitchingStats: IDL.Record({
        pitches: IDL.Nat,
        strikes: IDL.Nat,
        hits: IDL.Nat,
        strikeouts: IDL.Nat,
        runs: IDL.Nat,
        homeRuns: IDL.Nat,
    }),
    injuries: IDL.Nat,
});



export type CompletedMatch = {
    team1: CompletedMatchTeam;
    team2: CompletedMatchTeam;
    aura: MatchAura;
    winner: TeamIdOrTie;
    playerStats: PlayerMatchStatsWithId[];
};
export const CompletedMatchIdl = IDL.Record({
    team1: CompletedMatchTeamIdl,
    team2: CompletedMatchTeamIdl,
    aura: MatchAuraIdl,
    winner: TeamIdOrTieIdl,
    playerStats: IDL.Vec(PlayerMatchStatsIdl),
});


export type CompletedSeasonTeam = TeamInfo & {
    wins: Nat;
    losses: Nat;
    totalScore: Int;
};
export const CompletedSeasonTeamIdl = IDL.Record({
    id: IDL.Principal,
    name: IDL.Text,
    logoUrl: IDL.Text,
    wins: IDL.Nat,
    losses: IDL.Nat,
    totalScore: IDL.Int,
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
    championTeamId: Principal;
    runnerUpTeamId: Principal;
    teams: CompletedSeasonTeam[];
    matchGroups: CompletedMatchGroup[];
};
export const CompletedSeasonIdl = IDL.Record({
    championTeamId: IDL.Principal,
    runnerUpTeamId: IDL.Principal,
    teams: IDL.Vec(CompletedSeasonTeamIdl),
    matchGroups: IDL.Vec(CompletedMatchGroupIdl),
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
    timerId: Nat;
    matches: ScheduledMatch[];
};
export const ScheduledMatchGroupIdl = IDL.Record({
    time: TimeIdl,
    timerId: IDL.Nat,
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

export type InProgressSeason = {
    matchGroups: InProgressSeasonMatchGroupVariant[];
};
export const InProgressSeasonIdl = IDL.Record({
    matchGroups: IDL.Vec(InProgressSeasonMatchGroupVariantIdl),
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
