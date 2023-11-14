import { writable } from "svelte/store";
import { SeasonSchedule, leagueAgentFactory } from "../ic-agent/League";


export const seasonScheduleStore = (() => {
  const { subscribe, set } = writable<SeasonSchedule | undefined>();

  const refetch = async () => {
    let seasonScheduleOrNull = await leagueAgentFactory()
      .getSeasonSchedule();
    set(seasonScheduleOrNull.length > 0 ? seasonScheduleOrNull[0] : undefined);
  };

  refetch();


  return {
    subscribe,
    refetch
  };
})();


