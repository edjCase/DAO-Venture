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




  refetchData();


  return {
    subscribeData: dataStore.subscribe,
    refetchData
  };
})();
