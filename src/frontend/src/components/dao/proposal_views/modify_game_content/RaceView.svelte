<script lang="ts">
  import EntityView from "./EntityView.svelte";
  import ActionsView from "./ActionsView.svelte";
  import ItemsView from "./ItemsView.svelte";
  import UnlockRequirementView from "./UnlockRequirementView.svelte";
  import { Race } from "../../../../ic-agent/declarations/main";
  import { decodeImageToPixels } from "../../../../utils/PixelUtil";
  import PixelArtCanvas from "../../../common/PixelArtCanvas.svelte";

  export let race: Race;

  $: layers = [decodeImageToPixels(race.image, 32, 32)];
</script>

<div>
  <div>Race</div>
  <EntityView entity={race} />
  <PixelArtCanvas {layers} pixelSize={2} />
  <ActionsView actionIds={race.startingSkillActionIds} />
  <ItemsView itemIds={race.startingItemIds} />
  <UnlockRequirementView value={race.unlockRequirement} />
</div>
