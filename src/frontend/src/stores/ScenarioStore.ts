import { writable, derived, type Readable } from 'svelte/store';
import { type Scenario } from "../ic-agent/declarations/main";
import { mainAgentFactory } from "../ic-agent/Main";


export const scenarioStore = (() => {
    const { subscribe, update } = writable<Record<number, Scenario>>({});

    const getById = (id: bigint) => {
        return derived<Readable<Record<number, Scenario>>, Scenario | undefined>(
            { subscribe },
            $store => $store[Number(id)]
        );
    };

    const refetchById = async (scenarioId: bigint) => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.getScenario(scenarioId);
        if (result.length === 1) {
            let scenario = result[0];
            update(scenarios => ({
                ...scenarios,
                [Number(scenarioId)]: scenario
            }));
        } else {
            console.log("Scenario not found", scenarioId);
        }
    };

    return {
        subscribe,
        getById,
        refetchById,
    };
})();