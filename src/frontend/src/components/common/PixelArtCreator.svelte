<script lang="ts">
    import { PixelGrid, Rgb } from "../../models/PixelArt";
    import RgbColor from "./RgbColor.svelte";

    export let pixelSize = 40;
    export let pixels: PixelGrid;

    let height = pixels.length;
    let width = pixels[0].length;

    let selectedColor: Rgb = { red: 0, green: 0, blue: 0 };

    function updatePixel(x: number, y: number): void {
        pixels![y][x] = { ...selectedColor };
    }
</script>

<div class="flex flex-col items-center space-y-4">
    <div class="flex space-x-4 items-center">
        <RgbColor bind:value={selectedColor} />
    </div>

    <div
        class="grid bg-gray-200 rounded-lg"
        style:grid-template-columns="repeat({width}, {pixelSize}px)"
    >
        {#each pixels as row, y}
            {#each row as pixel, x}
                <div
                    on:click={() => updatePixel(x, y)}
                    on:keydown={(event) => {
                        if (event.key === "Enter") {
                            updatePixel(x, y);
                        }
                    }}
                    role="button"
                    tabindex={x + y * height}
                    class="cursor-pointer hover:opacity-75 transition-opacity"
                    style:width="{pixelSize}px"
                    style:height="{pixelSize}px"
                    style:background-color="rgb({pixel.red}, {pixel.green}, {pixel.blue})"
                />
            {/each}
        {/each}
    </div>
</div>
