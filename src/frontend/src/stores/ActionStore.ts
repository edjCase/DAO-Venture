import { writable } from 'svelte/store';
import { Action } from '../ic-agent/declarations/main';
import { mainAgentFactory } from '../ic-agent/Main';

export const actionStore = (() => {
    const { subscribe, set } = writable<Action[]>();
    let initialized = false;

    async function refetch() {
        const mainAgent = await mainAgentFactory();
        const actions = await mainAgent.getActions();
        set(actions);
    }

    return {
        subscribe: (run: (value: Action[]) => void, invalidate?: (value?: Action[]) => void): (() => void) => {
            if (!initialized) {
                initialized = true;
                refetch();
            }
            return subscribe(run, invalidate);
        },
        refetch,
    };
})();