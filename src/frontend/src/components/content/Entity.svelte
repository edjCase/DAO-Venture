<script lang="ts">
  import { Tooltip } from "flowbite-svelte";
  import PixelArtCanvas from "../common/PixelArtCanvas.svelte";
  import { decodeImageToPixels } from "../../utils/PixelUtil";
  import { PixelImage } from "../../ic-agent/declarations/main";

  type Entity = {
    id: string;
    name: string;
    description: string;
    image?: PixelImage;
  };
  export let entity: Entity | string;
  export let store: {
    subscribe: (run: (value: Entity[]) => void) => () => void;
  };
  export let pixelSize: number = 1;

  $: entities = $store;

  $: if (typeof entity === "string") {
    let foundEntity = entities?.find((i) => i.id === entity);
    if (foundEntity) {
      entity = foundEntity;
    }
  }
</script>

<span>
  {#if typeof entity !== "string"}
    <span class="text-xl">
      {#if entity.image}
        <PixelArtCanvas
          layers={[decodeImageToPixels(entity.image, 32, 32)]}
          {pixelSize}
        />
      {:else}
        {entity.name}
      {/if}
    </span>
    <Tooltip>
      <div class="text-sm">
        {entity.name}
        <br />
        {entity.description}
      </div>
    </Tooltip>
  {/if}
</span>
