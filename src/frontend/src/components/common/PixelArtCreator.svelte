<script lang="ts">
  import { Button } from "flowbite-svelte";
  import RgbColor from "./RgbColor.svelte";
  type RGBColor = [number, number, number];

  export let pixelSize = 20;
  export let pixels: RGBColor[][];

  let height = pixels.length;
  let width = pixels[0]?.length || 0;

  let selectedColor: RGBColor = [0, 0, 0];

  function updatePixel(x: number, y: number): void {
    pixels![y][x] = { ...selectedColor };
  }

  let fillWithColor = () => {
    pixels = pixels.map((row) => row.map(() => ({ ...selectedColor })));
  };
</script>

<div class="flex space-x-4">
  <div
    class="grid rounded-lg"
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
          style:background-color="rgb({pixel[0]}, {pixel[1]}, {pixel[2]})"
        />
      {/each}
    {/each}
  </div>
  <div class="flex flex-col justify-center">
    <RgbColor bind:value={selectedColor} type="vertical" />
    <Button on:click={fillWithColor}>Fill w/color</Button>
  </div>
</div>
