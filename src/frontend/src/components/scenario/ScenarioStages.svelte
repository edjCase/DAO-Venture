<script lang="ts">
  import { ScenarioStageResult } from "../../ic-agent/declarations/main";
  import ScenarioStage from "./ScenarioStage.svelte";
  import { ChevronDoubleUpOutline } from "flowbite-svelte-icons";

  export let stages: ScenarioStageResult[];
</script>

{#each [...stages].reverse() as stage}
  <ScenarioStage {stage} />
  <div class="w-full flex justify-center my-4">
    <ChevronDoubleUpOutline />
  </div>
{/each}
