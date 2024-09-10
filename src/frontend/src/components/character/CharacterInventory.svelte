<script lang="ts">
  import { InventorySlotWithMetaData } from "../../ic-agent/declarations/main";
  import CharacterItem from "./CharacterItem.svelte";

  export let value: InventorySlotWithMetaData[];
</script>

<ul class="text-md flex">
  {#each value as slot}
    <li>
      <CharacterInventorySlot value={slot} />
    </li>
  {/each}
</ul>
