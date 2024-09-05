import { writable } from 'svelte/store';
import { Weapon } from '../ic-agent/declarations/main';
import { mainAgentFactory } from '../ic-agent/Main';

export const weaponStore = (() => {
    const { subscribe, set } = writable<Weapon[]>();
    let initialized = false;

    async function refetch() {
        const mainAgent = await mainAgentFactory();
        const weapons = await mainAgent.getWeapons();
        set(weapons);
    }

    return {
        subscribe: (run: (value: Weapon[]) => void, invalidate?: (value?: Weapon[]) => void): (() => void) => {
            if (!initialized) {
                initialized = true;
                refetch();
            }
            return subscribe(run, invalidate);
        },
        refetch,
    };
})();