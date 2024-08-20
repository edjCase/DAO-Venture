<script lang="ts">
  import { gameStateStore } from "../../stores/GameStateStore";
  import { scenarioStore } from "../../stores/ScenarioStore";
  import PixelArtCanvas from "../common/PixelArtCanvas.svelte";

  export let locationId: bigint;

  $: gameState = $gameStateStore;
  $: location =
    gameState !== undefined && "inProgress" in gameState
      ? gameState.inProgress.locations.find((l) => l.id == locationId)
      : undefined;

  $: scenarios = $scenarioStore;
  $: scenario = location && scenarios?.find((s) => s.id == location.scenarioId);
</script>

{#if location !== undefined}
  <g>
    {#if scenario}
      <foreignObject width="100%" height="100%" x={-32} y={-32}>
        <PixelArtCanvas pixels={scenario.metaData.icon} pixelSize={4} />
      </foreignObject>
    {/if}
  </g>
{/if}
