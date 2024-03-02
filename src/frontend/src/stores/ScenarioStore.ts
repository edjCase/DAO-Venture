import { writable } from "svelte/store";
import { Scenario } from "../ic-agent/declarations/league";
import { leagueAgentFactory } from "../ic-agent/League";


export const scenarioStore = (() => {
    const { subscribe, set } = writable<Scenario[]>([]);

    const refetch = () => {
        leagueAgentFactory().getScenarios().then((result) => {
            set(result);
        });
    };

    refetch();

    return {
        subscribe,
        refetch
    };
})();


