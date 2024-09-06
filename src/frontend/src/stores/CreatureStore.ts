import { writable } from 'svelte/store';
import { Creature, } from '../ic-agent/declarations/main';
import { mainAgentFactory } from '../ic-agent/Main';

export const creatureStore = (() => {
    const { subscribe, set } = writable<Creature[]>();
    let initialized = false;

    async function refetch() {
        const mainAgent = await mainAgentFactory();
        const creatures = await mainAgent.getCreatures();
        set(creatures);
    }

    return {
        subscribe: (run: (value: Creature[]) => void, invalidate?: (value?: Creature[]) => void): (() => void) => {
            if (!initialized) {
                initialized = true;
                refetch();
            }
            return subscribe(run, invalidate);
        },
        refetch,
    };
})();