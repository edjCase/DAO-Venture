<script lang="ts">
  import { gameStateStore } from "../../stores/GameStateStore";
  import { scenarioStore } from "../../stores/ScenarioStore";

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
    {#if hasCharacter}
      <circle
        cx="0"
        cy="-0.25em"
        r="1.5em"
        fill="black"
        stroke="rgb(156, 163, 175)"
        stroke-width="0.2em"
      />
    {/if}
    <text
      x="0"
      y="0"
      dominant-baseline="middle"
      text-anchor="middle"
      font-size="2em"
      style="pointer-events: none; user-select: none;"
    >
      {#if scenario}
        {scenario.metaData.id}
      {/if}
    </text>
  </g>
{/if}
