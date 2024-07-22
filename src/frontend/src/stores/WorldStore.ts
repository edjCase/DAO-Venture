import { writable } from "svelte/store";
import { mainAgentFactory } from "../ic-agent/Main";
import { WorldLocation } from "../ic-agent/declarations/main";




export const worldStore = (() => {
  const { subscribe, set
  } = writable<WorldLocation[] | undefined>();

  const refetch = async () => {
    let mainAgent = await mainAgentFactory();
    let worldGrid = await mainAgent.getWorldGrid();
    if ('ok' in worldGrid) {
      set(worldGrid.ok);
    }
    else {
      console.error("Failed to get world grid", worldGrid.err);
    }
  };



  setInterval(refetch, 1000 * 10); // Refetch every 10 seconds

  refetch();


  return {
    subscribe,
    refetch
  };
})();
