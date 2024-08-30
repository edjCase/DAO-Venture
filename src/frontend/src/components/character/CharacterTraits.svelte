<script lang="ts">
  import { Tooltip } from "flowbite-svelte";
  import { Trait } from "../../ic-agent/declarations/main";
  import PixelArtCanvas from "../common/PixelArtCanvas.svelte";
  import { decodeImageToPixels } from "../../utils/PixelUtil";

  export let traits: Trait[];
</script>

<ul class="flex">
  {#each traits as trait}
    <li>
      <div class="text-xl">
        <PixelArtCanvas pixels={decodeImageToPixels(trait.image, 16, 16)} />
      </div>
      <Tooltip>
        <div class="text-sm">
          {trait.name}
          <br />
          {trait.description}
        </div>
      </Tooltip>
    </li>
  {/each}
</ul>
