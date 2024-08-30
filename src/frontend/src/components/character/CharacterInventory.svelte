<script lang="ts">
  import { Tooltip } from "flowbite-svelte";
  import { Item } from "../../ic-agent/declarations/main";

  export let items: Item[];
</script>

<ul class="text-md flex">
  {#each items as item}
    <li>
      <div class="text-xl">📦</div>
      <Tooltip>
        <div class="text-sm">
          {item.name}
          <br />
          {item.description}
        </div>
      </Tooltip>
    </li>
  {/each}
</ul>
