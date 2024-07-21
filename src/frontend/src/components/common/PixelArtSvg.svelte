<script lang="ts">
    import { PixelGrid } from "../../models/PixelArt";

    export let pixels: PixelGrid;
    export let pixelSize: number;
    export let imageWidth: number;
    export let imageHeight: number;
</script>

<svg
    width={imageWidth}
    height={imageHeight}
    viewBox="0 0 {imageWidth} {imageHeight}"
    xmlns="http://www.w3.org/2000/svg"
>
    {#each pixels as row, y}
        {#each row as pixel, x}
            <rect
                x={x * pixelSize}
                y={y * pixelSize}
                width={pixelSize}
                height={pixelSize}
                fill="rgb({pixel.red},{pixel.green},{pixel.blue})"
            />
        {/each}
    {/each}
</svg>
