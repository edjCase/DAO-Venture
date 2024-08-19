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

  $: hasCharacter =
    gameState !== undefined && "inProgress" in gameState
      ? gameState.inProgress.characterLocationId == locationId
      : undefined;
</script>

{#if location !== undefined}
  <g>
    {#if scenario}
      <foreignObject width="100%" height="100%" x={-16} y={-16}>
        <PixelArtCanvas pixels={scenario.metaData.icon} pixelSize={2} />
      </foreignObject>
    {/if}
    {#if hasCharacter}
      <circle
        cx="0"
        cy="0"
        r="1.5em"
        fill="none"
        stroke="rgb(156, 163, 175)"
        stroke-width="0.2em"
      />
    {/if}
  </g>
{/if}
