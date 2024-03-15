import { writable } from "svelte/store";
import { Scenario } from "../ic-agent/declarations/league";
import { leagueAgentFactory } from "../ic-agent/League";

export const scenarioStore = (() => {
    const { subscribe, update } = writable<Map<string, Scenario>>(new Map());

    const refetchById = async (id: string) => {
        leagueAgentFactory().getScenario(id).then((scenario) => {
            if ('ok' in scenario) {
                update(scenarios => {
                    scenarios.set(id, scenario.ok);
                    return scenarios;
                });
            } else {
                console.error("Failed to get scenario: " + id, scenario);
            }
        });
    };

    const subscribeById = (id: string, callback: (scenario: Scenario) => void) => {
        const unsubscribe = subscribe(scenarios => {
            const scenario = scenarios.get(id);
            if (scenario) {
                callback(scenario);
            } else {
                refetchById(id);
            }
        });
        return unsubscribe;
    }

    return {
        subscribeById,
        refetchById
    };
})();