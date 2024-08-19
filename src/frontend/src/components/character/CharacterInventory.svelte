<script lang="ts">
  import { Item } from "../../ic-agent/declarations/main";

  export let items: Item[];
</script>

<div class="border p-6">
  <ul class="text-md">
    {#each items as item}
      <li>{item.name} - {item.description}</li>
    {/each}
  </ul>
</div>
