import { writable, get } from "svelte/store";
import { stadiumAgentFactory as stadiumAgentFactory, MatchGroup, Offering, SeasonSchedule } from "../ic-agent/Stadium";
import { stadiumStore } from "./StadiumStore";
import { Principal } from "@dfinity/principal";

export type OfferingDetails = {
  name: string;
  description: string;
};

export let getOfferingDetails = (offering: Offering): OfferingDetails => {
  if ("shuffleAndBoost" in offering) {
    return {
      name: "Shuffle And Boost",
      description:
        "Shuffle your team's field positions and boost your team with a random blessing.",
    };
  } else {
    return {
      name: "Unknown",
      description: "Unknown",
    };
  }
};

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
    stadiumAgentFactory(stadiumId)
      .getMatchGroup(matchGroupId)
      .then((matchGroupOrNull: [MatchGroup] | []) => {
        if (matchGroupOrNull.length === 0) {
          return;
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
  const refetchScheduledMatches = async (stadiumId: Principal) => {
    return stadiumAgentFactory(stadiumId)
      .getSeasonSchedule()
      .then((scheduleOrNull: [SeasonSchedule] | []) => {
        if (scheduleOrNull.length === 0) {
          return;
        }
        set(scheduleOrNull[0].divisions.flatMap(d => d.matchGroups));
        return;
      });
  };
  const refetchById = async (matchGroupId: number) => {
    const $stadiums = get(stadiumStore);
    const promises = $stadiums.map(s => refetchMatchGroup(s.id, matchGroupId));

    await Promise.all(promises);
  };
  const refetchAll = async () => {
    const $stadiums = get(stadiumStore);
    const promises = $stadiums.map(s => refetchScheduledMatches(s.id));

    await Promise.all(promises);
  };


  // Derived store to watch changes in stadiumStore and trigger refetch
  // TODO
  stadiumStore.subscribe(() => {
    refetchAll();
  });


  return {
    subscribe,
    refetchById,
    refetchAll
  };
})();


