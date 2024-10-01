<script lang="ts">
  import { Input } from "flowbite-svelte";

  export let value: string[];

  let selectedTags: string = value.join(", ");

  const handleTagsChange = () => {
    value = selectedTags.split(",").map((tag) => tag.trim());
  };
</script>

<Input
  type="text"
  bind:value={selectedTags}
  on:change={handleTagsChange}
  placeholder="a, b, c"
/>
