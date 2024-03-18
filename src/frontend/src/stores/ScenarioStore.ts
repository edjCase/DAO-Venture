import { Writable, writable } from "svelte/store";
import { Scenario } from "../ic-agent/declarations/league";
import { leagueAgentFactory } from "../ic-agent/League";



export const scenarioStore = (() => {
    const scenarioStores = new Map<string, Writable<Scenario>>();

    const refetchById = async (id: string) => {
        let store = await getOrCreateStore(id);
        let scenario = await get(id);
        store.set(scenario!);
    };

    const getOrCreateStore = async (id: string) => {
        if (!scenarioStores.has(id)) {
            let scenario = await get(id);
            if (scenario) {
                scenarioStores.set(id, writable<Scenario>(scenario));
            } else {
                throw new Error("Scenario not found: " + id);
            }
        }
        return scenarioStores.get(id)!;
    };

    const get = async (id: string) => {
        let leagueAgent = await leagueAgentFactory();
        let scenario = await leagueAgent
            .getScenario(id);
        if ('ok' in scenario) {
            return scenario.ok;
        } else {
            console.error("Failed to get scenario: " + id, scenario);
            return null;
        }
    }

    const subscribeById = async (id: string, callback: (scenario: Scenario) => void) => {
        let store = await getOrCreateStore(id);
        return store.subscribe(callback);
    }

    return {
        subscribeById,
        refetchById
    };
})();