import { writable, get } from "svelte/store";
import { stadiumAgentFactory as stadiumAgentFactory, MatchGroup } from "../ic-agent/Stadium";
import { stadiumStore } from "./StadiumStore";
import { Principal } from "@dfinity/principal";


export const matchGroupStore = (() => {
  const { subscribe, set, update } = writable<MatchGroup[]>([]);
  const stadiumLivePolls: { [key: string]: NodeJS.Timeout } = {};


  const resetStadiumLivePoll = (stadiumId: Principal, matchGroupId: number, date: Date) => {
    let waitMillis = date.getTime() - Date.now();
    if (waitMillis < 1000) {
      waitMillis = 1000; // Safety
    }
    let stadiumIdString = stadiumId.toText();
    if (stadiumLivePolls[stadiumIdString]) {
      clearTimeout(stadiumLivePolls[stadiumIdString]);
    }
    console.log("Polling stadium", stadiumIdString, "matches in", waitMillis, "ms");
    stadiumLivePolls[stadiumIdString] = setTimeout(() => refetchMatchGroup(stadiumId, matchGroupId), waitMillis);
  };
  const refetchMatchGroup = async (stadiumId: Principal, matchGroupId: number) => {
    return stadiumAgentFactory(stadiumId)
      .getMatchGroup(matchGroupId)
      .then((matchGroupOrNull: [MatchGroup] | []) => {
        if (matchGroupOrNull.length === 0) {
          return matchGroupOrNull;
        }
        let matchGroup = matchGroupOrNull[0];
        update((matchGroupsToUpdate: MatchGroup[]) => {
          // Update the existing matches and add new ones
          let oldMatchGroupIndex = matchGroupsToUpdate.findIndex(m => m.id === matchGroup.id);
          if (oldMatchGroupIndex >= 0) {
            matchGroupsToUpdate[oldMatchGroupIndex] = matchGroup;
          } else {
            matchGroupsToUpdate.push(matchGroup);
          }
          return matchGroupsToUpdate;
        });
        const now = new Date();
        let nextMatchDate;
        if ('inProgress' in matchGroup.state) {
          nextMatchDate = new Date(now.getTime() + 5000); // five seconds from now
        } else {
          nextMatchDate = undefined; // TODO?
        }
        if (nextMatchDate) {
          resetStadiumLivePoll(stadiumId, matchGroupId, nextMatchDate); // TODO how to handle failure

        }
        return matchGroupOrNull;
      });
  };
  const refetch = async () => {
    const $stadiums = get(stadiumStore);
    const promises = $stadiums.map(s => refetchMatchGroup(s.id, matchGroupId));

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


