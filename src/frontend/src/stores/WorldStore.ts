import { writable } from "svelte/store";
import { mainAgentFactory } from "../ic-agent/Main";
import { WorldData } from "../ic-agent/declarations/main";




export const worldStore = (() => {
  const { subscribe, set
  } = writable<WorldGrid | undefined>();

  const refetch = async () => {
    let mainAgent = await mainAgentFactory();
    let entropyData = await mainAgent.getWorldGrid();
    set(entropyData);
  };



  setInterval(refetch, 1000 * 10); // Refetch every 10 seconds

  refetch();


  return {
    subscribe,
    refetch
  };
})();
