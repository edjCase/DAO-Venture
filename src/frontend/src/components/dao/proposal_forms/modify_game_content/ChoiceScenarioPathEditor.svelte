<script lang="ts">
  import { Label } from "flowbite-svelte";
  import {
    ChoicePath,
    GeneratedDataField,
  } from "../../../../ic-agent/declarations/main";
  import ChoiceForm from "./ChoiceForm.svelte";
  import GeneratedDataFieldForm from "./GeneratedDataFieldForm.svelte";

  export let value: ChoicePath;

  let data: GeneratedDataField[] = [];

  function addDataField() {
    data = [
      ...data,
      { id: "", name: "", value: { nat: { min: 0n, max: 0n } } },
    ];
  }

  function removeDataField(index: number) {
    data = data.filter((_, i) => i !== index);
  }

  function addChoice() {
    value.choices = [
      ...value.choices,
      { id: "", description: "", data: [], effects: [], requirement: [] },
    ];
  }

  function removeChoice(index: number) {
    value.choices = value.choices.filter((_, i) => i !== index);
  }
</script>

<div>
  <Label>Generated Data Fields</Label>
  {#each data as field, index}
    <GeneratedDataFieldForm bind:value={field} />
    <button
      class="mt-2 bg-red-500 text-white px-2 py-1 rounded"
      on:click={() => removeDataField(index)}
    >
      Remove Data Field
    </button>
  {/each}
  <button
    class="bg-blue-500 text-white px-4 py-2 rounded"
    on:click={addDataField}
  >
    Add Data Field
  </button>
</div>

<div>
  <Label>Choices</Label>
  {#each value.choices as choice, index}
    <ChoiceForm bind:value={choice} />
    <button
      class="mt-2 bg-red-500 text-white px-2 py-1 rounded"
      on:click={() => removeChoice(index)}
    >
      Remove Choice
    </button>
  {/each}
  <button class="bg-blue-500 text-white px-4 py-2 rounded" on:click={addChoice}>
    Add Choice
  </button>
</div>
