import { writable } from 'svelte/store';
import { Item } from '../ic-agent/declarations/main';
import { mainAgentFactory } from '../ic-agent/Main';

export const itemStore = (() => {
    const { subscribe, set } = writable<Item[]>();
    let initialized = false;

    async function refetch() {
        const mainAgent = await mainAgentFactory();
        const items = await mainAgent.getItems();
        set(items);
    }

    return {
        subscribe: (run: (value: Item[]) => void, invalidate?: (value?: Item[]) => void): (() => void) => {
            if (!initialized) {
                initialized = true;
                refetch();
            }
            return subscribe(run, invalidate);
        },
        refetch,
    };
})();