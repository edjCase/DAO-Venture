<script lang="ts">
  import { Select } from "flowbite-svelte";
  import { Effect } from "../../../../ic-agent/declarations/main";
  import ScenarioEffectEditor from "./ScenarioEffectEditor.svelte";

  export let effects: Effect[];

  let effectTypes = [
    { value: "damage", name: "Damage" },
    { value: "heal", name: "Heal" },
    { value: "removeGold", name: "Remove Gold" },
    { value: "addItem", name: "Add Item" },
    { value: "removeItem", name: "Remove Item" },
    { value: "achievement", name: "Achievement" },
  ];

  let selectedEffect: string = effectTypes[0].value;

  function addEffect() {
    let newEffect: { [x: string]: any } = { [selectedEffect]: null };
    if (
      selectedEffect === "damage" ||
      selectedEffect === "heal" ||
      selectedEffect === "removeGold"
    ) {
      newEffect[selectedEffect] = { raw: 0n };
    } else if (
      selectedEffect === "addItem" ||
      selectedEffect === "removeItem"
    ) {
      newEffect[selectedEffect] = { specific: { raw: "" } };
    } else if (selectedEffect === "achievement") {
      newEffect[selectedEffect] = null;
    }
    effects = [...effects, newEffect as Effect];
  }

  function removeEffect(index: number) {
    effects = effects.filter((_, i) => i !== index);
  }
</script>

{#each effects as effect, index}
  <div class="flex gap-2 mt-2">
    <ScenarioEffectEditor bind:value={effect} />
    <button
      class="bg-red-500 text-white px-2 py-1 rounded"
      on:click={() => removeEffect(index)}>Remove</button
    >
  </div>
{/each}

<Select items={effectTypes} bind:value={selectedEffect} />
<button
  class="bg-blue-500 text-white px-2 py-1 rounded mt-2"
  on:click={addEffect}>Add Effect</button
>
