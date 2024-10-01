<script lang="ts">
  import EntityView from "./EntityView.svelte";
  import UnlockRequirementView from "./UnlockRequirementView.svelte";
  import { Race } from "../../../../ic-agent/declarations/main";
  import { decodeImageToPixels } from "../../../../utils/PixelUtil";
  import PixelArtCanvas from "../../../common/PixelArtCanvas.svelte";

  export let race: Race;

  $: layers = [decodeImageToPixels(race.image, 32, 32)];
</script>

<div>
  <div class="text-xl text-primary-500 font-bold">Race</div>
  <EntityView entity={race} />
  <div class="text-primary-500">Image</div>
  <PixelArtCanvas {layers} pixelSize={2} />
  <div class="text-primary-500">Starting Skill Actions</div>
  <div>{race.startingSkillActionIds.join(", ")}</div>
  <div class="text-primary-500">Starting Items</div>
  <div>{race.startingItemIds.join(", ")}</div>
  <UnlockRequirementView value={race.unlockRequirement} />
</div>
