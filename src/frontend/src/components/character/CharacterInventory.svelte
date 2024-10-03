<script lang="ts">
  import { InventorySlotWithMetaData } from "../../ic-agent/declarations/main";
  import CharacterInventorySlot from "./CharacterInventorySlot.svelte";

  export let value: InventorySlotWithMetaData[];
</script>

<ul class="text-md flex flex-wrap justify-center">
  {#each value as slot}
    <li>
      <CharacterInventorySlot value={slot} />
    </li>
  {/each}
</ul>
