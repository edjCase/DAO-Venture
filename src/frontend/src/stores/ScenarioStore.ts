import { writable, derived, type Readable } from 'svelte/store';
import { type Scenario } from "../ic-agent/declarations/main";
import { mainAgentFactory } from "../ic-agent/Main";

export const scenarioStore = (() => {
    const { subscribe, update } = writable<Record<number, Scenario>>({});

    const getById = (id: bigint): Readable<Scenario | undefined> => {
        const numId = Number(id);
        return {
            subscribe: (run: (value: Scenario | undefined) => void) => {
                const unsubscribe = derived<Readable<Record<number, Scenario>>, Scenario | undefined>(
                    { subscribe },
                    $store => $store[numId]
                ).subscribe(run);

                // Fetch the scenario if it's not already in the store
                update(scenarios => {
                    if (!(numId in scenarios)) {
                        refetchById(id);
                    }
                    return scenarios;
                });

                return unsubscribe;
            }
        };
    };

    const refetchById = async (scenarioId: bigint) => {
        try {
            let mainAgent = await mainAgentFactory();
            let result = await mainAgent.getScenario(scenarioId);
            if ('ok' in result) {
                let scenario = result.ok;
                update(scenarios => ({
                    ...scenarios,
                    [Number(scenarioId)]: scenario
                }));
            } else {
                console.log("Scenario not found", scenarioId);
            }
        } catch (error) {
            console.error("Error fetching scenario:", error);
        }
    };

    return {
        subscribe,
        getById,
        refetchById,
    };
})();