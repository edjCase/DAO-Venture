import { writable } from "svelte/store";
import { mainAgentFactory } from "../ic-agent/Main";
import { Town } from "../ic-agent/declarations/main";




export const townStore = (() => {
  const townsStore = writable<Town[] | undefined>();

  const refetch = async () => {
    let mainAgent = await mainAgentFactory();
    let towns = await mainAgent.getTowns();
    townsStore.set(towns);
  };




  setInterval(refetch, 1000 * 10); // Refetch every 10 seconds

  refetch();


  return {
    subscribe: townsStore.subscribe,
    refetch
  };
})();
