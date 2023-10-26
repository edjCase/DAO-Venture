import { get, writable } from "svelte/store";
import { leagueAgentFactory, type Team } from "../ic-agent/League";




export const teamStore = (() => {
  const { subscribe, set } = writable<Team[]>([]);

  const refetch = async () => {
    leagueAgentFactory().getTeams().then((teams) => {
      set(teams);
    });
  };
  refetch();


  return {
    subscribe,
    refetch
  };
})();
