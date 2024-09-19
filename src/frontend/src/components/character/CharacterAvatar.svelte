<script lang="ts">
  import { CharacterWithMetaData } from "../../ic-agent/declarations/main";
  import PixelArtCanvas from "../common/PixelArtCanvas.svelte";
  import { decodeImageToPixels } from "../../utils/PixelUtil";

  export let size: "xs" | "sm" | "md" | "lg" | "xl";
  export let character: CharacterWithMetaData;

  $: weaponPixels = decodeImageToPixels(character.weapon.image, 32, 32);

  $: pixelLayers = [
    decodeImageToPixels(character.race.image, 32, 32),
    decodeImageToPixels(character.class.image, 32, 32),
  ];
</script>

<PixelArtCanvas layers={pixelLayers} />
<PixelArtCanvas layers={[weaponPixels]} />
