import { writable } from "svelte/store";
import { leagueAgentFactory, type Stadium } from "../ic-agent/League"



export const stadiumStore = (() => {
  const { subscribe, set } = writable<Stadium[]>([]);

  const refetch = async () => {
    leagueAgentFactory().getStadiums().then((stadiums) => {
      set(stadiums);
    });
  };
  refetch();

  return {
    subscribe,
    refetch
  };
})();