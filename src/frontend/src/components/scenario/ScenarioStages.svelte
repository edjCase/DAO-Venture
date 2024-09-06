<script lang="ts">
  import {
    ScenarioMetaData,
    ScenarioStageResult,
  } from "../../ic-agent/declarations/main";
  import ScenarioStage from "./ScenarioStage.svelte";

  export let stages: ScenarioStageResult[];
  export let scenarioMetaData: ScenarioMetaData;
</script>

<div class="text-3xl text-primary-500">Stages</div>
{#each stages as stage}
  <ScenarioStage {stage} {scenarioMetaData} />
{/each}
