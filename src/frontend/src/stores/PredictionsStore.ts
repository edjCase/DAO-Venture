import { Writable, writable } from "svelte/store";
import { leagueAgentFactory } from "../ic-agent/League";
import { MatchGroupPredictionSummary } from "../ic-agent/declarations/league";
import { Subscriber } from "svelte/motion";


export const predictionStore = (() => {
    const matchGroupPredictions = new Map<bigint, Writable<MatchGroupPredictionSummary>>();


    const getOrCreateMatchGroupStore = (matchGroupId: bigint): Writable<MatchGroupPredictionSummary> => {
        let store = matchGroupPredictions.get(matchGroupId);
        if (!store) {
            store = writable<MatchGroupPredictionSummary>();
            matchGroupPredictions.set(matchGroupId, store);
            refetchMatchGroup(matchGroupId);
        };
        return store;
    };

    const refetchMatchGroup = (matchGroupId: bigint) => {
        let { set } = getOrCreateMatchGroupStore(matchGroupId);
        leagueAgentFactory().getMatchGroupPredictions(matchGroupId).then((result) => {
            if ('ok' in result) {
                const matchPredictions = result.ok;
                set(matchPredictions);
                return;
            } else {
                console.error("Failed to get match group predictions: " + matchGroupId, result);
            }
        });
    };

    const subscribeToMatchGroup = (matchGroupId: bigint, callback: Subscriber<MatchGroupPredictionSummary>) => {
        let { subscribe } = getOrCreateMatchGroupStore(matchGroupId);
        subscribe(callback);
    };

    return {
        subscribeToMatchGroup,
        refetchMatchGroup
    };
})();


