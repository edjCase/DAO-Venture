<script lang="ts">
  import { decodeImageToPixels } from "../../../../utils/PixelUtil";
  import PixelArtCanvas from "../../../common/PixelArtCanvas.svelte";
  import EntityView from "./EntityView.svelte";
  import TagsView from "./TagsView.svelte";
  import UnlockRequirementView from "./UnlockRequirementView.svelte";

  export let item;
</script>

<div>
  <div class="text-xl text-primary-500 font-bold">Item</div>
  <EntityView entity={item} />
  <div class="text-primary-500">Image</div>
  <div>
    <PixelArtCanvas
      layers={[decodeImageToPixels(item.image, 32, 32)]}
      pixelSize={1}
    />
  </div>
  <div class="text-primary-500">Tags</div>
  <TagsView tags={item.tags} />
  <div class="text-primary-500">Unlock Requirement</div>
  <UnlockRequirementView value={item.unlockRequirement} />
</div>
