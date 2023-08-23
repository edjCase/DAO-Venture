import { writable } from "svelte/store";
import { agent as leagueAgent, type Stadium } from "../ic-agent/League"



export const stadiumStore = (() => {
  const { subscribe, set } = writable<Stadium[]>([]);

  const refetch = async () => {
    leagueAgent.getStadiums().then((stadiums) => {
        set(stadiums);
    });
  };
  refetch();

  return {
    subscribe,
    refetch
  };
})();