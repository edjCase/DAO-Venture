import { TeamIdOrTie } from "../ic-agent/declarations/league";


export type MatchGroupDetails = {
    id: number;
    time: bigint;
    matches: MatchDetails[];
    state: 'NotScheduled' | 'Scheduled' | 'InProgress' | 'Completed';
    scenarioId: string;
};

export type MatchDetails = {
    id: bigint;
    time: bigint;
    matchGroupId: bigint;
    team1: TeamDetailsOrUndetermined;
    team2: TeamDetailsOrUndetermined;
    winner: TeamIdOrTie | undefined;
    state: MatchState;
};
export type MatchState = 'NotScheduled' | 'Scheduled' | 'InProgress' | 'Played' | 'Error';

export type TeamDetails = {
    id: bigint;
    name: string;
    logoUrl: string;
};

export type TeamDetailsWithScore = TeamDetails & { score: bigint | undefined };

export type TeamDetailsOrUndetermined =
    | TeamDetails
    | { winnerOfMatch: number }
    | { seasonStandingIndex: number };