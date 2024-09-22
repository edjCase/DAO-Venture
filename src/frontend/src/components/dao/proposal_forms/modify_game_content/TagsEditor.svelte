<script lang="ts">
  import { Input } from "flowbite-svelte";

  export let value: string[];

  let selectedTags = value.join(", ");

  const handleTagsChange = () => {
    value = selectedTags.split(",").map((tag) => tag.trim());
  };
</script>

<Input
  id="tags"
  type="text"
  bind:value={selectedTags}
  on:change={handleTagsChange}
  placeholder="tag1,tag2,tag3"
/>
