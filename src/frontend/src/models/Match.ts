
import { Principal } from "@dfinity/principal";
import { TeamId, TeamIdOrTie } from "./Team";
import { OfferingWithMetaData } from "./Offering";


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
    offeringOptions: OfferingWithMetaData[] | undefined;
    winner: TeamIdOrTie | undefined;
    state: MatchState;
    predictions: Map<Principal, TeamId>;
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