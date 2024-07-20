import { writable } from "svelte/store";
import { TownStandingInfo } from "../ic-agent/declarations/main";
import { mainAgentFactory } from "../ic-agent/Main";
import { Town } from "../ic-agent/declarations/main";




export const townStore = (() => {
  const townsStore = writable<Town[] | undefined>();
  const townStandingsWritable = writable<TownStandingInfo[] | undefined>();

  const refetch = async () => {
    let mainAgent = await mainAgentFactory();
    let towns = await mainAgent.getTowns();
    townsStore.set(towns);
  };


  const refetchTownStandings = async () => {
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.getTownStandings();
    if ('ok' in result) {
      townStandingsWritable.set(result.ok);
    } else if ('err' in result && 'notFound' in result.err) {
      townStandingsWritable.set(undefined);
    } else {
      console.error("Failed to get town standings: ", result);
    }
  }


  setInterval(refetch, 1000 * 10); // Refetch every 10 seconds

  refetch();
  refetchTownStandings();


  return {
    subscribeTownStandings: townStandingsWritable.subscribe,
    refetchTownStandings,
    subscribe: townsStore.subscribe,
    refetch
  };
})();
