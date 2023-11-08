
import { Principal } from "@dfinity/principal";
import {
    CompletedMatchGroupState,
    CompletedMatchState,
    InProgressMatchGroupState,
    InProgressMatchState,
    LogEntry,
    Match,
    MatchAura,
    MatchGroup,
    MatchGroupState,
    MatchPlayer,
    MatchTeam,
    NotStartedMatchGroupState,
    StartedMatchState,
    TeamId,
    TeamIdOrTie,
} from "../ic-agent/Stadium";
import { getOfferingDetails } from "../stores/MatchGroupStore";

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

export type OfferingDetails = {
    name: string;
    description: string;
};
export type MatchAuraDetails = OfferingDetails;

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
    offerings: OfferingDetails[];
    aura: MatchAuraDetails;
};
export type MatchGroupDetails = {
    id: number;
    time: bigint;
    matches: MatchDetail[];
    state: MatchGroupStateDetails;
};


let getTeamName = (
    matchGroup: MatchGroup,
    teamId: TeamId | { tie: null } | { both: null } | { team1: null } | { team2: null },
    matchIndex: number
): string => {
    if (!matchGroup) {
        return "Unknown";
    }
    if ("both" in teamId) {
        return "Both Teams";
    } else if ("tie" in teamId) {
        return "Tie";
    } else if ("team1" in teamId) {
        return matchGroup.matches[matchIndex].team1.name;
    } else {
        return matchGroup.matches[matchIndex].team2.name;
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

export const mapAura = (aura: MatchAura): MatchAuraDetails => {
    if ("lowGravity" in aura) {
        return {
            name: "Shuffle And Boost",
            description:
                "Shuffle your team's field positions and boost your team with a random blessing",
        };
    } else if ("explodingBalls" in aura) {
        return {
            name: "Exploding Balls",
            description: "Balls have a chance to explode on contact with the bat",
        };
    } else if ("fastBallsHardHits" in aura) {
        return {
            name: "Fast Balls, Hard Hits",
            description: "Balls are faster and fly farther when hit by the bat",
        };
    } else if ("moreBlessingsAndCurses" in aura) {
        return {
            name: "More Blessings And Curses",
            description: "Blessings and curses are more common",
        };
    } else {
        return {
            name: "Unknown",
            description: "Unknown",
        };
    }
};
export const mapMatch = (match: Match): MatchDetail => {
    return {
        team1: mapTeam(match.team1),
        team2: mapTeam(match.team2),
        offerings: match.offerings.map(getOfferingDetails),
        aura: mapAura(match.aura),
    };
};
export const mapInProgressMatchState = (
    state: InProgressMatchState
): InProgressMatchState => {
    return state;
};
export const mapCompletedMatchState = (
    matchGroup: MatchGroup,
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
                name: getTeamName(matchGroup, state.absentTeam, matchIndex),
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
    matchGroup: MatchGroup,
    state: StartedMatchState,
    matchIndex: number
): StartedMatchStateDetails => {
    if ("inProgress" in state) {
        return { inProgress: mapInProgressMatchState(state.inProgress) };
    } else {
        return { completed: mapCompletedMatchState(matchGroup, state.completed, matchIndex) };
    }
};
export const mapNotStartedState = (
    state: NotStartedMatchGroupState
): NotStartedMatchGroupStateDetails => {
    return state;
};
export const mapInProgressState = (
    matchGroup: MatchGroup,
    state: InProgressMatchGroupState
): InProgressMatchGroupStateDetails => {
    return {
        matches: state.matches.map((m, i) => mapStartedMatchState(matchGroup, m, i)),
    };
};
export const mapCompletedState = (
    matchGroup: MatchGroup,
    state: CompletedMatchGroupState
): CompletedMatchGroupStateDetails => {
    return {
        matches: state.matches.map((m, i) => mapCompletedMatchState(matchGroup, m, i)),
    };
};
export const mapState = (matchGroup: MatchGroup, state: MatchGroupState): MatchGroupStateDetails => {
    if ("inProgress" in state) {
        return { inProgress: mapInProgressState(matchGroup, state.inProgress) };
    } else if ("completed" in state) {
        return { completed: mapCompletedState(matchGroup, state.completed) };
    } else {
        return { notStarted: mapNotStartedState(state.notStarted) };
    }
};
export const mapMatchGroup = (matchGroup: MatchGroup): MatchGroupDetails => {
    return {
        id: matchGroup.id,
        time: matchGroup.time,
        matches: matchGroup.matches.map(mapMatch),
        state: mapState(matchGroup, matchGroup.state),
    };
};