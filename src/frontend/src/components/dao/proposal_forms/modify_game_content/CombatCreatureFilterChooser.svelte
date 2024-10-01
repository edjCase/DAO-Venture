<script lang="ts">
  import { Select } from "flowbite-svelte";
  import { CombatCreatureFilter } from "../../../../ic-agent/declarations/main";
  import { toJsonString } from "../../../../utils/StringUtil";
  import CombatCreatureLocationFilterChooser from "./CombatCreatureLocationFilterChooser.svelte";

  export let value: CombatCreatureFilter;

  const filterItems = [{ value: "location", name: "Location" }];

  let selectedKind: string = Object.keys(value)[0];

  let handleKindChange = () => {
    if (selectedKind === "location") {
      value = { location: { any: null } };
    }
  };
</script>

<Select
  items={filterItems}
  bind:value={selectedKind}
  on:change={handleKindChange}
/>

{#if "location" in value}
  <CombatCreatureLocationFilterChooser bind:value={value.location} />
{:else}
  NOT IMPLEMENTED COMBAT CREATURE FILTER: {toJsonString(value)}
{/if}
