<script lang="ts">
  import EntityView from "./EntityView.svelte";
  import UnlockRequirementView from "./UnlockRequirementView.svelte";
  import ActionsView from "./ActionsView.svelte";
  import { Weapon } from "../../../../ic-agent/declarations/main";
  import PixelArtCanvas from "../../../common/PixelArtCanvas.svelte";
  import { decodeImageToPixels } from "../../../../utils/PixelUtil";

  export let weapon: Weapon;
  $: layers = [decodeImageToPixels(weapon.image, 32, 32)];
</script>

<div>
  <div>Weapon</div>
  <EntityView entity={weapon} />
  <PixelArtCanvas {layers} pixelSize={2} />
  <UnlockRequirementView value={weapon.unlockRequirement} />
  <ActionsView actionIds={weapon.actionIds} />
</div>
