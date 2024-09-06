<script lang="ts">
  import { Input, Select } from "flowbite-svelte";
  import { Condition } from "../../../../ic-agent/declarations/main";
  import NatValueEditor from "./NatValueEditor.svelte";
  import { toJsonString } from "../../../../utils/StringUtil";
  export let value: Condition;
</script>

<Select
  items={[
    { value: "none", name: "No Condition" },
    { value: "hasGold", name: "Has Gold" },
    { value: "hasItem", name: "Has Item" },
    { value: "hasTrait", name: "Has Trait" },
  ]}
  bind:value={value ? Object.keys(value)[0] : "none"}
/>
{#if "hasGold" in value}
  <NatValueEditor bind:value={value.hasGold} />
{:else if "hasItem" in value}
  <TextValueEditor bind:value={value.hasItem} />
{:else if "hasTrait" in value}
  <TextValueEditor bind:value={value.hasItem} />
{:else}
  NOT IMPLEMENTED CONDITION : {toJsonString(value)}
{/if}
