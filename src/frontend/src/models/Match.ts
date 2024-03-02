
import { Principal } from "@dfinity/principal";
import { ResolvedScenario, Scenario, TeamIdOrTie } from "../ic-agent/declarations/league";


export type MatchGroupDetails = {
    id: number;
    time: bigint;
    matches: MatchDetails[];
    state: 'NotScheduled' | 'Scheduled' | 'InProgress' | 'Completed';
    scenario: Scenario | ResolvedScenario;
};

export type MatchDetails = {
    id: number;
    time: bigint;
    matchGroupId: number;
    team1: TeamDetailsOrUndetermined;
    team2: TeamDetailsOrUndetermined;
    winner: TeamIdOrTie | undefined;
    state: MatchState;
};
export type MatchState = 'NotScheduled' | 'Scheduled' | 'InProgress' | 'Played' | 'Error';

export type TeamDetails = {
    id: Principal;
    name: string;
    logoUrl: string;
    score: number | undefined;
};

export type TeamDetailsOrUndetermined =
    | TeamDetails
    | { winnerOfMatch: number }
    | { seasonStandingIndex: number };