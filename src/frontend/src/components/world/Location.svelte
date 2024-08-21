<script lang="ts">
  import { gameStateStore } from "../../stores/GameStateStore";
  import { scenarioStore } from "../../stores/ScenarioStore";
  import GameImage from "../common/GameImage.svelte";

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
        <GameImage id={scenario.metaData.imageId} />
      </foreignObject>
    {/if}
  </g>
{/if}
