import { Writable, writable } from "svelte/store";
import { mainAgentFactory } from "../ic-agent/Main";
import { MatchGroupPredictionSummary, TeamId } from "../ic-agent/declarations/main";
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

    const refetchMatchGroup = async (matchGroupId: bigint | number) => {
        if (typeof matchGroupId === "number") {
            matchGroupId = BigInt(matchGroupId);
        }
        let { set } = getOrCreateMatchGroupStore(matchGroupId);

        let mainAgent = await mainAgentFactory();
        let result = await mainAgent
            .getMatchGroupPredictions(matchGroupId);
        if ('ok' in result) {
            const matchPredictions = result.ok;
            set(matchPredictions);
            return;
        } else {
            console.error("Failed to get match group predictions: " + matchGroupId, result);
        }
    };

    const subscribeToMatchGroup = (matchGroupId: bigint | number, callback: Subscriber<MatchGroupPredictionSummary>) => {
        if (typeof matchGroupId === "number") {
            matchGroupId = BigInt(matchGroupId);
        }
        let { subscribe } = getOrCreateMatchGroupStore(matchGroupId);
        subscribe(callback);
    };

    const predictMatchOutcome = async (matchGroupId: bigint | number, matchId: bigint | number, team: TeamId) => {
        if (typeof matchGroupId === "number") {
            matchGroupId = BigInt(matchGroupId);
        }

        if (typeof matchId === "number") {
            matchId = BigInt(matchId);
        }


        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.predictMatchOutcome({
            matchId: matchId,
            winner: team ? [team] : [],
        });
        if ("ok" in result) {
            console.log("Predicted for match: ", matchId);
            refetchMatchGroup(matchGroupId);
        } else {
            console.log("Failed to predict for match: ", matchId, result);
        }
    };

    return {
        subscribeToMatchGroup,
        refetchMatchGroup,
        predictMatchOutcome
    };
})();


