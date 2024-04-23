import { writable } from "svelte/store";
import { TeamStandingInfo } from "../ic-agent/declarations/league";
import { leagueAgentFactory } from "../ic-agent/League";
import { teamsAgentFactory } from "../ic-agent/Teams";
import { Team } from "../ic-agent/declarations/teams";




export const teamStore = (() => {
  const teamsStore = writable<Team[] | undefined>();
  const teamStandingsWritable = writable<TeamStandingInfo[] | undefined>();

  const refetch = async () => {
    let teamsAgent = await teamsAgentFactory();
    let teams = await teamsAgent.getTeams();
    teamsStore.set(teams);
  };


  const refetchTeamStandings = async () => {
    let leagueAgent = await leagueAgentFactory();
    let result = await leagueAgent.getTeamStandings();
    if ('ok' in result) {
      teamStandingsWritable.set(result.ok);
    } else if ('notFound' in result) {
      teamStandingsWritable.set(undefined);
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
