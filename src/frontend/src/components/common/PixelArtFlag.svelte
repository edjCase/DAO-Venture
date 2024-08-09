<script lang="ts">
    import { PixelGrid } from "../../models/PixelArt";
    import PixelArtCanvas from "./PixelArtCanvas.svelte";
    import PixelArtSvg from "./PixelArtSvg.svelte";

    export let pixels: PixelGrid;
    export let size: "xxs" | "xs" | "sm" | "md" | "lg" | undefined;
    export let border: boolean = false;
    export let type: "canvas" | "svg" = "canvas";

    let pixelSize: number;
    $: {
        switch (size) {
            case "xxs":
                pixelSize = 1;
                break;
            case "xs":
                pixelSize = 2;
                break;
            case "sm":
                pixelSize = 3;
                break;
            case "md":
                pixelSize = 4;
                break;
            case "lg":
                pixelSize = 5;
                break;
            default:
                pixelSize = 6;
        }
    }
</script>

<!-- TODO need svg? -->
{#if type === "svg"}
    <PixelArtSvg {pixelSize} {pixels} {border} />
{:else}
    <PixelArtCanvas {pixelSize} {pixels} {border} />
{/if}
