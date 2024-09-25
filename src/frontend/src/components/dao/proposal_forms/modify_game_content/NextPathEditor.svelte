<script lang="ts">
  import { Input, Button } from "flowbite-svelte";
  import {
    NextPathKind,
    WeightedScenarioPathOption,
  } from "../../../../ic-agent/declarations/main";
  import PathEffectEditor from "./PathEffectEditor.svelte";

  export let value: NextPathKind;

  function addEffect(path: WeightedScenarioPathOption) {
    path.effects = [...path.effects, { damage: { raw: 0n } }];
  }

  function removeEffect(path: WeightedScenarioPathOption, index: number) {
    path.effects = path.effects.filter((_, i) => i !== index);
  }

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
  <div>None</div>
{:else if "single" in value}
  <Input type="text" bind:value={value.single} placeholder="Path ID" />
{:else if "multi" in value}
  {#each value.multi as path, pathIndex}
    <div class="border p-4 mb-4">
      <Input type="number" bind:value={path.weight} placeholder="Weight" />
      <Input
        type="text"
        bind:value={path.description}
        placeholder="Description"
      />
      <Input type="text" bind:value={path.pathId} placeholder="Path ID" />

      <h4 class="mt-4 mb-2">Effects:</h4>
      {#each path.effects as effect, effectIndex}
        <div class="mb-2 pl-4 border-l-2">
          <PathEffectEditor bind:value={effect} />
          <Button
            color="red"
            size="xs"
            class="mt-1"
            on:click={() => removeEffect(path, effectIndex)}
            >Remove Effect</Button
          >
        </div>
      {/each}
      <Button
        color="green"
        size="sm"
        class="mt-2"
        on:click={() => addEffect(path)}>Add Effect</Button
      >

      <Button
        color="red"
        size="sm"
        class="mt-4"
        on:click={() => removePath(pathIndex)}>Remove Path</Button
      >
    </div>
  {/each}
  <Button color="blue" on:click={addPath}>Add Path</Button>
{/if}
