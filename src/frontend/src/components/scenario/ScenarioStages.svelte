<script lang="ts">
  import { ScenarioStageResult } from "../../ic-agent/declarations/main";
  import ScenarioStage from "./ScenarioStage.svelte";

  export let stages: ScenarioStageResult[];
</script>

<div class="text-3xl text-primary-500">Stages</div>
{#each stages as stage}
  <ScenarioStage {stage} />
{/each}
