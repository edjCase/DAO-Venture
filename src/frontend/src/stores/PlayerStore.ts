import { writable } from "svelte/store";
import { Player } from "../ic-agent/declarations/players";
import { playersAgentFactory } from "../ic-agent/Players";



export const playerStore = (() => {
    const { subscribe, set } = writable<Player[] | undefined>();

    const refetch = async () => {
        let playersAgent = await playersAgentFactory();
        let players = await playersAgent.getAllPlayers();
        set(players);
    };
    refetch();

    return {
        subscribe,
        refetch
    };
})();


