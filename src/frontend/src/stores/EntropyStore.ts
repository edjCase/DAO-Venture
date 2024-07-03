import { writable } from "svelte/store";
import { teamsAgentFactory } from "../ic-agent/Teams";




export const entropyStore = (() => {
  const thresholdStore = writable<bigint | undefined>();

  const refetchThreshold = async () => {
    let teamsAgent = await teamsAgentFactory();
    let entropyThreshold = await teamsAgent.getEntropyThreshold();
    thresholdStore.set(entropyThreshold);
  };




  refetchThreshold();


  return {
    subscribeThreshold: thresholdStore.subscribe,
    refetchThreshold
  };
})();
