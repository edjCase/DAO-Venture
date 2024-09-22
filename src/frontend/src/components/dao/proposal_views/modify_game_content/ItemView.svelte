<script lang="ts">
  import { decodeImageToPixels } from "../../../../utils/PixelUtil";
  import PixelArtCanvas from "../../../common/PixelArtCanvas.svelte";
  import EntityView from "./EntityView.svelte";
  import TagsView from "./TagsView.svelte";
  import UnlockRequirementView from "./UnlockRequirementView.svelte";

  export let item;
</script>

<div>
  <div>Item</div>
  <EntityView entity={item} />
  <div>
    <PixelArtCanvas
      layers={[decodeImageToPixels(item.image, 32, 32)]}
      pixelSize={1}
    />
  </div>
  <TagsView tags={item.tags} />
  <UnlockRequirementView value={item.unlockRequirement} />
</div>
