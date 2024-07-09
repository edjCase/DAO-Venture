import { writable } from "svelte/store";
import { mainAgentFactory } from "../ic-agent/Main";
import { EntropyData } from "../ic-agent/declarations/main";




export const entropyStore = (() => {
  const dataStore = writable<EntropyData | undefined>();

  const refetchData = async () => {
    let mainAgent = await mainAgentFactory();
    let entropyData = await mainAgent.getEntropyData();
    dataStore.set(entropyData);
  };



  setInterval(refetchData, 1000 * 10); // Refetch every 10 seconds

  refetchData();


  return {
    subscribeData: dataStore.subscribe,
    refetchData
  };
})();
