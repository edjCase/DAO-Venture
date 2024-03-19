import { writable } from "svelte/store";
import { Scenario } from "../ic-agent/declarations/league";
import { leagueAgentFactory } from "../ic-agent/League";



export const scenarioStore = (() => {
    const { subscribe, set } = writable<Scenario[]>([]);

    const refetch = async () => {
        let leagueAgent = await leagueAgentFactory();
        let result = await leagueAgent.getScenarios();
        if ('ok' in result) {
            set(result.ok);
        } else {
            console.log("Error getting scenarios", result);
        }
    };

    refetch();

    return {
        refetch,
        subscribe
    };
})();