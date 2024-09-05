import { writable } from 'svelte/store';
import { Trait } from '../ic-agent/declarations/main';
import { mainAgentFactory } from '../ic-agent/Main';

export const traitStore = (() => {
    const { subscribe, set } = writable<Trait[]>();
    let initialized = false;

    async function refetch() {
        const mainAgent = await mainAgentFactory();
        const traits = await mainAgent.getTraits();
        set(traits);
    }

    return {
        subscribe: (run: (value: Trait[]) => void, invalidate?: (value?: Trait[]) => void): (() => void) => {
            if (!initialized) {
                initialized = true;
                refetch();
            }
            return subscribe(run, invalidate);
        },
        refetch,
    };
})();