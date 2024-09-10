<script lang="ts">
  import { OutcomePath } from "../../../../ic-agent/declarations/main";
  import { Input, Label, Textarea, Select } from "flowbite-svelte";
  import ConditionEditor from "./ConditionEditor.svelte";

  export let value: OutcomePath;

  let conditionOptions = [
    { value: "none", name: "No Condition" },
    { value: "hasGold", name: "Has Gold" },
    { value: "hasItem", name: "Has Item" },
  ];

  let selectedCondition: string = conditionOptions[0].value;

  function addPath() {
    value.paths = [...value.paths, { weight: 1, pathId: "", condition: [] }];
  }

  function removePath(index: number) {
    value.paths = value.paths.filter((_, i) => i !== index);
  }

  let changeCondition = (pathIndex: number) => () => {
    if (selectedCondition === "none") {
      value.paths[pathIndex].condition = [];
    } else if (selectedCondition === "hasGold") {
      value.paths[pathIndex].condition = [{ hasGold: { raw: 1n } }];
    } else if (selectedCondition === "hasItem") {
      value.paths[pathIndex].condition = [{ hasItem: { raw: "" } }];
    }
  };
</script>

<div class="border p-4 mb-4 rounded">
  <Label for="id">Id</Label>
  <Input id="id" type="text" bind:value={value.id} placeholder="path_id" />

  <Label for="description">Description</Label>
  <Textarea
    id="description"
    bind:value={value.description}
    placeholder="Describe the outcome..."
  />

  {#if "effects" in value.kind}
    <Label>Effects</Label>
  {:else if "combat" in value.kind}
    TODO Combat
  {/if}

  <Label class="mt-4">Weighted Paths</Label>
  {#each value.paths as path, index}
    <div class="flex gap-2 mt-2">
      <Input type="number" bind:value={path.weight} placeholder="Weight" />
      <Input type="text" bind:value={path.pathId} placeholder="Path ID" />

      <Select
        items={conditionOptions}
        bind:value={selectedCondition}
        on:change={changeCondition(index)}
      />
      {#if path.condition[0] !== undefined}
        <ConditionEditor bind:value={path.condition[0]} />
      {/if}
      <button
        class="bg-red-500 text-white px-2 py-1 rounded"
        on:click={() => removePath(index)}>Remove</button
      >
    </div>
  {/each}
  <button
    class="bg-blue-500 text-white px-2 py-1 rounded mt-2"
    on:click={addPath}>Add Path</button
  >
</div>
