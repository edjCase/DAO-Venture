<script lang="ts">
  import {
    GameWithMetaData,
    InProgressGameStateWithMetaData,
  } from "../../ic-agent/declarations/main";
  import Scenario from "../scenario/Scenario.svelte";
  import ScenarioHexGrid from "./ScenarioHexGrid.svelte";

  export let game: GameWithMetaData;
  export let state: InProgressGameStateWithMetaData;

  $: currentScenarioId = game.scenarios.findIndex(
    (s) => !("started" in s.state && "completed" in s.state.started.kind)
  ); // First not completed

  let selectedScenarioId: number;
  $: if (selectedScenarioId === undefined) {
    selectedScenarioId = currentScenarioId;
  }

  $: scenario = game.scenarios[selectedScenarioId];
  let nextScenario = () => {
    selectedScenarioId += 1;
  };
</script>

<ScenarioHexGrid
  bind:selectedScenarioId
  scenarios={game.scenarios}
  {currentScenarioId}
/>
{#if scenario !== undefined}
  <Scenario {scenario} character={state.character} {nextScenario} />
{/if}
