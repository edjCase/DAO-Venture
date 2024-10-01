<script lang="ts">
  import EntityView from "./EntityView.svelte";
  import UnlockRequirementView from "./UnlockRequirementView.svelte";
  import { Weapon } from "../../../../ic-agent/declarations/main";
  import PixelArtCanvas from "../../../common/PixelArtCanvas.svelte";
  import { decodeImageToPixels } from "../../../../utils/PixelUtil";

  export let weapon: Weapon;
  $: layers = [decodeImageToPixels(weapon.image, 32, 32)];
</script>

<div>
  <div class="text-xl text-primary-500 font-bold">Weapon</div>
  <EntityView entity={weapon} />
  <PixelArtCanvas {layers} pixelSize={2} />
  <div class="text-primary-500">Unlock Requirement</div>
  <UnlockRequirementView value={weapon.unlockRequirement} />
  <div class="text-primary-500">Actions</div>
  <div>{weapon.actionIds.join(", ")}</div>
</div>
