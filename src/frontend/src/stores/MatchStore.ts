import { writable, get } from "svelte/store";
import { stadiumAgentFactory as stadiumAgentFactory, type Match } from "../ic-agent/Stadium";
import { stadiumStore } from "./StadiumStore";
import { subscribe as liveStreamSubscribe, type LiveStreamMessage } from "../ic-agent/LiveStreamHub";


export const matchStore = (() => {
  const { subscribe, set, update } = writable<Match[]>([]);

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
  let ws = liveStreamSubscribe((msg: LiveStreamMessage) => {
    update((matches: Match[]) => {
      let match = matches.find((m) => m.id === msg.matchId && m.stadiumId === msg.stadiumId);
      if (!match) {
        refetch();
      } else {
        match.state = msg.state;
      }
      return matches;
    });
  });
  const close = () => {
    ws.close();
  }

  return {
    subscribe,
    refetch,
    close
  };
})();


