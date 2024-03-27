import { writable } from "svelte/store";
import { PlayerWithId } from "../ic-agent/declarations/players";
import { playersAgentFactory } from "../ic-agent/Players";



export const playerStore = (() => {
    const { subscribe, set } = writable<PlayerWithId[] | undefined>();

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


