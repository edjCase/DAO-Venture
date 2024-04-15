import { writable } from "svelte/store";
import { TeamStandingInfo, Team } from "../ic-agent/declarations/league";
import { leagueAgentFactory } from "../ic-agent/League";
import { TeamLinks } from "../ic-agent/declarations/teams";
import { teamsAgentFactory } from "../ic-agent/Teams";




export const teamStore = (() => {
  const teamsStore = writable<Team[] | undefined>();
  const teamStandingsWritable = writable<TeamStandingInfo[] | undefined>();
  const teamLinks = writable<TeamLinks[] | undefined>();

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
    } else if ('notFound' in result) {
      teamStandingsWritable.set(undefined);
    } else {
      console.error("Failed to get team standings: ", result);
    }
  }

  const refetchTeamLinks = async () => {
    let teamsAgent = await teamsAgentFactory();
    let result = await teamsAgent.getLinks();
    if ('ok' in result) {
      teamLinks.set(result.ok);
    } else {
      console.error("Failed to get team links: ", result);
    }
  }



  refetch();
  refetchTeamStandings();
  refetchTeamLinks();


  return {
    subscribeTeamLinks: teamLinks.subscribe,
    refetchTeamLinks,
    subscribeTeamStandings: teamStandingsWritable.subscribe,
    refetchTeamStandings,
    subscribe: teamsStore.subscribe,
    refetch
  };
})();
