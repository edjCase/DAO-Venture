import { writable } from "svelte/store";
import { mainAgentFactory } from "../ic-agent/Main";
import { WorldData } from "../ic-agent/declarations/main";




export const worldStore = (() => {
  const dataStore = writable<WorldData | undefined>();

  const refetchData = async () => {
    let mainAgent = await mainAgentFactory();
    let entropyData = await mainAgent.getWorldData();
    dataStore.set(entropyData);
  };



  setInterval(refetchData, 1000 * 10); // Refetch every 10 seconds

  refetchData();


  return {
    subscribeData: dataStore.subscribe,
    refetchData
  };
})();
