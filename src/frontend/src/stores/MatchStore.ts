import { writable, get } from "svelte/store";
import { agentFactory as stadiumAgentFactory } from "../ic-agent/Stadium";
import { stadiumStore } from "./StadiumStore";


export const matchStore = (() => {
  const { subscribe, set } = writable([]);

  const refetch = async () => {
    const $stadiums = get(stadiumStore);
    const promises = $stadiums.map(async (stadium) => {
      return stadiumAgentFactory(stadium.id)
        .getMatches()
        .then((matches) => {
          return matches;
        });
    });

    const results = await Promise.all(promises);
    const allMatches = results.flat();
    set(allMatches);
  };
  // Derived store to watch changes in stadiumStore and trigger refetch
  stadiumStore.subscribe(() => {
    refetch();
  });

  return {
    subscribe,
    refetch
  };
})();


