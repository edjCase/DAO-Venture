import { writable } from "svelte/store";
import { ScenarioTemplate } from "../models/Scenario";
import { leagueAgentFactory } from "../ic-agent/League";


export const scenarioTemplateStore = (() => {
    const { subscribe, set } = writable<ScenarioTemplate[]>([]);

    const refetch = () => {
        leagueAgentFactory().getScenarioTemplates().then((result) => {
            set(result);
        });
    };

    refetch();

    return {
        subscribe,
        refetch
    };
})();


