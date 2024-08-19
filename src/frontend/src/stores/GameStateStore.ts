import { writable } from "svelte/store";
import { mainAgentFactory } from "../ic-agent/Main";
import { GameState } from "../ic-agent/declarations/main";

export const gameStateStore = (() => {
  const { subscribe, set } = writable<GameState | undefined>();

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
    const result = await mainAgent.getGameInstance();

    set(result);
    if ('notIntialized' in result) {
      console.log("Game state not initialized yet");
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