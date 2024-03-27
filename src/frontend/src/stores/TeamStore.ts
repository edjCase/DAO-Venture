import { writable } from "svelte/store";
import { TeamStandingInfo, TeamWithId } from "../ic-agent/declarations/league";
import { leagueAgentFactory } from "../ic-agent/League";




export const teamStore = (() => {
  const teamsStore = writable<TeamWithId[] | undefined>();
  const teamStandingsWritable = writable<TeamStandingInfo[] | undefined>();

  const refetch = async () => {
    let leagueAgent = await leagueAgentFactory();
    let teams = await leagueAgent.getTeams();
    teamsStore.set(teams);
  };


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
    subscribeTeamStandings: teamStandingsWritable.subscribe,
    refetchTeamStandings,
    subscribe: teamsStore.subscribe,
    refetch
  };
})();
