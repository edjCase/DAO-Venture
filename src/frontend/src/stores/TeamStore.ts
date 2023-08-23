import { writable } from "svelte/store";
import {Team, agent as leagueAgent} from "../ic-agent/League"; 




export const teamStore = (() => {
  const { subscribe, set } = writable<Team[]>([]);

  const refetch = async () => {
    leagueAgent.getTeams().then((teams) => {
        set(teams);
    });
  };
  refetch();

  return {
    subscribe,
    refetch 
  };
})();
