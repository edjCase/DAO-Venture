<script lang="ts">
  import { Select } from "flowbite-svelte";
  import { CombatCreatureKind } from "../../../../ic-agent/declarations/main";
  import EntitySelector from "./EntitySelector.svelte";
  import { creatureStore } from "../../../../stores/CreatureStore";
  import CombatCreatureFilterChooser from "./CombatCreatureFilterChooser.svelte";

  export let value: CombatCreatureKind;

  let creatureKinds = [
    { value: "id", name: "By Id" },
    { value: "filter", name: "By Filter" },
  ];
  let selectedKind: string = Object.keys(value)[0];

  let handleKindChange = () => {
    if (selectedKind === "id") {
      value = { id: "" };
    } else if (selectedKind === "filter") {
      value = { filter: { location: { any: null } } };
    }
  };
</script>

<Select
  id="kind"
  items={creatureKinds}
  bind:value={selectedKind}
  on:change={handleKindChange}
/>
{#if "id" in value}
  <EntitySelector value={value.id} store={creatureStore} label="Creature" />
{:else if "filter" in value}
  <CombatCreatureFilterChooser bind:value={value.filter} />
{/if}
