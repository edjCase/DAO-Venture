import { writable } from 'svelte/store';
import { Class } from '../ic-agent/declarations/main';
import { mainAgentFactory } from '../ic-agent/Main';

export const classStore = (() => {
    const { subscribe, set } = writable<Class[]>();
    let initialized = false;

    async function refetch() {
        const mainAgent = await mainAgentFactory();
        const classes = await mainAgent.getClasses();
        set(classes);
    }

    return {
        subscribe: (run: (value: Class[]) => void, invalidate?: (value?: Class[]) => void): (() => void) => {
            if (!initialized) {
                initialized = true;
                refetch();
            }
            return subscribe(run, invalidate);
        },
        refetch,
    };
})();