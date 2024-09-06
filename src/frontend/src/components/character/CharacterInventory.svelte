<script lang="ts">
  import { Item } from "../../ic-agent/declarations/main";
  import CharacterItem from "./CharacterItem.svelte";

  export let items: Item[];
</script>

<ul class="text-md flex">
  {#each items as item}
    <li>
      <CharacterItem {item} />
    </li>
  {/each}
</ul>
