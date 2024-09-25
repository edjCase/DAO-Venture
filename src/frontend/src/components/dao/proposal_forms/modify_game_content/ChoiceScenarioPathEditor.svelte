<script lang="ts">
  import { Label } from "flowbite-svelte";
  import { ChoicePath } from "../../../../ic-agent/declarations/main";
  import ChoiceForm from "./ChoiceForm.svelte";

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
  <Label>Choices</Label>
  {#each value.choices as choice, index}
    <ChoiceForm bind:value={choice} />
    <button
      class="mt-2 bg-red-500 text-white px-2 py-1"
      on:click={() => removeChoice(index)}
    >
      Remove Choice
    </button>
  {/each}
  <button class="bg-blue-500 text-white px-4 py-2" on:click={addChoice}>
    Add Choice
  </button>
</div>
