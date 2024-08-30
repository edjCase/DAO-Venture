<script lang="ts">
  import { Tooltip } from "flowbite-svelte";
  import { Item } from "../../ic-agent/declarations/main";
  import PixelArtCanvas from "../common/PixelArtCanvas.svelte";
  import { decodeImageToPixels } from "../../utils/PixelUtil";

  export let items: Item[];
</script>

<ul class="text-md flex">
  {#each items as item}
    <li>
      <div class="text-xl">
        <PixelArtCanvas pixels={decodeImageToPixels(item.image, 16, 16)} />
      </div>
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
