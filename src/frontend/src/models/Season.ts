import type { Principal } from '@dfinity/principal';
import { IDL } from "@dfinity/candid";
import { Offering, OfferingIdl, OfferingWithMetaData, OfferingWithMetaDataIdl } from './Offering';
import { MatchAura, MatchAuraIdl, MatchAuraWithMetaData, MatchAuraWithMetaDataIdl } from './MatchAura';
import { TeamId, TeamIdIdl, TeamIdOrTie, TeamIdOrTieIdl } from './Team';

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

export type InProgressMatchResult =
    | { started: { team1Offering: Offering; team1ChampionId: Nat32; team2Offering: Offering; team2ChampionId: Nat32; } }
    | { absentTeam: TeamId }
    | { allAbsent: null };
export const InProgressMatchResultIdl = IDL.Variant({
    started: IDL.Record({
        team1Offering: OfferingIdl,
        team1ChampionId: IDL.Nat32,
        team2Offering: OfferingIdl,
        team2ChampionId: IDL.Nat32,
    }),
    absentTeam: TeamIdIdl,
    allAbsent: IDL.Null,
});

export type InProgressMatch = {
    team1: TeamInfo;
    team2: TeamInfo;
    aura: MatchAura;
    result: InProgressMatchResult;
};
export const InProgressMatchIdl = IDL.Record({
    team1: TeamInfoIdl,
    team2: TeamInfoIdl,
    aura: MatchAuraIdl,
    result: InProgressMatchResultIdl,
});

export type PlayedMatchTeamData = {
    offering: Offering;
    championId: Nat32;
    score: Int;
};
export const PlayedMatchTeamDataIdl = IDL.Record({
    offering: OfferingIdl,
    championId: IDL.Nat32,
    score: IDL.Int,
});

export type CompletedMatchResult =
    | { played: { team1: PlayedMatchTeamData; team2: PlayedMatchTeamData; winner: TeamIdOrTie; } }
    | { absentTeam: TeamId }
    | { allAbsent: null }
    | { failed: Text };
export const CompletedMatchResultIdl = IDL.Variant({
    played: IDL.Record({
        team1: PlayedMatchTeamDataIdl,
        team2: PlayedMatchTeamDataIdl,
        winner: TeamIdOrTieIdl,
    }),
    absentTeam: TeamIdIdl,
    allAbsent: IDL.Null,
    failed: IDL.Text,
});

export type CompletedMatch = {
    team1: TeamInfo;
    team2: TeamInfo;
    log: LogEntry[];
    result: CompletedMatchResult;
};
export const CompletedMatchIdl = IDL.Record({
    team1: TeamInfoIdl,
    team2: TeamInfoIdl,
    result: CompletedMatchResultIdl,
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
