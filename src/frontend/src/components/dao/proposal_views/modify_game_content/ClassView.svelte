<script lang="ts">
  import EntityView from "./EntityView.svelte";
  import UnlockRequirementView from "./UnlockRequirementView.svelte";
  import { Class } from "../../../../ic-agent/declarations/main";
  import PixelArtCanvas from "../../../common/PixelArtCanvas.svelte";
  import { decodeImageToPixels } from "../../../../utils/PixelUtil";

  export let class_: Class;

  $: layers = [decodeImageToPixels(class_.image, 32, 32)];
</script>

<div>
  <div class="text-xl text-primary-500 font-bold">Class</div>
  <EntityView entity={class_} />
  <div class="text-primary-500">Weapon</div>
  <div>{class_.weaponId}</div>
  <div class="text-primary-500">Image</div>
  <PixelArtCanvas {layers} pixelSize={2} />
  <div class="text-primary-500">Starting Skill Actions</div>
  <div>{class_.startingSkillActionIds.join(", ")}</div>
  <div class="text-primary-500">Starting Items</div>
  <div>{class_.startingItemIds.join(", ")}</div>
  <UnlockRequirementView value={class_.unlockRequirement} />
</div>
