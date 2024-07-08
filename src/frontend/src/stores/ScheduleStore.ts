import { writable } from "svelte/store";
import { mainAgentFactory } from "../ic-agent/Main";
import {
    CompletedMatch,
    InProgressMatch,
    InProgressSeasonMatchGroupVariant,
    NotScheduledMatch,
    ScheduledMatch,
    SeasonStatus,
    TeamAssignment,
} from "../ic-agent/declarations/main";
import { MatchDetails, MatchGroupDetails, TeamDetailsOrUndetermined, TeamDetailsWithScore } from "../models/Match";

type MatchVariant =
    | { completed: CompletedMatch }
    | { inProgress: InProgressMatch }
    | { scheduled: ScheduledMatch }
    | { notScheduled: NotScheduledMatch };

export const scheduleStore = (() => {
    const { subscribe: subscribeStatus, set: setStatus } = writable<SeasonStatus | undefined>();
    const { subscribe: subscribeMatchGroups, set: setMatchGroups } = writable<MatchGroupDetails[]>([]);

    const mapTeamAssignment = (
        team: TeamAssignment
    ): TeamDetailsOrUndetermined => {
        if ('predetermined' in team) {
            return mapTeam(team.predetermined, undefined);
        } else if ('winnerOfMatch' in team) {
            return { winnerOfMatch: Number(team.winnerOfMatch) };
        } else {
            return { seasonStandingIndex: Number(team.seasonStandingIndex) };
        }
    };
    const mapTeam = (
        id: bigint,
        score: bigint | undefined
    ): TeamDetailsWithScore => {
        return {
            id: id,
            score: score
        };
    };
    const mapMatch = (
        index: number,
        matchGroupId: bigint,
        time: bigint,
        match: MatchVariant
    ): MatchDetails => {
        let id = BigInt(index);
        if ('completed' in match) {
            return {
                id: id,
                time: time,
                matchGroupId: matchGroupId,
                state: "Played",
                team1: mapTeam(match.completed.team1.id, match.completed.team1.score),
                team2: mapTeam(match.completed.team2.id, match.completed.team2.score),
                winner: match.completed.winner
            };
        } else if ('inProgress' in match) {
            return {
                id: id,
                time: time,
                matchGroupId: matchGroupId,
                state: 'InProgress',
                team1: mapTeam(match.inProgress.team1.id, undefined),
                team2: mapTeam(match.inProgress.team2.id, undefined),
                winner: undefined,
            };
        }
        else if ('scheduled' in match) {
            return {
                id: id,
                time: time,
                matchGroupId: matchGroupId,
                state: 'Scheduled',
                team1: mapTeam(match.scheduled.team1.id, undefined),
                team2: mapTeam(match.scheduled.team2.id, undefined),
                winner: undefined
            };
        }
        else {
            return {
                id: id,
                time: time,
                matchGroupId: matchGroupId,
                state: 'NotScheduled',
                team1: mapTeamAssignment(match.notScheduled.team1),
                team2: mapTeamAssignment(match.notScheduled.team2),
                winner: undefined
            };
        }
    };

    const mapMatchGroup = (matchGroupIndex: number, matchGroup: InProgressSeasonMatchGroupVariant): MatchGroupDetails => {
        let id = BigInt(matchGroupIndex);
        if ('completed' in matchGroup) {
            return {
                id: id,
                time: matchGroup.completed.time,
                matches: matchGroup.completed.matches.map((match, matchIndex) => (mapMatch(matchIndex, id, matchGroup.completed.time, { completed: match }))),
                state: 'Completed'
            };
        } else if ('inProgress' in matchGroup) {
            return {
                id: id,
                time: matchGroup.inProgress.time,
                matches: matchGroup.inProgress.matches.map((match, matchIndex) => (mapMatch(matchIndex, id, matchGroup.inProgress.time, { inProgress: match }))),
                state: 'InProgress'
            };
        } else if ('scheduled' in matchGroup) {
            return {
                id: id,
                time: matchGroup.scheduled.time,
                matches: matchGroup.scheduled.matches.map((match, matchIndex) => (mapMatch(matchIndex, id, matchGroup.scheduled.time, { scheduled: match }))),
                state: 'Scheduled'
            };
        } else {
            return {
                id: id,
                time: matchGroup.notScheduled.time,
                matches: matchGroup.notScheduled.matches.map((match, matchIndex) => (mapMatch(matchIndex, id, matchGroup.notScheduled.time, { notScheduled: match }))),
                state: 'NotScheduled'
            };
        }
    };

    const refetch = async () => {
        let mainAgent = await mainAgentFactory();
        let status = await mainAgent
            .getSeasonStatus();
        setStatus(status);
        let matchGroups: MatchGroupDetails[] = [];
        if ('inProgress' in status) {
            matchGroups = status.inProgress.matchGroups.map((matchGroup, index) => {
                return mapMatchGroup(index, matchGroup);
            });
        } else if ('completed' in status) {
            matchGroups = status.completed.matchGroups.map((matchGroup, index) => {
                return mapMatchGroup(index, { completed: matchGroup });
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

