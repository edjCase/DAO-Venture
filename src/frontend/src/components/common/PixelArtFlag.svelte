<script lang="ts">
    import { PixelGrid } from "../../models/PixelArt";
    import PixelArtSvg from "../common/PixelArtSvg.svelte";

    export let pixels: PixelGrid;
    export let size: "xxs" | "xs" | "sm" | "md" | "lg" | undefined;

    let imageWidth: number;
    let imageHeight: number;
    $: {
        let imageSize: number;
        switch (size) {
            case "xxs":
                imageSize = 35;
                break;
            case "xs":
                imageSize = 60;
                break;
            case "sm":
                imageSize = 75;
                break;
            case "md":
                imageSize = 100;
                break;
            case "lg":
                imageSize = 150;
                break;
            default:
                imageSize = 50;
        }
        imageWidth = imageSize;
        imageHeight = imageSize;
    }
    let pixelSize = 1;
</script>

<PixelArtSvg {pixelSize} {pixels} {imageHeight} {imageWidth} />
