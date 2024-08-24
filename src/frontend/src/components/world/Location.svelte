<script lang="ts">
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import { scenarioStore } from "../../stores/ScenarioStore";
  import GameImage from "../common/GameImage.svelte";

  export let locationId: bigint;

  $: currentGame = $currentGameStore;
  $: location =
    currentGame !== undefined && "inProgress" in currentGame.state
      ? currentGame.state.inProgress.locations.find((l) => l.id == locationId)
      : undefined;

  $: scenarios = $scenarioStore;
  $: scenario = location && scenarios?.find((s) => s.id == location.scenarioId);

  let size = 40;
</script>

{#if location !== undefined}
  <g>
    {#if scenario}
      <svg x={-size / 2} y={-size / 2} width={size} height={size}>
        <foreignObject width={size} height={size}>
          <GameImage id={scenario.metaData.imageId} />
        </foreignObject>
      </svg>
    {/if}
  </g>
{:else}
  <text x="0" y="0" fill="red">Location not found</text>
{/if}
