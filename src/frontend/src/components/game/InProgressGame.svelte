<script lang="ts">
  import {
    GameWithMetaData,
    InProgressGameStateWithMetaData,
  } from "../../ic-agent/declarations/main";
  import Scenario from "../scenario/Scenario.svelte";
  import ScenarioHexGrid from "./ScenarioHexGrid.svelte";

  export let game: GameWithMetaData;
  export let state: InProgressGameStateWithMetaData;

  let selectedScenarioId: number = game.scenarios.findIndex(
    (s) => !("started" in s.state && "complete" in s.state.started.kind)
  ); // First not completed

  $: scenario = game.scenarios[selectedScenarioId];
  let nextScenario = () => {
    selectedScenarioId += 1;
  };
</script>

<ScenarioHexGrid bind:selectedScenarioId scenarios={game.scenarios} />

<Scenario {scenario} character={state.character} {nextScenario} />
