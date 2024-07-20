<script lang="ts">
  import { townStore } from "../../stores/TownStore";
  import MatchUpTown from "./MatchUpTown.svelte";

  export let matchGroupId: number;
  export let matchId: number;
  export let town1Id: bigint;
  export let town2Id: bigint;

  $: towns = $townStore;

  $: town1 = towns?.find((t) => t.id == town1Id);
  $: town2 = towns?.find((t) => t.id == town2Id);
</script>

{#if town1 && town2}
  <div class="bg-gray-700 rounded-lg p-4">
    <div class="flex flex-col gap-2">
      <MatchUpTown
        {matchGroupId}
        {matchId}
        town={town1}
        townId={{ town1: null }}
      />
      <div class="text-xs text-center">VS</div>
      <MatchUpTown
        {matchGroupId}
        {matchId}
        town={town2}
        townId={{ town2: null }}
      />
    </div>
  </div>
{/if}
