import { writable } from "svelte/store";
import { leagueAgentFactory } from "../ic-agent/League";
import {
    CompletedMatch,
    InProgressMatch,
    InProgressSeasonMatchGroupVariant,
    NotScheduledMatch,
    ScheduledMatch,
    SeasonStatus,
    TeamAssignment,
} from "../ic-agent/declarations/league";
import { MatchDetails, MatchGroupDetails, TeamDetails, TeamDetailsOrUndetermined, TeamDetailsWithScore } from "../models/Match";

type MatchVariant =
    | { completed: CompletedMatch }
    | { inProgress: InProgressMatch }
    | { scheduled: ScheduledMatch }
    | { notScheduled: NotScheduledMatch };

export const scheduleStore = (() => {
    const { subscribe: subscribeStatus, set: setStatus } = writable<SeasonStatus | undefined>();
    const { subscribe: subscribeMatchGroups, set: setMatchGroups } = writable<MatchGroupDetails[]>([]);

    const getTeam = (id: bigint, teams: TeamDetails[]): TeamDetails => {
        const foundTeam = teams.find((t) => t.id === id);
        if (foundTeam) {
            return foundTeam;
        } else {
            throw new Error('Team not found');
        }
    };

    const mapTeamAssignment = (
        team: TeamAssignment,
        teams: TeamDetails[]
    ): TeamDetailsOrUndetermined => {
        if ('predetermined' in team) {
            return getTeam(team.predetermined, teams);
        } else if ('winnerOfMatch' in team) {
            return { winnerOfMatch: Number(team.winnerOfMatch) };
        } else {
            return { seasonStandingIndex: Number(team.seasonStandingIndex) };
        }
    };
    const mapTeam = (
        id: bigint,
        score: bigint | undefined,
        teams: TeamDetails[]
    ): TeamDetailsWithScore => {
        let team = getTeam(id, teams);
        return {
            ...team,
            score: score
        };
    };
    const mapMatch = (
        index: number,
        matchGroupId: bigint,
        time: bigint,
        match: MatchVariant,
        teams: TeamDetails[]
    ): MatchDetails => {
        let id = BigInt(index);
        if ('completed' in match) {
            return {
                id: id,
                time: time,
                matchGroupId: matchGroupId,
                state: "Played",
                team1: mapTeam(match.completed.team1.id, match.completed.team1.score, teams),
                team2: mapTeam(match.completed.team2.id, match.completed.team2.score, teams),
                winner: match.completed.winner
            };
        } else if ('inProgress' in match) {
            return {
                id: id,
                time: time,
                matchGroupId: matchGroupId,
                state: 'InProgress',
                team1: mapTeam(match.inProgress.team1.id, undefined, teams),
                team2: mapTeam(match.inProgress.team2.id, undefined, teams),
                winner: undefined,
            };
        }
        else if ('scheduled' in match) {
            return {
                id: id,
                time: time,
                matchGroupId: matchGroupId,
                state: 'Scheduled',
                team1: mapTeam(match.scheduled.team1.id, undefined, teams),
                team2: mapTeam(match.scheduled.team2.id, undefined, teams),
                winner: undefined
            };
        }
        else {
            return {
                id: id,
                time: time,
                matchGroupId: matchGroupId,
                state: 'NotScheduled',
                team1: mapTeamAssignment(match.notScheduled.team1, teams),
                team2: mapTeamAssignment(match.notScheduled.team2, teams),
                winner: undefined
            };
        }
    };

    const mapMatchGroup = (matchGroupIndex: number, matchGroup: InProgressSeasonMatchGroupVariant, teams: TeamDetails[]): MatchGroupDetails => {
        let id = BigInt(matchGroupIndex);
        if ('completed' in matchGroup) {
            return {
                id: id,
                time: matchGroup.completed.time,
                matches: matchGroup.completed.matches.map((match, matchIndex) => (mapMatch(matchIndex, id, matchGroup.completed.time, { completed: match }, teams))),
                state: 'Completed'
            };
        } else if ('inProgress' in matchGroup) {
            return {
                id: id,
                time: matchGroup.inProgress.time,
                matches: matchGroup.inProgress.matches.map((match, matchIndex) => (mapMatch(matchIndex, id, matchGroup.inProgress.time, { inProgress: match }, teams))),
                state: 'InProgress'
            };
        } else if ('scheduled' in matchGroup) {
            return {
                id: id,
                time: matchGroup.scheduled.time,
                matches: matchGroup.scheduled.matches.map((match, matchIndex) => (mapMatch(matchIndex, id, matchGroup.scheduled.time, { scheduled: match }, teams))),
                state: 'Scheduled'
            };
        } else {
            return {
                id: id,
                time: matchGroup.notScheduled.time,
                matches: matchGroup.notScheduled.matches.map((match, matchIndex) => (mapMatch(matchIndex, id, matchGroup.notScheduled.time, { notScheduled: match }, teams))),
                state: 'NotScheduled'
            };
        }
    };

    const refetch = async () => {
        let leagueAgent = await leagueAgentFactory();
        let status = await leagueAgent
            .getSeasonStatus();
        setStatus(status);
        let matchGroups: MatchGroupDetails[] = [];
        if ('inProgress' in status) {
            let teams = status.inProgress.teams;
            matchGroups = status.inProgress.matchGroups.map((matchGroup, index) => {
                return mapMatchGroup(index, matchGroup, teams);
            });
        } else if ('completed' in status) {
            let teams = status.completed.teams;
            matchGroups = status.completed.matchGroups.map((matchGroup, index) => {
                return mapMatchGroup(index, { completed: matchGroup }, teams);
            });
        } else {
            matchGroups = [];
        }
        // order by id
        matchGroups.sort((a, b) => Number(a.id) - Number(b.id));
        setMatchGroups(matchGroups);
    };

    refetch();


    return {
        subscribeStatus,
        subscribeMatchGroups,
        refetch
    };
})();

