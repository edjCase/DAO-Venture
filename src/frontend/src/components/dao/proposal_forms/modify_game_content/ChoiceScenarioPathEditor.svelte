<script lang="ts">
  import { Label, Accordion, AccordionItem, Button } from "flowbite-svelte";
  import { ChoicePath } from "../../../../ic-agent/declarations/main";
  import ChoiceForm from "./ChoiceForm.svelte";
  import { PlusSolid, TrashBinSolid } from "flowbite-svelte-icons";

  export let value: ChoicePath;

  function addChoice() {
    value.choices = [
      ...value.choices,
      {
        id: "",
        description: "",
        effects: [],
        requirement: [],
        nextPath: { none: null },
      },
    ];
  }

  function removeChoice(index: number) {
    value.choices = value.choices.filter((_, i) => i !== index);
  }
</script>

<div>
  <div class="flex items-center gap-2">
    <Label>Choices</Label>
    <Button on:click={addChoice}>
      <PlusSolid size="xs" />
    </Button>
  </div>
  <Accordion>
    {#each value.choices as choice, index}
      <AccordionItem>
        <div
          slot="header"
          class="flex justify-between items-center w-full pr-10"
        >
          <span>{choice.id}</span>
          <Button on:click={() => removeChoice(index)} color="red">
            <TrashBinSolid size="xs" />
          </Button>
        </div>
        <ChoiceForm bind:value={choice} />
      </AccordionItem>
    {/each}
  </Accordion>
</div>
