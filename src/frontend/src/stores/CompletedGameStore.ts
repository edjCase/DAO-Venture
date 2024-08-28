import { writable } from "svelte/store";
import { mainAgentFactory } from "../ic-agent/Main";
import { CompletedGameWithMetaData } from "../ic-agent/declarations/main";

export const completedGameStore = (() => {
    const { subscribe, set } = writable<CompletedGameWithMetaData[] | undefined>();

    const refetch = async () => {
        const mainAgent = await mainAgentFactory();
        const games = await mainAgent.getCompletedGames();
        set(games);
    };

    refetch();



    return {
        subscribe,
        refetch
    };
})();