<script lang="ts">
  import { scenarioMetaDataStore } from "../../stores/ScenarioMetaDataStore";
  import { decodeImageToPixels } from "../../utils/PixelUtil";
  import PixelArtCanvas from "../common/PixelArtCanvas.svelte";

  export let metaDataId: string;

  $: metaDataList = $scenarioMetaDataStore;

  $: metaData = metaDataList?.find((m) => m.id === metaDataId);
</script>

{#if metaData}
  <PixelArtCanvas
    layers={[decodeImageToPixels(metaData.image, 64, 64)]}
    pixelSize={0.5}
  />
{/if}
