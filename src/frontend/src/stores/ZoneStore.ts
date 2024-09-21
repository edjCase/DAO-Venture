import { writable } from 'svelte/store';
import { Zone } from '../ic-agent/declarations/main';
import { mainAgentFactory } from '../ic-agent/Main';

export const zoneStore = (() => {
    const { subscribe, set } = writable<Zone[]>();
    let initialized = false;

    async function refetch() {
        const mainAgent = await mainAgentFactory();
        const zones = await mainAgent.getZones();
        set(zones);
    }

    return {
        subscribe: (run: (value: Zone[]) => void, invalidate?: (value?: Zone[]) => void): (() => void) => {
            if (!initialized) {
                initialized = true;
                refetch();
            }
            return subscribe(run, invalidate);
        },
        refetch,
    };
})();