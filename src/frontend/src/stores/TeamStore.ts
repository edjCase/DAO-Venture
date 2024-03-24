import { writable } from "svelte/store";
import { TeamStandingInfo, TeamWithId } from "../ic-agent/declarations/league";
import { leagueAgentFactory } from "../ic-agent/League";
import { Subscriber } from "svelte/motion";




export const teamStore = (() => {
  const { subscribe, set } = writable<TeamWithId[]>([]);
  const teamStandingsWritable = writable<TeamStandingInfo[]>([]);

  const refetch = async () => {
    let leagueAgent = await leagueAgentFactory();
    leagueAgent
      .getTeams().then((teams) => {
        set(teams);
      });
  };

  const subscribeTeamStandings = async (subscriber: Subscriber<TeamStandingInfo[]>) => {
    return teamStandingsWritable.subscribe(subscriber);
  }

  const refetchTeamStandings = async () => {
    let leagueAgent = await leagueAgentFactory();
    let result = await leagueAgent.getTeamStandings();
    if ('ok' in result) {
      teamStandingsWritable.set(result.ok);
    } else {
      console.error("Failed to get team standings: ", result);
    }
  }


  refetch();
  refetchTeamStandings();


  return {
    subscribeTeamStandings,
    refetchTeamStandings,
    subscribe,
    refetch
  };
})();
