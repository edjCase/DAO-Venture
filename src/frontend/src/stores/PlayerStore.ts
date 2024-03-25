import { writable } from "svelte/store";
import { PlayerWithId } from "../ic-agent/declarations/players";
import { playersAgentFactory } from "../ic-agent/Players";



export const playerStore = (() => {
    const { subscribe, set } = writable<PlayerWithId[] | undefined>();

    const refetch = async () => {
        let playersAgent = await playersAgentFactory();
        playersAgent.getAllPlayers().then((players) => {
            set(players);
        });
    };
    refetch();

    return {
        subscribe,
        refetch
    };
})();


