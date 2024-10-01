<script lang="ts">
  import { Input, Select, SelectOptionType } from "flowbite-svelte";

  export let value: [] | [bigint];

  const items: SelectOptionType<string>[] = [
    { name: "Indefinite", value: "indefinite" },
    { name: "Turns", value: "turns" },
  ];

  let selectedOption: string;
  if (value.length < 1) {
    selectedOption = "indefinite";
  } else {
    selectedOption = "turns";
  }

  const updateDuration = () => {
    if (selectedOption === "turns") {
      value = [1n];
    } else {
      value = [];
    }
  };
</script>

<Select {items} bind:value={selectedOption} on:change={updateDuration} />
{#if value.length > 0}
  <Input type="number" bind:value={value[0]} placeholder="Duration" />
{/if}
