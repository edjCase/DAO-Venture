<script lang="ts">
  import { Tooltip } from "flowbite-svelte";
  import PixelArtCanvas from "../common/PixelArtCanvas.svelte";
  import { decodeImageToPixels } from "../../utils/PixelUtil";
  import { Item } from "../../ic-agent/declarations/main";
  import { itemStore } from "../../stores/ItemStore";

  export let item: Item | string;

  $: items = $itemStore;

  $: if (typeof item === "string") {
    let foundItem = items?.find((i) => i.id === item);
    if (foundItem) {
      item = foundItem;
    }
  }
</script>

<span>
  {#if typeof item !== "string"}
    <span class="text-xl">
      <PixelArtCanvas
        pixels={decodeImageToPixels(item.image, 32, 32)}
        pixelSize={1}
      />
    </span>
    <Tooltip>
      <div class="text-sm">
        {item.name}
        <br />
        {item.description}
      </div>
    </Tooltip>
  {/if}
</span>
