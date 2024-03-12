import { Writable, writable } from "svelte/store";
import { leagueAgentFactory } from "../ic-agent/League";
import { MatchGroupPredictionSummary } from "../ic-agent/declarations/league";
import { Subscriber } from "svelte/motion";


export const predictionStore = (() => {
    const matchGroupPredictions = new Map<bigint, Writable<MatchGroupPredictionSummary | undefined>>();


    const getOrCreateMatchGroupStore = (matchGroupId: bigint): Writable<MatchGroupPredictionSummary | undefined> => {
        let store = matchGroupPredictions.get(matchGroupId);
        if (!store) {
            store = writable<MatchGroupPredictionSummary | undefined>();
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
                set(undefined);
            }
        });
    };

    const subscribeToMatchGroup = (matchGroupId: bigint, callback: Subscriber<MatchGroupPredictionSummary | undefined>) => {
        let { subscribe } = getOrCreateMatchGroupStore(matchGroupId);
        subscribe(callback);
    };

    return {
        subscribeToMatchGroup,
        refetchMatchGroup
    };
})();


