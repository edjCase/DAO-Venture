<script lang="ts">
    import { PixelGrid } from "../../models/PixelArt";
    import PixelArtSvg from "../common/PixelArtSvg.svelte";

    export let pixels: PixelGrid;
    export let size: "xxs" | "xs" | "sm" | "md" | "lg" | undefined;

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

<PixelArtSvg {pixelSize} {pixels} />
