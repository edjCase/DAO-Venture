import { writable } from "svelte/store";
import { Player } from "../ic-agent/declarations/players";
import { playersAgentFactory } from "../ic-agent/Players";



export const playerStore = (() => {
    const { subscribe, set } = writable<Player[]>([]);

    const refetch = async () => {
        playersAgentFactory().getAllPlayers().then((players) => {
            set(players);
        });
    };
    refetch();

    return {
        subscribe,
        refetch
    };
})();


