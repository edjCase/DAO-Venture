import { writable } from "svelte/store";
import { mainAgentFactory } from "../ic-agent/Main";




export const entropyStore = (() => {
  const thresholdStore = writable<bigint | undefined>();

  const refetchThreshold = async () => {
    let mainAgent = await mainAgentFactory();
    let entropyThreshold = await mainAgent.getEntropyThreshold();
    thresholdStore.set(entropyThreshold);
  };




  refetchThreshold();


  return {
    subscribeThreshold: thresholdStore.subscribe,
    refetchThreshold
  };
})();
