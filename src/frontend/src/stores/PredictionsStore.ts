import { writable } from "svelte/store";
import { UpcomingMatchPrediction, leagueAgentFactory } from "../ic-agent/League";


export const predictionStore = (() => {
    const { subscribe, set } = writable<UpcomingMatchPrediction[] | undefined>();

    const refetch = () => {
        leagueAgentFactory().getUpcomingMatchPredictions().then((result) => {
            if ('ok' in result) {
                const matchPredictions = result.ok;
                set(matchPredictions);
                return;
            } else {
                set(undefined);
            }
        });
    };

    refetch();

    return {
        subscribe,
        refetch
    };
})();


