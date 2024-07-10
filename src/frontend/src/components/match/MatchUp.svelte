<script lang="ts">
  import { teamStore } from "../../stores/TeamStore";
  import MatchUpTeam from "./MatchUpTeam.svelte";

  export let matchGroupId: number;
  export let matchId: number;
  export let team1Id: bigint;
  export let team2Id: bigint;

  $: teams = $teamStore;

  $: team1 = teams?.find((t) => t.id == team1Id);
  $: team2 = teams?.find((t) => t.id == team2Id);
</script>

{#if team1 && team2}
  <div class="bg-gray-700 rounded-lg p-4">
    <div class="flex flex-col gap-2">
      <MatchUpTeam
        {matchGroupId}
        {matchId}
        team={team1}
        teamId={{ team1: null }}
      />
      <div class="text-xs text-center">VS</div>
      <MatchUpTeam
        {matchGroupId}
        {matchId}
        team={team2}
        teamId={{ team2: null }}
      />
    </div>
  </div>
{/if}
