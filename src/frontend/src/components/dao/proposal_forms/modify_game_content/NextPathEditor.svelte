<script lang="ts">
  import { Input, Select } from "flowbite-svelte";
  import path from "path";
  import { NextPathKind } from "../../../../ic-agent/declarations/main";
  import ConditionEditor from "./ConditionEditor.svelte";

  export let value: NextPathKind;
</script>

{#if "none" in value}
  <div>None</div>
{:else if "single" in value}
  <Input type="text" bind:value={value.single} placeholder="Path ID" />
{:else if "multi" in value}
  {#each value.multi as path, index}
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
  {/each}
{/if}
