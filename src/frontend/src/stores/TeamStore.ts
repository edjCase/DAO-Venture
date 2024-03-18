import { writable } from "svelte/store";
import { TeamWithId } from "../ic-agent/declarations/league";
import { leagueAgentFactory } from "../ic-agent/League";




export const teamStore = (() => {
  const { subscribe, set } = writable<TeamWithId[]>([]);

  const refetch = async () => {
    let leagueAgent = await leagueAgentFactory();
    leagueAgent
      .getTeams().then((teams) => {
        set(teams);
      });
  };
  refetch();


  return {
    subscribe,
    refetch
  };
})();
