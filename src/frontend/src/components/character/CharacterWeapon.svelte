<script lang="ts">
  import { Tooltip } from "flowbite-svelte";
  import { Weapon } from "../../ic-agent/declarations/main";
  import { weaponStore } from "../../stores/WeaponStore";
  import { decodeImageToPixels } from "../../utils/PixelUtil";
  import PixelArtCanvas from "../common/PixelArtCanvas.svelte";

  export let value: Weapon | string;

  $: weapons = $weaponStore;

  $: if (typeof value === "string") {
    let foundItem = weapons?.find((i) => i.id === value);
    if (foundItem) {
      value = foundItem;
    }
  }
</script>

<span>
  {#if typeof value !== "string"}
    <span class="text-xl">
      <PixelArtCanvas layers={[decodeImageToPixels(value.image, 32, 32)]} />
    </span>
    <Tooltip>
      <div class="text-sm">
        {value.name}
        <br />
        {value.description}
      </div>
    </Tooltip>
  {/if}
</span>
