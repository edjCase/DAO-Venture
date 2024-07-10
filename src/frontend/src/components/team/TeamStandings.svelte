<script lang="ts">
  import {
    CompletedSeason,
    CompletedSeasonTeam,
    Team,
  } from "../../ic-agent/declarations/main";
  import TeamLogo from "./TeamLogo.svelte";
  import { teamStore } from "../../stores/TeamStore";

  export let completedSeason: CompletedSeason;

  $: teams = $teamStore;

  $: teamsWithS =
    teams == undefined
      ? undefined
      : completedSeason.teams.map<[CompletedSeasonTeam, Team]>((t) => [
          t,
          teams.find((team) => team.id == t.id)!,
        ]);
</script>

<div>
  <div class="text-center text-3xl font-bold my-4">Teams</div>
  <div class="flex flex-wrap">
    {#if teamsWithS}
      {#each teamsWithS as [c, team]}
        <div class="mb-1 mx-2">
          <TeamLogo {team} size="sm" />
          <div class="w-full text-center">{c.wins} - {c.losses}</div>
        </div>
      {/each}
    {/if}
  </div>
</div>
