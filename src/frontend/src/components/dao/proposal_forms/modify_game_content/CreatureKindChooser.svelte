<script lang="ts">
  import { Select } from "flowbite-svelte";
  import { CreatureKind } from "../../../../ic-agent/declarations/main";

  export let value: CreatureKind;

  let creatureKinds = [
    { value: "normal", name: "Normal", kind: { normal: null } },
    { value: "elite", name: "Elite", kind: { elite: null } },
    { value: "boss", name: "Boss", kind: { boss: null } },
  ];
  let selectedKind: string = Object.keys(value)[0];

  let handleKindChange = () => {
    if (selectedKind === "normal") {
      value = { normal: null };
    } else if (selectedKind === "boss") {
      value = { boss: null };
    } else if (selectedKind === "elite") {
      value = { elite: null };
    }
  };
</script>

<Select
  id="kind"
  items={creatureKinds}
  bind:value={selectedKind}
  on:change={handleKindChange}
/>
