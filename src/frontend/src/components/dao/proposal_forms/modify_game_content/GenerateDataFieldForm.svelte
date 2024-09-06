<script lang="ts">
  import { GeneratedDataField } from "../../../../ic-agent/declarations/main";
  import { Input, Label, Select } from "flowbite-svelte";
  import { toJsonString } from "../../../../utils/StringUtil";

  export let value: GeneratedDataField;

  let fieldTypes = [
    { value: "nat", name: "Number" },
    { value: "text", name: "Text" },
  ];

  let selectedFieldType: "nat" | "text" = "nat";

  $: {
    if (selectedFieldType === "nat" && !("nat" in value.value)) {
      value.value = { nat: { min: 0n, max: 0n } };
    } else if (selectedFieldType === "text" && !("text" in value.value)) {
      value.value = { text: { options: [] } };
    }
  }

  function addTextOption() {
    if ("text" in value.value) {
      value.value.text.options = [...value.value.text.options, ["", 1]];
    }
  }

  function removeTextOption(index: number) {
    if ("text" in value.value) {
      value.value.text.options = value.value.text.options.filter(
        (_, i) => i !== index
      );
    }
  }
</script>

<div class="border p-4 mb-4 rounded">
  <Label for="id">Id</Label>
  <Input id="id" type="text" bind:value={value.id} placeholder="field_id" />

  <Label for="name">Name</Label>
  <Input
    id="name"
    type="text"
    bind:value={value.name}
    placeholder="Field Name"
  />

  <Label for="fieldType">Field Type</Label>
  <Select id="fieldType" items={fieldTypes} bind:value={selectedFieldType} />

  {#if "nat" in value.value}
    <div class="flex gap-2 mt-2">
      <div>
        <Label for="min">Min</Label>
        <Input id="min" type="number" bind:value={value.value.nat.min} />
      </div>
      <div>
        <Label for="max">Max</Label>
        <Input id="max" type="number" bind:value={value.value.nat.max} />
      </div>
    </div>
  {:else if "text" in value.value}
    <Label>Text Options</Label>
    {#each value.value.text.options as option, index}
      <div class="flex gap-2 mt-2">
        <Input type="text" bind:value={option[0]} placeholder="Option text" />
        <Input type="number" bind:value={option[1]} placeholder="Weight" />
        <button
          class="bg-red-500 text-white px-2 py-1 rounded"
          on:click={() => removeTextOption(index)}>Remove</button
        >
      </div>
    {/each}
    <button
      class="bg-blue-500 text-white px-2 py-1 rounded mt-2"
      on:click={addTextOption}>Add Option</button
    >
  {:else}
    NOT IMPLEMENTED VALUE TYPE: {toJsonString(value.value)}
  {/if}
</div>
