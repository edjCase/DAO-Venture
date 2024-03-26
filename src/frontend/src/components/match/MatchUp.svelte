<script lang="ts">
  import { TeamStandingInfo } from "../../ic-agent/declarations/league";
  import { MatchDetails, TeamDetailsOrUndetermined } from "../../models/Match";
  import { teamStore } from "../../stores/TeamStore";
  import TeamLogo from "../team/TeamLogo.svelte";
  import PredictMatchOutcome from "./PredictMatchOutcome.svelte";

  export let match: MatchDetails;

  let teamStandings: TeamStandingInfo[] | undefined;

  let getTeamName = (team: TeamDetailsOrUndetermined) => {
    if ("name" in team) {
      return team.name;
    }
    return "Undetermined"; // TODO
  };

  teamStore.subscribeTeamStandings((standings) => {
    teamStandings = standings;
  });

  // Placeholder function for getting team stats
  let getTeamStats = (team: TeamDetailsOrUndetermined) => {
    if ("id" in team) {
      const standing = teamStandings?.find((s) => s.id == team.id);
      if (standing) {
        return `(${standing.wins}-${standing.losses})`;
      }
    }
    return "";
  };
</script>

<div class="bg-gray-700 rounded-lg p-4">
  <div class="flex items-center justify-center justify-evently mb-4">
    <div class="flex-1 flex flex-col items-center">
      <span class="team-name font-semibold block mb-2">
        {getTeamName(match.team1)}
        {getTeamStats(match.team1)}
      </span>
      <TeamLogo team={match.team1} size="md" />
      <PredictMatchOutcome {match} teamId={{ team1: null }} />
    </div>
    <span class="text-xl font-bold my-4">VS</span>
    <div class="flex-1 flex flex-col items-center">
      <span class="team-name font-semibold block mb-2">
        {getTeamName(match.team2)}
        {getTeamStats(match.team2)}
      </span>
      <TeamLogo team={match.team2} size="md" />
      <PredictMatchOutcome {match} teamId={{ team2: null }} />
    </div>
  </div>
</div>
