<script lang="ts">
  import { Select, SelectOptionType } from "flowbite-svelte";
  import { ZoneDifficulty } from "../../../../ic-agent/declarations/main";

  export let value: ZoneDifficulty;
  let items: SelectOptionType<string>[] = [
    { value: "easy", name: "Easy" },
    { value: "medium", name: "Medium" },
    { value: "hard", name: "Hard" },
  ];
  let selectedItem: string = Object.keys(value)[0];

  let handleChange = () => {
    if (selectedItem === "easy") {
      value = { easy: null };
    } else if (selectedItem === "medium") {
      value = { medium: null };
    } else if (selectedItem === "hard") {
      value = { hard: null };
    }
  };
</script>

<Select {items} bind:value={selectedItem} on:change={handleChange} />
