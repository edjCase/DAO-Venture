<script lang="ts">
  import { Select, SelectOptionType } from "flowbite-svelte";
  import { NatValue } from "../../../../ic-agent/declarations/main";
  import NatValueEditor from "./NatValueEditor.svelte";

  export let value: NatValue;

  let items: SelectOptionType<string>[] = [
    { name: "Raw", value: "raw" },
    { name: "Data Field", value: "dataField" },
    { name: "Random", value: "random" },
  ];
  let selectedItem: string;

  let updateValue = () => {
    if (selectedItem === "raw") {
      value = { raw: 0n };
    } else if (selectedItem === "dataField") {
      value = { dataField: "f1" };
    } else if (selectedItem === "random") {
      value = { random: [0n, 1n] };
    }
  };
</script>

<Select {items} bind:value={selectedItem} on:change={updateValue} />
<NatValueEditor bind:value />
