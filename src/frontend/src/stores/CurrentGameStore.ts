import { writable } from "svelte/store";
import { mainAgentFactory } from "../ic-agent/Main";
import { GameWithMetaData } from "../ic-agent/declarations/main";

export const currentGameStore = (() => {
  const { subscribe, set } = writable<GameWithMetaData | undefined>();

  const refetch = async () => {
    const mainAgent = await mainAgentFactory();
    const result = await mainAgent.getCurrentGame();
    if ('ok' in result) {
      let gameOrUndefined = result.ok[0];
      set(gameOrUndefined);
      if (gameOrUndefined !== undefined) {
        setTimeout(refetch, 5000);
      }
    } else {
      console.error("Current game fetch error", result.err);
      setTimeout(refetch, 5000);
    }
  };

  refetch();



  return {
    subscribe,
    refetch
  };
})();