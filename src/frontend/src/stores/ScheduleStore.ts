import { writable } from "svelte/store";
import { mainAgentFactory } from "../ic-agent/Main";
import {
    InProgressSeasonMatchGroupVariant,
    SeasonStatus,
} from "../ic-agent/declarations/main";


export const scheduleStore = (() => {
    const { subscribe: subscribeStatus, set: setStatus } = writable<SeasonStatus | undefined>();
    const { subscribe: subscribeMatchGroups, set: setMatchGroups } = writable<InProgressSeasonMatchGroupVariant[]>([]);


    const refetch = async () => {
        let mainAgent = await mainAgentFactory();
        let status = await mainAgent
            .getSeasonStatus();
        setStatus(status);
        let matchGroups: InProgressSeasonMatchGroupVariant[] = [];
        if ('inProgress' in status) {
            matchGroups = status.inProgress.matchGroups;
        } else if ('completed' in status) {
            matchGroups = status.completed.completedMatchGroups.map((mg) => {
                return { completed: mg };
            });
        } else {
            matchGroups = [];
        }
        setMatchGroups(matchGroups);
    };

    refetch();


    return {
        subscribeStatus,
        subscribeMatchGroups,
        refetch
    };
})();

