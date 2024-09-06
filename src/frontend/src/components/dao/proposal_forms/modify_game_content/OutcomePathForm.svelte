<script lang="ts">
  import { OutcomePath, Effect } from "../../../../ic-agent/declarations/main";
  import { Input, Label, Textarea, Select } from "flowbite-svelte";
  import ConditionEditor from "./ConditionEditor.svelte";

  export let value: OutcomePath;

  let effectTypes = [
    { value: "reward", name: "Reward" },
    { value: "damage", name: "Damage" },
    { value: "heal", name: "Heal" },
    { value: "removeGold", name: "Remove Gold" },
    { value: "addItem", name: "Add Item" },
    { value: "removeItem", name: "Remove Item" },
    { value: "achievement", name: "Achievement" },
  ];

  function addEffect() {
    if ("effects" in value.kind) {
      value.kind.effects = [...value.kind.effects, { reward: null }];
    }
  }

  function removeEffect(index: number) {
    if ("effects" in value.kind) {
      value.kind.effects = value.kind.effects.filter((_, i) => i !== index);
    }
  }

  function addPath() {
    value.paths = [...value.paths, { weight: 1, pathId: "", condition: [] }];
  }

  function removePath(index: number) {
    value.paths = value.paths.filter((_, i) => i !== index);
  }

  function updateEffectType(index: number, newType: string) {
    if ("effects" in value.kind) {
      let newEffect: { [x: string]: any } = { [newType]: null };
      if (
        newType === "damage" ||
        newType === "heal" ||
        newType === "removeGold"
      ) {
        newEffect[newType] = { raw: 0n };
      } else if (newType === "addItem" || newType === "removeItem") {
        newEffect[newType] = { specific: { raw: "" } };
      } else if (newType === "achievement") {
        newEffect[newType] = null;
      }
      value.kind.effects[index] = newEffect as Effect;
    }
  }
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
    {#each value.kind.effects as effect, index}
      <div class="flex gap-2 mt-2">
        <Select
          items={effectTypes}
          value={Object.keys(effect)[0]}
          on:change={(e) => updateEffectType(index, e.target.value)}
        />
        {#if "damage" in effect || "heal" in effect || "removeGold" in effect}
          <Input
            type="number"
            bind:value={effect[Object.keys(effect)[0]].raw}
            placeholder="Value"
          />
        {:else if "addItem" in effect || "removeItem" in effect}
          <Input
            type="text"
            bind:value={effect[Object.keys(effect)[0]].specific.raw}
            placeholder="Item"
          />
        {:else if "achievement" in effect}
          <Input
            type="text"
            bind:value={effect.achievement}
            placeholder="Achievement ID"
          />
        {/if}
        <button
          class="bg-red-500 text-white px-2 py-1 rounded"
          on:click={() => removeEffect(index)}>Remove</button
        >
      </div>
    {/each}
    <button
      class="bg-blue-500 text-white px-2 py-1 rounded mt-2"
      on:click={addEffect}>Add Effect</button
    >
  {:else if "combat" in value.kind}
    TODO
  {/if}

  <Label class="mt-4">Weighted Paths</Label>
  {#each value.paths as path, index}
    <div class="flex gap-2 mt-2">
      <Input type="number" bind:value={path.weight} placeholder="Weight" />
      <Input type="text" bind:value={path.pathId} placeholder="Path ID" />

      <Select
        items={[
          { value: "none", name: "No Condition" },
          { value: "hasGold", name: "Has Gold" },
          { value: "hasItem", name: "Has Item" },
        ]}
        on:change={(e) => (path.condition = [e.target.value])}
      />
      <ConditionEditor bind:value={path.condition} />
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
