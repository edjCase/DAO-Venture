<script lang="ts">
  import { gameStateStore } from "../../stores/GameStateStore";
  import Scenario from "../scenario/Scenario.svelte";

  export let locationId: bigint;

  $: gameState = $gameStateStore;

  $: location =
    gameState !== undefined && "inProgress" in gameState
      ? gameState.inProgress.locations.find((l) => l.id == locationId)
      : undefined;
</script>

{#if location !== undefined}
  <div class="bg-gray-800 rounded p-2">
    <div class="text-center text-3xl">
      <Scenario scenarioId={location.scenarioId} />
    </div>
  </div>
{/if}
