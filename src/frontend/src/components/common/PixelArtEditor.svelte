<script lang="ts">
  import { Button } from "flowbite-svelte";
  import RgbColor from "./RgbColor.svelte";
  import {
    PixelGrid,
    PixelColor,
    encodePixelsToBase64,
  } from "../../utils/PixelUtil";
  import PixelArtCanvas from "./PixelArtCanvas.svelte";

  export let pixelSize = 20;
  export let pixels: PixelGrid;
  export let previewPixelSize: number | undefined;

  let height = pixels.length;
  let width = pixels[0].length;

  let selectedColor: PixelColor = [0, 0, 0];

  function updatePixel(x: number, y: number): void {
    pixels[y][x] = selectedColor;
  }

  let selectTransparent = () => {
    selectedColor = undefined;
  };

  let copyToClipboard = () => {
    navigator.clipboard.writeText(encodePixelsToBase64(pixels));
  };
</script>

<div class="flex space-x-4">
  <div
    class="grid border"
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
          style:background-color={pixel === undefined
            ? undefined
            : `rgb(${pixel[0]}, ${pixel[1]}, ${pixel[2]})`}
        />
      {/each}
    {/each}
  </div>
  <div class="flex flex-col justify-center">
    <RgbColor bind:value={selectedColor} type="vertical" />
    <Button on:click={selectTransparent}>Transparent Pixel</Button>
    <Button on:click={copyToClipboard}>Copy Bas64 to Clipboard</Button>
  </div>
</div>
{#if previewPixelSize !== undefined}
  <PixelArtCanvas {pixels} pixelSize={previewPixelSize} />
{/if}
