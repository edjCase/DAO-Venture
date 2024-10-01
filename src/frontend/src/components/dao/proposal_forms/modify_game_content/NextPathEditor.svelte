<script lang="ts">
  import { Input, Button, Accordion, AccordionItem } from "flowbite-svelte";
  import { NextPathKind } from "../../../../ic-agent/declarations/main";
  import { PlusSolid, TrashBinSolid } from "flowbite-svelte-icons";
  import WeightedScenarioPathOptionEditor from "./WeightedScenarioPathOptionEditor.svelte";

  export let value: NextPathKind;

  function addPath() {
    if ("multi" in value) {
      value.multi = [
        ...value.multi,
        {
          weight: { kind: { raw: null }, value: 1 },
          description: "",
          pathId: [],
          effects: [],
        },
      ];
    }
  }

  function removePath(index: number) {
    if ("multi" in value) {
      value.multi = value.multi.filter((_, i) => i !== index);
    }
  }
</script>

{#if "none" in value}
  <div>-</div>
{:else if "single" in value}
  <Input type="text" bind:value={value.single} placeholder="Path ID" />
{:else if "multi" in value}
  <Accordion>
    {#each value.multi as path, pathIndex}
      <AccordionItem>
        <div
          slot="header"
          class="flex items-center justify-between pr-10 w-full"
        >
          <span>{pathIndex + 1}</span>

          <Button color="red" on:click={() => removePath(pathIndex)}>
            <TrashBinSolid size="xs" />
          </Button>
        </div>
        <WeightedScenarioPathOptionEditor value={path} />
      </AccordionItem>
    {/each}
  </Accordion>
  <Button color="blue" on:click={addPath}>
    <PlusSolid size="xs" />
  </Button>
{/if}
