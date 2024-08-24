<script lang="ts">
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import Scenario from "../scenario/Scenario.svelte";

  export let locationId: bigint;

  $: currentGame = $currentGameStore;

  $: location =
    currentGame !== undefined && "inProgress" in currentGame.state
      ? currentGame.state.inProgress.locations.find((l) => l.id == locationId)
      : undefined;
</script>

{#if location !== undefined}
  <div class="bg-gray-800 rounded p-2">
    <div class="text-center text-3xl">
      <Scenario scenarioId={location.scenarioId} />
    </div>
  </div>
{/if}
