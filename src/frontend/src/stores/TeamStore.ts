import { writable } from "svelte/store";
import { TeamStandingInfo } from "../ic-agent/declarations/main";
import { mainAgentFactory } from "../ic-agent/Main";
import { Team } from "../ic-agent/declarations/main";




export const teamStore = (() => {
  const teamsStore = writable<Team[] | undefined>();
  const teamStandingsWritable = writable<TeamStandingInfo[] | undefined>();

  const refetch = async () => {
    let mainAgent = await mainAgentFactory();
    let teams = await mainAgent.getTeams();
    teamsStore.set(teams);
  };


  const refetchTeamStandings = async () => {
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.getTeamStandings();
    if ('ok' in result) {
      teamStandingsWritable.set(result.ok);
    } else if ('err' in result && 'notFound' in result.err) {
      teamStandingsWritable.set(undefined);
    } else {
      console.error("Failed to get team standings: ", result);
    }
  }


  setInterval(refetch, 1000 * 10); // Refetch every 10 seconds

  refetch();
  refetchTeamStandings();


  return {
    subscribeTeamStandings: teamStandingsWritable.subscribe,
    refetchTeamStandings,
    subscribe: teamsStore.subscribe,
    refetch
  };
})();
