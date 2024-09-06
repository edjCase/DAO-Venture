<script lang="ts">
  import { Tooltip } from "flowbite-svelte";
  import PixelArtCanvas from "../common/PixelArtCanvas.svelte";
  import { decodeImageToPixels } from "../../utils/PixelUtil";
  import { Item } from "../../ic-agent/declarations/main";

  export let item: Item;
</script>

<div>
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
</div>
