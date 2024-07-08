<script lang="ts">
  import { CompletedSeason, Team } from "../../ic-agent/declarations/main";
  import { teamStore } from "../../stores/TeamStore";
  import TeamLogo from "../team/TeamLogo.svelte";

  export let completedSeason: CompletedSeason;

  let championTeam: Team | undefined;
  let runnerUpTeam: Team | undefined;
  teamStore.subscribe((teams) => {
    championTeam = teams?.find(
      (team) => team.id == completedSeason.championTeamId,
    );
    runnerUpTeam = teams?.find(
      (team) => team.id == completedSeason.runnerUpTeamId,
    );
  });
</script>

{#if championTeam && runnerUpTeam}
  <div class="flex flex-col items-center space-y-4">
    <div
      class="text-6xl text-center flex flex-col items-center bg-gray-800 p-4 rounded-lg shadow-lg"
    >
      {championTeam.name}
      <TeamLogo team={championTeam} size="lg" />
      <div class="text-4xl mt-4">👑 Season Champions 👑</div>
    </div>
    <div
      class="text-sm text-center flex flex-col items-center bg-gray-500 p-2 rounded-lg shadow-lg"
    >
      {runnerUpTeam.name}
      <TeamLogo team={runnerUpTeam} size="lg" />
      <div>🥈 Runner-up 🥈</div>
    </div>
  </div>
{/if}
