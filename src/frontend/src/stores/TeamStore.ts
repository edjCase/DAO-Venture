import { writable } from "svelte/store";
import { leagueAgentFactory } from "../ic-agent/League";
import { Team } from "../models/Team";




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
