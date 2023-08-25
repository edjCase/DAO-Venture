import { writable } from "svelte/store";
import { type PlayerInfoWithId, playerLedgerAgent as playerLedgerAgent } from "../ic-agent/PlayerLedger";


export const playerStore = (() => {
    const { subscribe, set } = writable<PlayerInfoWithId[]>([]);

    const refetch = async () => {
        playerLedgerAgent.getAllPlayers().then((players) => {
            set(players);
        });
    };
    refetch();

    return {
        subscribe,
        refetch
    };
})();


