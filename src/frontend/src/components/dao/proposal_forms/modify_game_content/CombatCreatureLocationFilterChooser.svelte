<script lang="ts">
  import { Select } from "flowbite-svelte";
  import { CombatCreatureLocationFilter } from "../../../../ic-agent/declarations/main";
  import EntitySelector from "./EntitySelector.svelte";
  import { zoneStore } from "../../../../stores/ZoneStore";

  export let value: CombatCreatureLocationFilter;

  const filterItems = [
    { value: "any", name: "Any" },
    { value: "zone", name: "Zone" },
    { value: "common", name: "Common" },
  ];
  let selectedKind: string = Object.keys(value)[0];

  let handleKindChange = () => {
    if (selectedKind === "any") {
      value = { any: null };
    } else if (selectedKind === "zone") {
      value = { zone: "" };
    } else if (selectedKind === "common") {
      value = { common: null };
    }
  };
</script>

<Select
  items={filterItems}
  bind:value={selectedKind}
  on:change={handleKindChange}
/>

{#if "zone" in value}
  <EntitySelector value={value.zone} store={zoneStore} label="Zone" />
{/if}
