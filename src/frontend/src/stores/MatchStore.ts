import { derived, writable, get } from "svelte/store";
import {agentFactory as stadiumAgentFactory} from "../ic-agent/stadium";
import { stadiumStore } from "./StadiumStore";




export const matchStore = (() => {
  const { subscribe, set } = writable([]);

  const refetch = async () => {
    const $stadiums = get(stadiumStore); // Get the current stadiums
    const promises = $stadiums.map(async (stadium) => {
      return stadiumAgentFactory(stadium.id).getIncompleteMatches()
      .then((matches) => {
        return matches;
      });
    });

    const results = await Promise.all(promises);
    const allMatches = results.flat();
    set(allMatches); // Set the new matches
  };

  // Refetch when stadiums change
  derived(stadiumStore, () => {
    refetch();
  });

  return {
    subscribe,
    refetch // Expose refetch method
  };
})();
