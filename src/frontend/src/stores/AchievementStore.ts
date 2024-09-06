import { writable } from 'svelte/store';
import { Achievement } from '../ic-agent/declarations/main';
import { mainAgentFactory } from '../ic-agent/Main';

export const achievementStore = (() => {
    const { subscribe, set } = writable<Achievement[]>();
    let initialized = false;

    async function refetch() {
        const mainAgent = await mainAgentFactory();
        const achievements = await mainAgent.getAchievements();
        set(achievements);
    }

    return {
        subscribe: (run: (value: Achievement[]) => void, invalidate?: (value?: Achievement[]) => void): (() => void) => {
            if (!initialized) {
                initialized = true;
                refetch();
            }
            return subscribe(run, invalidate);
        },
        refetch,
    };
})();