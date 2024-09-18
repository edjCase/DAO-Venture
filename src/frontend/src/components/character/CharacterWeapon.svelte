<script lang="ts">
  import { Tooltip } from "flowbite-svelte";
  import { Weapon } from "../../ic-agent/declarations/main";
  import { weaponStore } from "../../stores/WeaponStore";

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
      WEAPON: TODO IMAGE
      <!-- <PixelArtCanvas pixels={decodeImageToPixels(value.image, 16, 16)} /> -->
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
