<script lang="ts">
  import { InventorySlotWithMetaData } from "../../ic-agent/declarations/main";
  import CharacterItem from "../content/Item.svelte";

  export let value: InventorySlotWithMetaData;
</script>

<div class="border rounded w-12 h-12 flex items-center justify-center">
  {#if value.item[0] !== undefined}
    <CharacterItem item={value.item[0]} />
  {/if}
</div>
