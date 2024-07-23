import { writable } from "svelte/store";
import { mainAgentFactory } from "../ic-agent/Main";
import { World } from "../ic-agent/declarations/main";
import { nanosecondsToDate } from "../utils/DateUtils";




export const worldStore = (() => {
  const { subscribe, set
  } = writable<World | undefined>();

  const refetch = async () => {
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.getWorld();
    if ('ok' in result) {
      set(result.ok);
      let now = new Date();
      let nextDay = nanosecondsToDate(result.ok.nextDayStartTime);
      let millisTillNextDay = nextDay.getTime() - now.getTime();
      setInterval(refetch, millisTillNextDay); // Refetch every day
    }
    else {
      console.error("Failed to get world grid", result.err);
      refetch();
    }
  };




  refetch();


  return {
    subscribe,
    refetch
  };
})();
