<script lang="ts">
  import { CharacterWithMetaData } from "../../ic-agent/declarations/main";
  import PixelArtCanvas from "../common/PixelArtCanvas.svelte";
  import { decodeImageToPixels } from "../../utils/PixelUtil";
  import { Tooltip } from "flowbite-svelte";

  export let character: CharacterWithMetaData;
  export let pixelSize: number;

  $: weaponPixels = decodeImageToPixels(character.weapon.image, 32, 32);

  $: pixelLayers = [
    decodeImageToPixels(character.race.image, 32, 32),
    decodeImageToPixels(character.class.image, 32, 32),
  ];
</script>

<div>
  <PixelArtCanvas layers={pixelLayers} {pixelSize} />
  <Tooltip>
    <div class="text-xl">
      <span class="text-primary-500">{character.race.name}</span> - Race
    </div>
    <div class="text-md">{character.race.description}</div>
    <div class="text-xl">
      <span class="text-primary-500">{character.class.name}</span> - Class
    </div>
    <div class="text-md">{character.class.description}</div>
  </Tooltip>
  <PixelArtCanvas layers={[weaponPixels]} {pixelSize} />
  <Tooltip>
    <div class="text-xl">
      <span class="text-primary-500">{character.weapon.name}</span> - Weapon
    </div>
    <div class="text-md">{character.weapon.description}</div>
  </Tooltip>
</div>
