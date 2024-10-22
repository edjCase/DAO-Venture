<script lang="ts">
  import { zoneStore } from "../../stores/ZoneStore";

  export let zoneId: string;

  $: zones = $zoneStore;

  $: zone = zones?.find((z) => z.id === zoneId);
</script>

{#if zone}
  -
  <!--
    TODO 
    <PixelArtCanvas
    layers={[decodeImageToPixels(zone.image, 64, 64)]}
    pixelSize={0.5}
  /> -->
{/if}
