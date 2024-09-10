<script lang="ts">
  import { InventorySlotWithMetaData } from "../../ic-agent/declarations/main";
  import CharacterItem from "./CharacterItem.svelte";

  export let value: InventorySlotWithMetaData;
</script>

{#if slot.item[0] !== undefined}
  <CharacterItem item={slot.item[0]} />
{:else}
  <div>-</div>
{/if}
