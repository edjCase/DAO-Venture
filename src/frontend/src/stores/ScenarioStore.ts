import { writable } from 'svelte/store';
import { type Scenario } from "../ic-agent/declarations/main";
import { mainAgentFactory } from "../ic-agent/Main";

export const scenarioStore = (() => {
    const { subscribe, set, update } = writable<Scenario[]>();

    const refetchById = async (id: bigint) => {
        const mainAgent = await mainAgentFactory();
        const result = await mainAgent.getScenario(id);
        if ('ok' in result) {
            update((scenarios) => {
                const index = scenarios.findIndex((s) => s.id === id);
                if (index !== -1) {
                    scenarios[index] = result.ok;
                }
                return scenarios;
            });
        } else {
            console.error("Failed to get scenario " + id, result.err)
        }
    }

    const refetch = async () => {
        const mainAgent = await mainAgentFactory();
        const result = await mainAgent.getScenarios();
        if ('ok' in result) {
            set(result.ok);
        } else {
            console.error("Failed to get scenarios", result.err);
        }
    };

    refetch();


    return {
        subscribe,
        refetch,
        refetchById,
    };
})();