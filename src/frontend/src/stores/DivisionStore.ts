import { writable } from "svelte/store";
import { leagueAgentFactory, type Division } from "../ic-agent/League";




export const divisionStore = (() => {
  const { subscribe, set } = writable<Division[]>([]);

  const refetch = async () => {
    leagueAgentFactory().getDivisions().then((divisions) => {
      set(divisions);
    });
  };
  refetch();

  return {
    subscribe,
    refetch
  };
})();
