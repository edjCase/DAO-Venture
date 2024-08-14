import { writable } from "svelte/store";
import { mainAgentFactory } from "../ic-agent/Main";
import { World } from "../ic-agent/declarations/main";

export const worldStore = (() => {
  const { subscribe, set } = writable<World | undefined>();

  // let fetchNextDayTimeout: NodeJS.Timeout | undefined = undefined;

  // const clearExistingTimeout = () => {
  //   if (fetchNextDayTimeout !== undefined) {
  //     clearTimeout(fetchNextDayTimeout);
  //     fetchNextDayTimeout = undefined;
  //   }
  // };

  // const scheduleNextFetch = (nextDayStartTime: bigint) => {
  //   clearExistingTimeout();

  //   const now = new Date();
  //   const nextDay = nanosecondsToDate(nextDayStartTime);
  //   const millisTillNextDay = nextDay.getTime() - now.getTime() + 2000; // Add 2 seconds to ensure we're past the next day

  //   fetchNextDayTimeout = setTimeout(() => {
  //     fetchNextDayTimeout = undefined;
  //     refetch();
  //   }, millisTillNextDay);

  //   console.log("Scheduled next world refetch in", millisTillNextDay, "ms");
  // };

  const refetch = async () => {
    const mainAgent = await mainAgentFactory();
    const result = await mainAgent.getWorld();

    if ('ok' in result) {
      set(result.ok);
      console.log("Fetched world");
      // scheduleNextFetch(result.ok.nextDayStartTime); // TODO
    } else if ('err' in result && 'noActiveGame' in result.err) {
      setTimeout(refetch, 60_000);
    } else {
      console.error("Failed to get world", result.err);
      // Retry after a short delay (e.g., 5 seconds)
      setTimeout(refetch, 5000);
    }
  };

  // Initial fetch
  refetch();

  return {
    subscribe,
    refetch
  };
})();