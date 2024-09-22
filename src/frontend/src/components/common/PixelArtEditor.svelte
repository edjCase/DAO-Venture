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
  let isDrawing = false;

  function updatePixel(x: number, y: number): void {
    pixels[y][x] = selectedColor;
    pixels = pixels; // Trigger reactivity
  }

  function handleMouseDown(x: number, y: number): void {
    isDrawing = true;
    updatePixel(x, y);
  }

  function handleMouseUp(): void {
    isDrawing = false;
  }

  function handleMouseMove(x: number, y: number): void {
    if (isDrawing) {
      updatePixel(x, y);
    }
  }

  let selectTransparent = () => {
    selectedColor = undefined;
  };

  let copyToClipboard = () => {
    navigator.clipboard.writeText(encodePixelsToBase64(pixels));
  };

  $: previewLayers = [pixels];
  $: gridHeight = height * pixelSize;
</script>

<div class="flex space-x-4">
  <div
    class="grid border"
    style:grid-template-columns="repeat({width}, {pixelSize}px)"
    style:grid-template-rows="repeat({height}, {pixelSize}px)"
    style:height="{gridHeight}px"
    style:overflow="hidden"
    on:mouseup={handleMouseUp}
    on:mouseleave={handleMouseUp}
    role="button"
    tabindex={0}
  >
    {#each pixels as row, y}
      {#each row as pixel, x}
        <div
          on:mousedown={() => handleMouseDown(x, y)}
          on:mousemove={() => handleMouseMove(x, y)}
          on:keydown={(event) => {
            if (event.key === "Enter") {
              updatePixel(x, y);
            }
          }}
          role="button"
          tabindex={x + y * pixelSize}
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
  <div class="flex flex-col justify-center items-center">
    <RgbColor bind:value={selectedColor} type="vertical" />
    <Button on:click={selectTransparent}>Transparent Pixel</Button>
    <Button on:click={copyToClipboard}>Copy Base64 to Clipboard</Button>
    {#if previewPixelSize !== undefined}
      <div class="flex flex-col items-center">
        <div>Preview:</div>
        <PixelArtCanvas layers={previewLayers} pixelSize={previewPixelSize} />
      </div>
    {/if}
  </div>
</div>
