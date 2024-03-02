import { writable } from "svelte/store";
import { leagueAgentFactory } from "../ic-agent/League";
import {
    CompletedMatch,
    InProgressMatch,
    InProgressSeasonMatchGroupVariant,
    NotScheduledMatch,
    ResolvedScenario,
    ScheduledMatch,
    SeasonStatus,
    TeamAssignment,
    TeamInfo,
} from "../ic-agent/declarations/league";
import { MatchDetails, MatchGroupDetails, TeamDetails, TeamDetailsOrUndetermined } from "../models/Match";
import { Scenario } from "../ic-agent/declarations/league";

type MatchVariant =
    | { completed: CompletedMatch }
    | { inProgress: InProgressMatch }
    | { scheduled: ScheduledMatch }
    | { notScheduled: NotScheduledMatch };

export const scheduleStore = (() => {
    const { subscribe: subscribeStatus, set: setStatus } = writable<SeasonStatus | undefined>();
    const { subscribe: subscribeMatchGroups, set: setMatchGroups } = writable<MatchGroupDetails[]>([]);

    const mapTeamAssignment = (team: TeamAssignment, score: bigint | undefined): TeamDetailsOrUndetermined => {
        if ('predetermined' in team) {
            return mapTeam(team.predetermined, undefined, score);
        } else if ('winnerOfMatch' in team) {
            return { winnerOfMatch: Number(team.winnerOfMatch) };
        } else {
            return { seasonStandingIndex: Number(team.seasonStandingIndex) };
        }
    };
    const mapTeam = (
        team: TeamInfo,
        scenario: Scenario | ResolvedScenario | undefined,
        score: bigint | undefined
    ): TeamDetails => {
        return {
            id: team.id,
            name: team.name,
            logoUrl: team.logoUrl,
            score: score != undefined ? Number(score) : undefined,
            scenario: scenario
        };
    };
    const mapMatch = (
        index: number,
        matchGroupId: number,
        time: bigint,
        match: MatchVariant
    ): MatchDetails => {
        if ('completed' in match) {
            return {
                id: index,
                time: time,
                matchGroupId: matchGroupId,
                state: "Played",
                team1: mapTeam(match.completed.team1, match.completed.team1.scenario, match.completed.team1.score),
                team2: mapTeam(match.completed.team2, match.completed.team2.scenario, match.completed.team2.score),
                winner: match.completed.winner
            };
        } else if ('inProgress' in match) {
            return {
                id: index,
                time: time,
                matchGroupId: matchGroupId,
                state: 'InProgress',
                team1: mapTeam(match.inProgress.team1, match.inProgress.team1.scenario, undefined),
                team2: mapTeam(match.inProgress.team2, match.inProgress.team2.scenario, undefined),
                winner: undefined,
            };
        }
        else if ('scheduled' in match) {
            return {
                id: index,
                time: time,
                matchGroupId: matchGroupId,
                state: 'Scheduled',
                team1: mapTeam(match.scheduled.team1, match.scheduled.team1.scenario, undefined),
                team2: mapTeam(match.scheduled.team2, match.scheduled.team2.scenario, undefined),
                winner: undefined
            };
        }
        else {
            return {
                id: index,
                time: time,
                matchGroupId: matchGroupId,
                state: 'NotScheduled',
                team1: mapTeamAssignment(match.notScheduled.team1, undefined),
                team2: mapTeamAssignment(match.notScheduled.team2, undefined),
                winner: undefined
            };
        }
    };

    const mapMatchGroup = (matchGroupIndex: number, matchGroup: InProgressSeasonMatchGroupVariant): MatchGroupDetails => {
        let id = matchGroupIndex;
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
        return leagueAgentFactory()
            .getSeasonStatus()
            .then((status: SeasonStatus) => {
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
            });
    };

    refetch();


    return {
        subscribeStatus,
        subscribeMatchGroups,
        refetch
    };
})();

