import { writable } from "svelte/store";
import { stadiumAgentFactory, MatchGroup } from "../ic-agent/Stadium";
import { Principal } from "@dfinity/principal";
import { nanosecondsToDate } from "../utils/DateUtils";
import { seasonStatusStore } from "./ScheduleStore";
import { SeasonStatus } from "../ic-agent/League";


export const liveMatchGroupStore = (() => {
  const { subscribe, set } = writable<MatchGroup>();
  let nextMatchTimeout: NodeJS.Timeout;
  let liveMatchInterval: NodeJS.Timeout;


  const refetchMatchGroup = async (stadiumId: Principal, matchGroupId: number) => {
    stadiumAgentFactory(stadiumId)
      .getMatchGroup(matchGroupId)
      .then((matchGroupOrNull: [MatchGroup] | []) => {
        if (matchGroupOrNull.length === 0) {
          return;
        }
        let matchGroup = matchGroupOrNull[0];
        set(matchGroup);
      });
  };


  seasonStatusStore.subscribe((status: SeasonStatus) => {
    if ('notStarted' in status || 'starting' in status || 'completed' in status) {
      if (liveMatchInterval) {
        clearInterval(liveMatchInterval);
      }
      if (nextMatchTimeout) {
        clearTimeout(nextMatchTimeout);
      }
      return;
    }
    // Find next one that is live or scheduled
    for (let matchGroupSchedule of status.inProgress.matchGroups) {
      if ('inProgress' in matchGroupSchedule.status) {
        // If live, then set a recurring timer for every 5 seconds
        if (liveMatchInterval) {
          clearInterval(liveMatchInterval);
        }
        let stadiumId = matchGroupSchedule.status.inProgress.stadiumId;
        refetchMatchGroup(stadiumId, matchGroupSchedule.id);
        liveMatchInterval = setInterval(
          () => refetchMatchGroup(stadiumId, matchGroupSchedule.id),
          5000
        );
        // Dont break, to set next match timer
      } else if ('notStarted' in matchGroupSchedule.status) {
        // Set a timer for 
        if (nextMatchTimeout) {
          clearTimeout(nextMatchTimeout);
        }
        let waitMillis = nanosecondsToDate(matchGroupSchedule.time).getTime() - Date.now();
        nextMatchTimeout = setTimeout(() => seasonStatusStore.refetch(), waitMillis);
        break;
      } else {
        // Match group is completed, skip
        continue;
      }
    }
    throw "No match groups are next but the season is in progress";
  });


  return {
    subscribe
  };
})();


