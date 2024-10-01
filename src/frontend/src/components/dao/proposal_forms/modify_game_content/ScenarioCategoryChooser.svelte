<script lang="ts">
  import { Select, SelectOptionType } from "flowbite-svelte";
  import { ScenarioCategory } from "../../../../ic-agent/declarations/main";

  export let value: ScenarioCategory;

  const categories: SelectOptionType<string>[] = [
    { value: "other", name: "Other" },
    { value: "store", name: "Store" },
    { value: "combat", name: "Combat" },
  ];

  let selectedCategory: string = Object.keys(value)[0];

  function updateCategory() {
    value = { [selectedCategory]: null } as ScenarioCategory;
  }
</script>

<Select
  id="category"
  items={categories}
  bind:value={selectedCategory}
  on:change={updateCategory}
/>
