
import { Principal } from "@dfinity/principal";
import { TeamId, TeamIdOrTie } from "./Team";
import { ScenarioInstance, ScenarioInstanceWithChoice } from "./Scenario";


export type MatchGroupDetails = {
    id: number;
    time: bigint;
    matches: MatchDetails[];
    state: 'NotScheduled' | 'Scheduled' | 'InProgress' | 'Completed';
};

export type MatchDetails = {
    id: number;
    time: bigint;
    matchGroupId: number;
    team1: TeamDetailsOrUndetermined;
    team2: TeamDetailsOrUndetermined;
    winner: TeamIdOrTie | undefined;
    state: MatchState;
    predictions: Map<string, TeamId>;
};
export type MatchState = 'NotScheduled' | 'Scheduled' | 'InProgress' | 'Played' | 'Error';

export type TeamDetails = {
    id: Principal;
    name: string;
    logoUrl: string;
    score: number | undefined;
    scenario: ScenarioInstance | ScenarioInstanceWithChoice | undefined;
};

export type TeamDetailsOrUndetermined =
    | TeamDetails
    | { winnerOfMatch: number }
    | { seasonStandingIndex: number };