import { writable } from "svelte/store";
import { Player } from "../ic-agent/declarations/main";
import { mainAgentFactory } from "../ic-agent/Main";



export const playerStore = (() => {
    const { subscribe, set } = writable<Player[] | undefined>();

    const refetch = async () => {
        let mainAgent = await mainAgentFactory();
        let players = await mainAgent.getAllPlayers();
        set(players);
    };
    refetch();

    return {
        subscribe,
        refetch
    };
})();


