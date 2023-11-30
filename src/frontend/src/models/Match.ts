
import { Principal } from "@dfinity/principal";
import { TeamIdOrTie } from "./Team";


export type MatchGroupDetails = {
    id: bigint;
    time: bigint;
    matches: MatchDetails[];
    state: 'NotScheduled' | 'Scheduled' | 'InProgress' | 'Completed';
};

export type MatchDetails = {
    id: bigint;
    time: bigint;
    matchGroupId: bigint;
    team1: TeamDetails;
    team2: TeamDetails;
    winner: TeamIdOrTie | undefined;
    state: MatchState;
};
export type MatchState = 'NotScheduled' | 'Scheduled' | 'InProgress' | 'Played' | 'AllAbsent' | 'Team1Absent' | 'Team2Absent' | 'Error';

export type TeamDetails = {
    id: Principal;
    name: string;
    logoUrl: string;
    score: bigint | undefined;
};
