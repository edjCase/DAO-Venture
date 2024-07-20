<script lang="ts">
  import { Town } from "../../ic-agent/declarations/main";
  import { townStore } from "../../stores/TownStore";
  import TownLogo from "../town/TownLogo.svelte";

  export let championTownId: bigint;
  export let runnerUpTownId: bigint;

  let championTown: Town | undefined;
  let runnerUpTown: Town | undefined;
  townStore.subscribe((towns) => {
    championTown = towns?.find((town) => town.id == championTownId);
    runnerUpTown = towns?.find((town) => town.id == runnerUpTownId);
  });
</script>

{#if championTown && runnerUpTown}
  <div class="flex flex-col items-center space-y-4">
    <div
      class="text-6xl text-center flex flex-col items-center bg-gray-800 p-4 rounded-lg shadow-lg"
    >
      {championTown.name}
      <TownLogo town={championTown} size="lg" />
      <div class="text-4xl mt-4">👑 Season Champions 👑</div>
    </div>
    <div
      class="text-sm text-center flex flex-col items-center bg-gray-500 p-2 rounded-lg shadow-lg"
    >
      {runnerUpTown.name}
      <TownLogo town={runnerUpTown} size="lg" />
      <div>🥈 Runner-up 🥈</div>
    </div>
  </div>
{/if}
