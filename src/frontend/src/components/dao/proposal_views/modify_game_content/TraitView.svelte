<script lang="ts">
  import { Trait } from "../../../../ic-agent/declarations/main";
  import { decodeImageToPixels } from "../../../../utils/PixelUtil";
  import PixelArtCanvas from "../../../common/PixelArtCanvas.svelte";
  import EntityView from "./EntityView.svelte";
  import UnlockRequirementView from "./UnlockRequirementView.svelte";

  export let trait: Trait;
</script>

<div>
  <div>Trait</div>
  <EntityView entity={trait} />
  <div>
    <PixelArtCanvas pixels={decodeImageToPixels(trait.image, 16, 16)} />
  </div>
  <UnlockRequirementView value={trait.unlockRequirement} />
</div>
