<script lang="ts">
  import { Badge } from "flowbite-svelte";

  export let tags: string[];
</script>

<div>
  <div>Tags:</div>
  {#each tags as tag}
    <Badge>{tag}</Badge>
  {/each}
</div>
