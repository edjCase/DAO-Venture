import { writable } from 'svelte/store';
import { ScenarioMetaData } from '../ic-agent/declarations/main';
import { mainAgentFactory } from '../ic-agent/Main';

export const scenarioMetaDataStore = (() => {
    const { subscribe, set } = writable<ScenarioMetaData[]>();
    let initialized = false;

    async function refetch() {
        const mainAgent = await mainAgentFactory();
        const scenarioMetaData = await mainAgent.getScenarioMetaDataList();
        set(scenarioMetaData);
    }

    return {
        subscribe: (run: (value: ScenarioMetaData[]) => void, invalidate?: (value?: ScenarioMetaData[]) => void): (() => void) => {
            if (!initialized) {
                initialized = true;
                refetch();
            }
            return subscribe(run, invalidate);
        },
        refetch,
    };
})();