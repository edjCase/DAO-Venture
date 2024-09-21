import { writable } from 'svelte/store';
import { Race } from '../ic-agent/declarations/main';
import { mainAgentFactory } from '../ic-agent/Main';

export const raceStore = (() => {
    const { subscribe, set } = writable<Race[]>();
    let initialized = false;

    async function refetch() {
        const mainAgent = await mainAgentFactory();
        const races = await mainAgent.getRaces();
        set(races);
    }

    return {
        subscribe: (run: (value: Race[]) => void, invalidate?: (value?: Race[]) => void): (() => void) => {
            if (!initialized) {
                initialized = true;
                refetch();
            }
            return subscribe(run, invalidate);
        },
        refetch,
    };
})();