import { writable } from "svelte/store";
import { playerLedgerAgentFactory, unMapPosition, unMapDeity } from "../ic-agent/PlayerLedger";
import type { Player } from "../models/Player";


export const playerStore = (() => {
    const { subscribe, set } = writable<Player[]>([]);

    const refetch = async () => {
        playerLedgerAgentFactory().getAllPlayers().then((players) => {
            set(players.map(p => {
                return {
                    ...p,
                    deity: unMapDeity(p.deity),
                    position: unMapPosition(p.position)
                };
            }));
        });
    };
    refetch();

    return {
        subscribe,
        refetch
    };
})();


