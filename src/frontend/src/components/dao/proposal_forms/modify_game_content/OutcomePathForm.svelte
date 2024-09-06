<script lang="ts">
  import { OutcomePath, Effect } from "../../../../ic-agent/declarations/main";
  import { Input, Label, Textarea, Select } from "flowbite-svelte";
  import ConditionEditor from "./ConditionEditor.svelte";
  import NatValueEditor from "./NatValueEditor.svelte";
  import TextValueEditor from "./TextValueEditor.svelte";
  import { achievementStore } from "../../../../stores/AchievementStore";
  import EntitySelector from "./EntitySelector.svelte";

  export let value: OutcomePath;

  let conditionOptions = [
    { value: "none", name: "No Condition" },
    { value: "hasGold", name: "Has Gold" },
    { value: "hasItem", name: "Has Item" },
  ];

  let selectedCondition: string = conditionOptions[0].value;

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
    {#each value.kind.effects as effect, index}
      <div class="flex gap-2 mt-2">
        <Select
          items={effectTypes}
          value={Object.keys(effect)[0]}
          on:change={(e) => updateEffectType(index, e.target.value)}
        />
        {#if "damage" in effect}
          <NatValueEditor bind:value={effect.damage} />
        {:else if "heal" in effect}
          <NatValueEditor bind:value={effect.heal} />
        {:else if "addItem" in effect}
          <TextValueEditor bind:value={effect.addItem} />
        {:else if "removeItem" in effect}
          <TextValueEditor bind:value={effect.removeItem} />
        {:else if "achievement" in effect}
          <EntitySelector
            bind:id={effect.achievement}
            store={achievementStore}
            label="Achievement"
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
