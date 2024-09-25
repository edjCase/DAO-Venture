<script lang="ts">
  import { Accordion, AccordionItem } from "flowbite-svelte";
  import { ScenarioStageResult } from "../../ic-agent/declarations/main";
  import ScenarioStage from "./ScenarioStage.svelte";

  export let stages: ScenarioStageResult[];

  $: orderedStages = stages.reverse();
</script>

<div class="text-3xl text-primary-500">Stages</div>
<Accordion border={false} flush={true}>
  {#each orderedStages as stage, i}
    <AccordionItem>
      <span slot="header">
        <div class="text-md text-right">Stage {stages.length - i}</div>
      </span>
      <ScenarioStage {stage} />
    </AccordionItem>
  {/each}
</Accordion>
