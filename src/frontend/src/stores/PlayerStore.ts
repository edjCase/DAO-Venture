import { writable } from "svelte/store";
import { Player, playerLedgerAgentFactory } from "../ic-agent/PlayerLedger";



export const playerStore = (() => {
    const { subscribe, set } = writable<Player[]>([]);

    const refetch = async () => {
        playerLedgerAgentFactory().getAllPlayers().then((players) => {
            set(players);
        });
    };
    refetch();

    return {
        subscribe,
        refetch
    };
})();


