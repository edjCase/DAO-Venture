import type { Principal } from '@dfinity/principal';
import { IDL } from "@dfinity/candid";
import { Offering, OfferingIdl, OfferingWithMetaData, OfferingWithMetaDataIdl } from './Offering';
import { MatchAura, MatchAuraIdl, MatchAuraWithMetaData, MatchAuraWithMetaDataIdl } from './MatchAura';
import { TeamIdOrTie, TeamIdOrTieIdl } from './Team';

export type Time = bigint;
export const TimeIdl = IDL.Int;
export type Nat = bigint;
export type Nat32 = number;
export type Int = bigint;
export type Bool = boolean;
export type Text = string;



export type LogEntry = {
    message: Text;
    isImportant: Bool;
};
export const LogEntryIdl = IDL.Record({
    message: IDL.Text,
    isImportant: IDL.Bool,
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

export type NotScheduledMatch = {
    team1: TeamInfo;
    team2: TeamInfo;
};
export const NotScheduledMatchIdl = IDL.Record({
    team1: TeamInfoIdl,
    team2: TeamInfoIdl,
});

export type ScheduledMatch = {
    team1: TeamInfo;
    team2: TeamInfo;
    offerings: OfferingWithMetaData[];
    aura: MatchAuraWithMetaData;
};
export const ScheduledMatchIdl = IDL.Record({
    team1: TeamInfoIdl,
    team2: TeamInfoIdl,
    offerings: IDL.Vec(OfferingWithMetaDataIdl),
    aura: MatchAuraWithMetaDataIdl,
});

export type InProgressMatchTeam = TeamInfo & {
    offering: Offering;
    championId: Nat32;
};
export const InProgressMatchTeamIdl = IDL.Record({
    id: IDL.Principal,
    name: IDL.Text,
    logoUrl: IDL.Text,
    offering: OfferingIdl,
    championId: IDL.Nat32,
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
    championId: Nat32;
    score: Int;
};
export const CompletedMatchTeamIdl = IDL.Record({
    id: IDL.Principal,
    name: IDL.Text,
    logoUrl: IDL.Text,
    offering: OfferingIdl,
    championId: IDL.Nat32,
    score: IDL.Int,
});


export type CompletedMatch = {
    team1: CompletedMatchTeam;
    team2: CompletedMatchTeam;
    aura: MatchAura;
    log: LogEntry[];
    winner: TeamIdOrTie;
    error: [string] | [];
};
export const CompletedMatchIdl = IDL.Record({
    team1: CompletedMatchTeamIdl,
    team2: CompletedMatchTeamIdl,
    log: IDL.Vec(LogEntryIdl),
    winner: TeamIdOrTieIdl,
    error: IDL.Opt(IDL.Text),
});

export type CompletedSeasonTeam = TeamInfo & {
    standing: Nat;
    wins: Nat;
    losses: Nat;
};
export const CompletedSeasonTeamIdl = IDL.Record({
    id: IDL.Principal,
    name: IDL.Text,
    logoUrl: IDL.Text,
    standing: IDL.Nat,
    wins: IDL.Nat,
    losses: IDL.Nat,
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
