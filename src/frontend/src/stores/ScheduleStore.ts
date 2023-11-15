import { writable } from "svelte/store";
import { SeasonStatus, leagueAgentFactory } from "../ic-agent/League";


export const seasonStatusStore = (() => {
  const { subscribe, set } = writable<SeasonStatus>({ 'notStarted': null });

  const refetch = async () => {
    let seasonStatus = await leagueAgentFactory()
      .getSeasonStatus();
    set(seasonStatus);
  };

  refetch();


  return {
    subscribe,
    refetch
  };
})();


