<script lang="ts">
  import { InventorySlotWithMetaData } from "../../ic-agent/declarations/main";
  import CharacterItem from "./CharacterItem.svelte";

  export let value: InventorySlotWithMetaData;
</script>

<div class="border rounded p-2">
  {#if value.item[0] !== undefined}
    <CharacterItem item={value.item[0]} />
  {/if}
</div>
