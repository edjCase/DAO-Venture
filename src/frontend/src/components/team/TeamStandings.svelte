<script lang="ts">
  import {
    CompletedSeason,
    CompletedSeasonTown,
    Town,
  } from "../../ic-agent/declarations/main";
  import TeamFlag from "./TeamFlag.svelte";
  import { townStore } from "../../stores/TownStore";

  export let completedSeason: CompletedSeason;

  $: towns = $townStore;

  $: townsWithS =
    towns == undefined
      ? undefined
      : completedSeason.towns.map<[CompletedSeasonTown, Town]>((t) => [
          t,
          towns.find((town) => town.id == t.id)!,
        ]);
</script>

<div>
  <div class="text-center text-3xl font-bold my-4">Towns</div>
  <div class="flex flex-wrap">
    {#if townsWithS}
      {#each townsWithS as [c, town]}
        <div class="mb-1 mx-2">
          <TeamFlag {town} size="sm" />
          <div class="w-full text-center">{c.wins} - {c.losses}</div>
        </div>
      {/each}
    {/if}
  </div>
</div>
