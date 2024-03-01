import type { Principal } from '@dfinity/principal';
import { IDL } from "@dfinity/candid";
import { MatchAura, MatchAuraIdl, MatchAuraWithMetaData, MatchAuraWithMetaDataIdl } from './MatchAura';
import { TeamIdOrTie, TeamIdOrTieIdl } from './Team';
import { TeamPositions, TeamPositionsIdl } from './Player';
import { Scenario, ScenarioIdl } from './Scenario';

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
};
export const ScheduledTeamInfoIdl = IDL.Record({
    id: IDL.Principal,
    name: IDL.Text,
    logoUrl: IDL.Text
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

export type InProgressTeam = TeamInfo & {
    positions: TeamPositions;
};
export const InProgressTeamIdl = IDL.Record({
    id: IDL.Principal,
    name: IDL.Text,
    logoUrl: IDL.Text,
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
    score: Int;
    positions: TeamPositions;
};
export const CompletedMatchTeamIdl = IDL.Record({
    id: IDL.Principal,
    name: IDL.Text,
    logoUrl: IDL.Text,
    score: IDL.Int,
    positions: TeamPositionsIdl,
});

export type CompletedMatch = {
    team1: CompletedMatchTeam;
    team2: CompletedMatchTeam;
    aura: MatchAura;
    winner: TeamIdOrTie;
};
export const CompletedMatchIdl = IDL.Record({
    team1: CompletedMatchTeamIdl,
    team2: CompletedMatchTeamIdl,
    aura: MatchAuraIdl,
    winner: TeamIdOrTieIdl,
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
    scenario: Scenario;
};
export const CompletedMatchGroupIdl = IDL.Record({
    time: TimeIdl,
    matches: IDL.Vec(CompletedMatchIdl),
    scenario: ScenarioIdl,
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
    scenario: Scenario;
};
export const NotScheduledMatchGroupIdl = IDL.Record({
    time: TimeIdl,
    matches: IDL.Vec(NotScheduledMatchIdl),
    scenario: ScenarioIdl,
});

export type ScheduledMatchGroup = {
    time: Time;
    timerId: Nat;
    matches: ScheduledMatch[];
    scenario: Scenario;
};
export const ScheduledMatchGroupIdl = IDL.Record({
    time: TimeIdl,
    timerId: IDL.Nat,
    matches: IDL.Vec(ScheduledMatchIdl),
    scenario: ScenarioIdl,
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
