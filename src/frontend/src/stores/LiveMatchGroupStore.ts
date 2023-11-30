import { writable } from "svelte/store";
import { LiveMatchGroup, stadiumAgentFactory } from "../ic-agent/Stadium";
import { nanosecondsToDate } from "../utils/DateUtils";
import { Principal } from "@dfinity/principal";
import { SeasonStatus } from "../models/Season";
import { scheduleStore } from "./ScheduleStore";


export const liveMatchGroupStore = (() => {
  const { subscribe, set } = writable<LiveMatchGroup>();
  let nextMatchTimeout: NodeJS.Timeout;
  let liveMatchInterval: NodeJS.Timeout;


  const refetchMatchGroup = async (stadiumId: Principal, matchGroupId: number) => {
    stadiumAgentFactory(stadiumId)
      .getMatchGroup(BigInt(matchGroupId))
      .then((matchGroupOrNull: [LiveMatchGroup] | []) => {
        if (matchGroupOrNull.length === 0) {
          return;
        }
        let matchGroup = matchGroupOrNull[0];
        set(matchGroup);
      });
  };


  scheduleStore.subscribeStatus((status: SeasonStatus) => {
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
    for (let [index, matchGroup] of status.inProgress.matchGroups.entries()) {
      if ('inProgress' in matchGroup) {
        // If live, then set a recurring timer for every 5 seconds
        if (liveMatchInterval) {
          clearInterval(liveMatchInterval);
        }
        let stadiumId = matchGroup.inProgress.stadiumId;
        refetchMatchGroup(stadiumId, index);
        liveMatchInterval = setInterval(
          () => refetchMatchGroup(stadiumId, index),
          5000
        );
        // Dont break, to set next match timer
      } else if ('scheduled' in matchGroup) {
        // Set a timer for 
        if (nextMatchTimeout) {
          clearTimeout(nextMatchTimeout);
        }
        let waitMillis = nanosecondsToDate(matchGroup.scheduled.time).getTime() - Date.now();
        nextMatchTimeout = setTimeout(() => scheduleStore.refetch(), waitMillis);
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


