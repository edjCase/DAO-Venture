import { writable } from "svelte/store";
import { CompletedMatchGroupState, InProgressMatchGroupState, MatchGroupSchedule, MatchSchedule, ScheduleMatchGroupError, SeasonStatus, leagueAgentFactory } from "../ic-agent/League";
import { Principal } from "@dfinity/principal";
import { TeamId, TeamIdOrTie } from "../ic-agent/Stadium";
import { nanosecondsToDate } from "../utils/DateUtils";



export type SeasonMatchGroups = {
    completed: CompletedMatchGroupVariant[];
    live: LiveMatchGroup | undefined;
    upcoming: UpcomingMatchGroup[];
};
type MatchGroupCommon = {
    id: number;
    time: Date;
};
type MatchCommon = {
    index: number;
    team1Id: Principal;
    team2Id: Principal;
};
export type CompletedMatchGroupVariant =
    | { played: PlayedMatchGroup }
    | { canceled: null }
    | { scheduleError: ScheduleMatchGroupError };

export type PlayedMatchGroup = MatchGroupCommon & {
    matches: CompletedMatchVariant[];
};
export type CompletedMatchVariant =
    | { played: PlayedMatch }
    | { absentTeam: TeamId }
    | { allAbsent: null };

export type PlayedMatch = MatchCommon & {
    team1Score: bigint | undefined;
    team2Score: bigint | undefined;
    winner: TeamIdOrTie | undefined;
};

export type LiveMatchGroup = MatchGroupCommon & {
    matches: LiveMatch[];
};
export type StartedMatchVariant =
    | { live: LiveMatch }
    | { completed: CompletedMatchVariant };
export type LiveMatch = MatchCommon & {
};

export type UpcomingMatchGroup = MatchGroupCommon & {
    matches: UpcomingMatch[];
};
export type UpcomingMatch = MatchCommon & {
};

export type MatchGroupVariant =
    | { completed: CompletedMatchGroupVariant }
    | { live: LiveMatchGroup }
    | { upcoming: UpcomingMatchGroup };
export type MatchVariant =
    | { completed: CompletedMatchVariant }
    | { live: LiveMatch }
    | { upcoming: UpcomingMatch };


export const scheduleStore = (() => {
    const { subscribe: subscribeStatus, set: setStatus } = writable<SeasonStatus>();
    const { subscribe: subscribeMatchGroups, set: setMatchGroups } = writable<SeasonMatchGroups | undefined>();


    const refetch = async () => {
        return leagueAgentFactory()
            .getSeasonStatus()
            .then((status: SeasonStatus) => {
                setStatus(status);
                if ('inProgress' in status) {
                    let completed: CompletedMatchGroupVariant[] = [];
                    let live: LiveMatchGroup | undefined;
                    let upcoming: UpcomingMatchGroup[] = [];
                    for (let matchGroup of status.inProgress.matchGroups) {
                        if ('completed' in matchGroup.status) {
                            completed.push(mapCompletedMatchGroup(
                                matchGroup,
                                matchGroup.status.completed
                            ));
                        } else if ('inProgress' in matchGroup.status) {
                            live = mapInProgressMatchGroup(matchGroup, matchGroup.status.inProgress);
                        } else if ('notStarted' in matchGroup.status) {
                            upcoming.push(mapNotStartedMatchGroup(
                                matchGroup,
                                matchGroup.status.notStarted
                            ));
                        }
                    }
                    setMatchGroups({
                        completed: completed,
                        live: live,
                        upcoming: upcoming
                    });
                } else if ('completed' in status) {
                    let completed: CompletedMatchGroupVariant[] = status.completed.matchGroups
                        .map((matchGroup) => {
                            return mapCompletedMatchGroup(
                                matchGroup,
                                matchGroup.status
                            );
                        });
                    setMatchGroups({
                        completed: completed,
                        live: undefined,
                        upcoming: []
                    });
                } else {
                    setMatchGroups(undefined);
                }
            });
    };

    refetch();


    return {
        subscribeStatus,
        subscribeMatchGroups,
        refetch
    };
})();


function mapCompletedMatchGroup(
    matchGroup: MatchGroupSchedule,
    state: CompletedMatchGroupState
): CompletedMatchGroupVariant {
    if ('played' in state) {
        let mappedMatches = matchGroup.matches
            .map((matchSchedule: MatchSchedule, i: number): CompletedMatchVariant => {
                let completedMatch = state.played.matches[i];
                if ('played' in completedMatch.state) {
                    return {
                        played: {
                            index: i,
                            team1Id: matchSchedule.team1Id,
                            team2Id: matchSchedule.team2Id,
                            team1Score: completedMatch.state.played.team1.score,
                            team2Score: completedMatch.state.played.team2.score,
                            winner: completedMatch.state.played.winner
                        }
                    };
                } else if ('absentTeam' in completedMatch.state) {
                    return {
                        absentTeam: completedMatch.state.absentTeam
                    };
                } else {
                    return {
                        allAbsent: null
                    };
                }
            });
        return {
            'played': {
                id: matchGroup.id,
                time: nanosecondsToDate(matchGroup.time),
                matches: mappedMatches
            }
        };
    } else if ('canceled' in state) {
        return {
            canceled: null
        };
    } else {
        return {
            scheduleError: state.scheduleError
        };
    }
};


function mapInProgressMatchGroup(
    matchGroup: MatchGroupSchedule,
    inProgress: InProgressMatchGroupState
): LiveMatchGroup {
    let mappedMatches: StartedMatchVariant[] = matchGroup.matches
        .map((matchSchedule: MatchSchedule, i: number): StartedMatchVariant => {
            let inProgressMatch = inProgress.matches[i];
            if ('live' in startedMatch.state) {
                return {
                    live: {
                        index: i,
                        team1Id: matchSchedule.team1Id,
                        team2Id: matchSchedule.team2Id
                    }
                };
            } else if ('completed' in startedMatch.state) {
                return {
                    completed: {
                        played: {
                            index: i,
                            team1Id: matchSchedule.team1Id,
                            team2Id: matchSchedule.team2Id,
                            team1Score: startedMatch.state.completed.team1.score,
                            team2Score: startedMatch.state.completed.team2.score,
                            winner: startedMatch.state.completed.winner
                        }
                    }
                };
            } else {
                throw new Error('Unexpected match state');
            }
        });
    return {
        id: matchGroup.id,
        time: nanosecondsToDate(matchGroup.time),
        matches: mappedMatches
    };
}

function mapNotStartedMatchGroup(matchGroup: MatchGroupSchedule, notStarted: unknown): UpcomingMatchGroup {

}

