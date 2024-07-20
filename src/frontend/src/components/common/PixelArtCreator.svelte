<script lang="ts">
    import { writable, type Writable } from "svelte/store";

    export let gridSize = 16;
    export let pixelSize = 20;

    type RGB = { red: number; green: number; blue: number };
    type PixelGrid = RGB[][];

    let selectedColor: RGB = { red: 0, green: 0, blue: 0 };
    let pixelData: Writable<PixelGrid> = writable(
        Array(gridSize)
            .fill(null)
            .map(() =>
                Array(gridSize).fill({ red: 255, green: 255, blue: 255 }),
            ),
    );

    function updatePixel(x: number, y: number): void {
        pixelData.update((data) => {
            data[y][x] = { ...selectedColor };
            return data;
        });
    }

    function handleColorChange(event: Event): void {
        const hex = (event.target as HTMLInputElement).value;
        selectedColor = {
            red: parseInt(hex.slice(1, 3), 16),
            green: parseInt(hex.slice(3, 5), 16),
            blue: parseInt(hex.slice(5, 7), 16),
        };
    }
</script>

<div class="flex flex-col items-center space-y-4">
    <div class="flex space-x-4 items-center">
        <input
            type="color"
            on:input={handleColorChange}
            class="w-12 h-12 cursor-pointer"
        />
    </div>

    <div
        class="grid bg-gray-200 rounded-lg"
        style:grid-template-columns="repeat({gridSize}, {pixelSize}px)"
    >
        {#each $pixelData as row, y}
            {#each row as pixel, x}
                <div
                    on:click={() => updatePixel(x, y)}
                    on:keydown={(event) => {
                        if (event.key === "Enter") {
                            updatePixel(x, y);
                        }
                    }}
                    role="button"
                    tabindex={x + y * gridSize}
                    class="cursor-pointer hover:opacity-75 transition-opacity"
                    style:width="{pixelSize}px"
                    style:height="{pixelSize}px"
                    style:background-color="rgb({pixel.red}, {pixel.green}, {pixel.blue})"
                />
            {/each}
        {/each}
    </div>
</div>
