import { writable, get } from "svelte/store";
import { stadiumAgentFactory as stadiumAgentFactory, MatchGroup, SeasonSchedule } from "../ic-agent/Stadium";
import { stadiumStore } from "./StadiumStore";
import { Principal } from "@dfinity/principal";
import { nanosecondsToDate } from "../utils/DateUtils";


export const matchGroupStore = (() => {
  const { subscribe, set, update } = writable<MatchGroup[]>([]);
  const matchGroupLivePolls: { [key: number]: NodeJS.Timeout } = {};


  const resetStadiumLivePoll = (stadiumId: Principal, matchGroupId: number, date: Date) => {
    let waitMillis = date.getTime() - Date.now();
    if (waitMillis < 1000) {
      waitMillis = 1000; // Safety
    }
    if (matchGroupLivePolls[matchGroupId]) {
      clearTimeout(matchGroupLivePolls[matchGroupId]);
    }
    console.log("Polling match group", matchGroupId, "matches in", waitMillis, "ms");
    matchGroupLivePolls[matchGroupId] = setTimeout(() => refetchMatchGroup(stadiumId, matchGroupId), waitMillis);
  };
  const setMatchGroupPoll = (stadiumId: Principal, matchGroup: MatchGroup) => {
    const now = new Date();
    let nextMatchDate;
    if ('inProgress' in matchGroup.state) {
      nextMatchDate = new Date(now.getTime() + 5000); // five seconds from now
    } else if ('notStarted' in matchGroup.state) {
      nextMatchDate = nanosecondsToDate(matchGroup.time);
    }
    if (nextMatchDate) {
      resetStadiumLivePoll(stadiumId, matchGroup.id, nextMatchDate); // TODO how to handle failure
    }
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
        setMatchGroupPoll(stadiumId, matchGroup);
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
        let matchGroups = scheduleOrNull[0].divisions.flatMap(d => d.matchGroups);
        set(matchGroups);
        for (let matchGroup of matchGroups) {
          setMatchGroupPoll(stadiumId, matchGroup);
        }
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


