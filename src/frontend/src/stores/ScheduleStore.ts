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
    TeamInfo,
} from "../models/Season";
import { MatchDetails, MatchGroupDetails } from "../models/Match";

type MatchVariant =
    | { completed: CompletedMatch }
    | { inProgress: InProgressMatch }
    | { scheduled: ScheduledMatch }
    | { notScheduled: NotScheduledMatch };

export const scheduleStore = (() => {
    const { subscribe: subscribeStatus, set: setStatus } = writable<SeasonStatus | undefined>();
    const { subscribe: subscribeMatchGroups, set: setMatchGroups } = writable<MatchGroupDetails[]>([]);

    const mapTeamAssignment = (team: TeamAssignment, score: bigint | undefined) => {
        if ('predetermined' in team) {
            return mapTeam(team.predetermined, score);
        } else {
            return undefined
        }
    };
    const mapTeam = (team: TeamInfo, score: bigint | undefined) => {
        return {
            id: team.id,
            name: team.name,
            logoUrl: team.logoUrl,
            score: Number(score)
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
                state: match.completed.error.length == 0 ? "Played" : "Error",
                offeringOptions: undefined,
                team1: mapTeam(match.completed.team1, match.completed.team1.score),
                team2: mapTeam(match.completed.team2, match.completed.team2.score),
                winner: match.completed.winner,
                error: match.completed.error.length == 0 ? undefined : match.completed.error[0]
            };
        } else if ('inProgress' in match) {
            return {
                id: index,
                time: time,
                matchGroupId: matchGroupId,
                state: 'InProgress',
                offeringOptions: undefined,
                team1: mapTeam(match.inProgress.team1, undefined),
                team2: mapTeam(match.inProgress.team2, undefined),
                winner: undefined,
                error: undefined
            };
        }
        else if ('scheduled' in match) {
            return {
                id: index,
                time: time,
                matchGroupId: matchGroupId,
                state: 'Scheduled',
                offeringOptions: match.scheduled.offeringOptions,
                team1: mapTeam(match.scheduled.team1, undefined),
                team2: mapTeam(match.scheduled.team2, undefined),
                winner: undefined,
                error: undefined
            };
        }
        else {
            return {
                id: index,
                time: time,
                matchGroupId: matchGroupId,
                state: 'NotScheduled',
                offeringOptions: undefined,
                team1: mapTeamAssignment(match.notScheduled.team1, undefined),
                team2: mapTeamAssignment(match.notScheduled.team2, undefined),
                winner: undefined,
                error: undefined
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


