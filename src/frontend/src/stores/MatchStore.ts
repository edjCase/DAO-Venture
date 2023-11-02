import { writable, get } from "svelte/store";
import { stadiumAgentFactory as stadiumAgentFactory, type Match } from "../ic-agent/Stadium";
import { stadiumStore } from "./StadiumStore";
import { Principal } from "@dfinity/principal";


export const matchStore = (() => {
  const { subscribe, set, update } = writable<Match[]>([]);
  const stadiumLivePolls: { [key: string]: NodeJS.Timeout } = {};


  const resetStadiumLivePoll = (stadiumId: Principal, date: Date) => {
    let waitMillis = date.getTime() - Date.now();
    if (waitMillis < 1000) {
      waitMillis = 1000; // Safety
    }
    let stadiumIdString = stadiumId.toText();
    if (stadiumLivePolls[stadiumIdString]) {
      clearTimeout(stadiumLivePolls[stadiumIdString]);
    }
    console.log("Polling stadium", stadiumIdString, "matches in", waitMillis, "ms");
    stadiumLivePolls[stadiumIdString] = setTimeout(() => refetchStadiumMatches(stadiumId), waitMillis);
  };
  const refetchStadiumMatches = async (stadiumId: Principal) => {
    return stadiumAgentFactory(stadiumId)
      .getMatches()
      .then((stadiumMatches: Match[]) => {
        update((matchesToUpdate: Match[]) => {
          // Update the existing matches and add new ones
          const newMatches = [];
          for (let i = 0; i < matchesToUpdate.length; i++) {
            let oldMatch = matchesToUpdate[i];
            if (oldMatch.stadiumId.compareTo(stadiumId) !== 'eq') {
              continue;
            }
            const updatedMatch = stadiumMatches.find(m => m.id === oldMatch.id);
            if (updatedMatch) {
              matchesToUpdate[i] = updatedMatch;
            } else {
              newMatches.push(oldMatch);
            }
          }
          for (const newMatch of newMatches) {
            matchesToUpdate.push(newMatch);
          }
          return matchesToUpdate
        });
        const now = new Date();
        let nextMatchDate;
        if (stadiumMatches.filter(m => 'inProgress' in m.state).length > 0) {
          nextMatchDate = new Date(now.getTime() + 5000); // five seconds from now
        } else {
          let nowNanoseconds = BigInt(now.getTime()) * BigInt(1000000);
          let nextMatches = stadiumMatches
            .filter(m => 'notStarted' in m.state && m.time > nowNanoseconds)
            .map(m => m.time);
          if (nextMatches.length > 0) {
            nextMatchDate = new Date(Math.min(...nextMatches.map(t => Number(t / BigInt(1000000)))));
          }
        }
        if (nextMatchDate) {
          resetStadiumLivePoll(stadiumId, nextMatchDate); // TODO how to handle failure

        }
        return stadiumMatches;
      });
  };
  const refetch = async () => {
    const $stadiums = get(stadiumStore);
    const promises = $stadiums.map(s => refetchStadiumMatches(s.id));

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


