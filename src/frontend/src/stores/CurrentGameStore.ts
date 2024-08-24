import { writable } from "svelte/store";
import { mainAgentFactory } from "../ic-agent/Main";
import { GameWithMetaData } from "../ic-agent/declarations/main";

export const currentGameStore = (() => {
  const { subscribe, set } = writable<GameWithMetaData | undefined>();

  const refetch = async () => {
    const mainAgent = await mainAgentFactory();
    const result = await mainAgent.getCurrentGame();
    if ('ok' in result) {
      set(result.ok[0]);
    } else {
      console.error("Current game fetch error", result.err);
    }
  };

  refetch();



  return {
    subscribe,
    refetch
  };
})();