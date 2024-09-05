<script lang="ts">
  import { decodeImageToPixels } from "../../../../utils/PixelUtil";
  import PixelArtCanvas from "../../../common/PixelArtCanvas.svelte";
  import EntityView from "./EntityView.svelte";
  import UnlockRequirementView from "./UnlockRequirementView.svelte";

  export let item;
</script>

<div>
  <div>Item</div>
  <EntityView entity={item} />
  <div>
    <PixelArtCanvas pixels={decodeImageToPixels(item.image, 16, 16)} />
  </div>
  <UnlockRequirementView value={item.unlockRequirement} />
</div>
