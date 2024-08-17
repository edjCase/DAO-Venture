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
      {#if scenario}{#if "mysteriousStructure" in scenario.kind}
          🏛️
        {:else if "goblinRaidingParty" in scenario.kind}
          🏹
        {:else if "lostElfling" in scenario.kind}
          🧝
        {:else if "sinkingBoat" in scenario.kind}
          🚣
        {:else if "darkElfAmbush" in scenario.kind}
          🗡️
        {:else if "corruptedTreant" in scenario.kind}
          🌲
        {:else if "trappedDruid" in scenario.kind}
          🧙
        {:else if "wanderingAlchemist" in scenario.kind}
          🧪
        {:else if "dwarvenWeaponsmith" in scenario.kind}
          🔨
        {:else if "fairyMarket" in scenario.kind}
          🧚
        {:else if "enchantedGrove" in scenario.kind}
          🍃
        {:else if "knowledgeNexus" in scenario.kind}
          📖
        {:else if "mysticForge" in scenario.kind}
          🛠️
        {:else if "travelingBard" in scenario.kind}
          🎵
        {:else if "druidicSanctuary" in scenario.kind}
          🌿
        {:else}
          ❓
        {/if}
      {/if}
    </text>
  </g>
{/if}
