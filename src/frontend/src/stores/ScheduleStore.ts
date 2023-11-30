import { writable } from "svelte/store";
import { leagueAgentFactory } from "../ic-agent/League";
import {
    CompletedMatchGroup,
    InProgressMatchGroup,
    NotScheduledMatchGroup,
    ScheduledMatchGroup,
    SeasonStatus
} from "../models/Season";


export type NotScheduledMatchGroupWithId = NotScheduledMatchGroup & {
    id: number;
};

export type CompletedMatchGroupWithId = CompletedMatchGroup & {
    id: number;
};

export type NextMatchGroupWithId = {
    id: number;
    type:
    | { scheduled: ScheduledMatchGroup }
    | { inProgress: InProgressMatchGroup };
}

export type SeasonMatchGroups = {
    completed: CompletedMatchGroupWithId[];
    next: NextMatchGroupWithId | undefined;
    upcoming: NotScheduledMatchGroupWithId[];
};

export const scheduleStore = (() => {
    const { subscribe: subscribeStatus, set: setStatus } = writable<SeasonStatus>();
    const { subscribe: subscribeMatchGroups, set: setMatchGroups } = writable<SeasonMatchGroups | undefined>();


    const refetch = async () => {
        return leagueAgentFactory()
            .getSeasonStatus()
            .then((status: SeasonStatus) => {
                setStatus(status);
                if ('inProgress' in status) {
                    let completed: CompletedMatchGroupWithId[] = [];
                    let next: NextMatchGroupWithId | undefined;
                    let upcoming: NotScheduledMatchGroupWithId[] = [];
                    let index = 0;
                    for (let matchGroup of status.inProgress.matchGroups) {
                        if ('completed' in matchGroup) {
                            completed.push({ ...matchGroup.completed, id: index });
                        } else if ('inProgress' in matchGroup) {
                            next = { id: index, type: { inProgress: matchGroup.inProgress } };
                        } else if ('scheduled' in matchGroup) {
                            next = { id: index, type: { scheduled: matchGroup.scheduled } };
                        } else if ('notScheduled' in matchGroup) {
                            upcoming.push({ ...matchGroup.notScheduled, id: index });
                        }
                        index += 1;
                    }
                    setMatchGroups({
                        completed: completed,
                        next: next,
                        upcoming: upcoming
                    });
                } else if ('completed' in status) {
                    setMatchGroups({
                        completed: status.completed.matchGroups.map((matchGroup, index) => {
                            return { ...matchGroup, id: index };
                        }),
                        next: undefined,
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


