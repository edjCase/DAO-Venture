
import { Principal } from "@dfinity/principal";
import {
    CompletedMatchGroupState,
    CompletedMatchState,
    InProgressMatchGroupState,
    InProgressMatchState,
    LogEntry,
    Match,
    MatchAuraWithMetaData,
    LiveMatchGroup,
    MatchGroupState,
    MatchPlayer,
    MatchTeam,
    NotStartedMatchGroupState,
    OfferingWithMetaData,
    StartedMatchState,
    TeamId,
    TeamIdOrTie,
} from "../ic-agent/Stadium";


export type PlayedTeamDetails = {
    score: bigint;
};
export type PlayedMatchStateDetails = {
    team1: PlayedTeamDetails;
    team2: PlayedTeamDetails;
    winner: TeamIdOrTie;
    log: LogEntry[];
};
export type CompletedMatchStateDetails =
    | { allAbsent: null }
    | { absentTeam: { name: string } }
    | { played: PlayedMatchStateDetails }
    | { stateBroken: string };

export type StartedMatchStateDetails =
    | { completed: CompletedMatchStateDetails }
    | { inProgress: InProgressMatchState };

export type CompletedMatchGroupStateDetails = {
    matches: CompletedMatchStateDetails[];
};
export type InProgressMatchGroupStateDetails = {
    matches: StartedMatchStateDetails[];
};
export type NotStartedMatchGroupStateDetails = {};
export type MatchGroupStateDetails =
    | { notStarted: NotStartedMatchGroupStateDetails }
    | { completed: CompletedMatchGroupStateDetails }
    | { inProgress: InProgressMatchGroupStateDetails };


export type MatchPlayerDetails = {
    id: number;
    name: string;
};

export type TeamDetails = {
    id: Principal;
    name: string;
    logoUrl: string;
    predictionVotes: bigint;
    players: MatchPlayerDetails[];
};
export type MatchDetail = {
    team1: TeamDetails;
    team2: TeamDetails;
    offerings: OfferingWithMetaData[];
    aura: MatchAuraWithMetaData;
};
export type MatchGroupDetails = {
    id: number;
    time: bigint;
    matches: MatchDetail[];
    state: MatchGroupStateDetails;
};


let getTeamName = (
    matchDetails: MatchDetail[],
    teamId: TeamId | { tie: null } | { both: null } | { team1: null } | { team2: null },
    matchIndex: number
): string => {
    if (!matchDetails) {
        return "Unknown";
    }
    if ("both" in teamId) {
        return "Both Teams";
    } else if ("tie" in teamId) {
        return "Tie";
    } else if ("team1" in teamId) {
        return matchDetails[matchIndex].team1.name;
    } else {
        return matchDetails[matchIndex].team2.name;
    }
};

export const mapMatchPlayer = (player: MatchPlayer): MatchPlayerDetails => {
    return {
        id: player.id,
        name: player.name,
    };
}

export const mapTeam = (team: MatchTeam): TeamDetails => {
    return {
        id: team.id,
        name: team.name,
        logoUrl: team.logoUrl,
        predictionVotes: team.predictionVotes,
        players: team.players.map(mapMatchPlayer)
    };
};

export const mapMatch = (match: Match): MatchDetail => {
    return {
        team1: mapTeam(match.team1),
        team2: mapTeam(match.team2),
        offerings: match.offerings,
        aura: match.aura,
    };
};
export const mapInProgressMatchState = (
    state: InProgressMatchState
): InProgressMatchState => {
    return state;
};
export const mapCompletedMatchState = (
    matches: MatchDetail[],
    state: CompletedMatchState,
    matchIndex: number
): CompletedMatchStateDetails => {
    if ("played" in state) {
        return {
            played: {
                team1: state.played.team1,
                team2: state.played.team2,
                winner: state.played.winner,
                log: state.played.log,
            },
        };
    } else if ("allAbsent" in state) {
        return {
            allAbsent: null,
        };
    } else if ("absentTeam" in state) {
        return {
            absentTeam: {
                name: getTeamName(matches, state.absentTeam, matchIndex),
            },
        };
    }
    else {
        let reason: string;
        if ('playerNotFound' in state.stateBroken.error) {
            reason = "Player not found: " + state.stateBroken.error.playerNotFound.id + " TeamId: " + (state.stateBroken.error.playerNotFound.teamId.length == 0 ? "Either" : ('team1' in state.stateBroken.error.playerNotFound.teamId[0] ? "Team 1" : "Team 2"));
        } else {
            reason = "Player expected on the field: " + state.stateBroken.error.playerExpectedOnField.id + " OnOffense: " + state.stateBroken.error.playerExpectedOnField.onOffense + " Description: " + state.stateBroken.error.playerExpectedOnField.description;
        }
        return {
            stateBroken: reason
        }
    }
};
export const mapStartedMatchState = (
    matches: MatchDetail[],
    state: StartedMatchState,
    matchIndex: number
): StartedMatchStateDetails => {
    if ("inProgress" in state) {
        return { inProgress: mapInProgressMatchState(state.inProgress) };
    } else {
        return { completed: mapCompletedMatchState(matches, state.completed, matchIndex) };
    }
};
export const mapNotStartedState = (
    state: NotStartedMatchGroupState
): NotStartedMatchGroupStateDetails => {
    return state;
};
export const mapInProgressState = (
    matches: MatchDetail[],
    state: InProgressMatchGroupState
): InProgressMatchGroupStateDetails => {
    return {
        matches: state.matches.map((m, i) => mapStartedMatchState(matches, m, i)),
    };
};
export const mapCompletedState = (
    matches: MatchDetail[],
    state: CompletedMatchGroupState
): CompletedMatchGroupStateDetails => {
    return {
        matches: state.matches.map((m, i) => mapCompletedMatchState(matches, m, i)),
    };
};
export const mapState = (matches: MatchDetail[], state: MatchGroupState): MatchGroupStateDetails => {
    if ("inProgress" in state) {
        return { inProgress: mapInProgressState(matches, state.inProgress) };
    } else if ("completed" in state) {
        return { completed: mapCompletedState(matches, state.completed) };
    } else {
        return { notStarted: mapNotStartedState(state.notStarted) };
    }
};
export const mapMatchGroup = (matchGroup: LiveMatchGroup): MatchGroupDetails => {
    let matches = matchGroup.matches.map(mapMatch);
    return {
        id: matchGroup.id,
        time: matchGroup.time,
        matches: matches,
        state: mapState(matches, matchGroup.state),
    };
};