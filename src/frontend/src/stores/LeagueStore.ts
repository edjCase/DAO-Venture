import { writable } from "svelte/store";
import { mainAgentFactory } from "../ic-agent/Main";
import { LeagueData } from "../ic-agent/declarations/main";




export const leagueStore = (() => {
  const dataStore = writable<LeagueData | undefined>();

  const refetchData = async () => {
    let mainAgent = await mainAgentFactory();
    let entropyData = await mainAgent.getLeagueData();
    dataStore.set(entropyData);
  };



  setInterval(refetchData, 1000 * 10); // Refetch every 10 seconds

  refetchData();


  return {
    subscribeData: dataStore.subscribe,
    refetchData
  };
})();
