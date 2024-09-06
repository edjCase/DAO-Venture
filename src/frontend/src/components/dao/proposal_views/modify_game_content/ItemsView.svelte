<script lang="ts">
  import { itemStore } from "../../../../stores/ItemStore";
  import ItemView from "./ItemView.svelte";

  export let itemIds: string[];

  $: allItems = $itemStore;
  $: items = allItems?.filter((i) => itemIds.includes(i.id));
</script>

<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
  {#if items !== undefined}
    {#each items as item}
      <ItemView {item} />
    {/each}
  {/if}
</div>
