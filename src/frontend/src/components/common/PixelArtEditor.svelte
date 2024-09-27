<script lang="ts">
  import { Button, Toggle, Label, Range, Textarea } from "flowbite-svelte";
  import RgbColor from "./RgbColor.svelte";
  import {
    PixelGrid,
    PixelColor,
    encodePixelsToBase64,
    generatePixelGrid,
    decodeBase64ToPixels,
  } from "../../utils/PixelUtil";
  import PixelArtCanvas from "./PixelArtCanvas.svelte";

  export let pixelSize = 20;
  export let pixels: PixelGrid;
  let previewPixelSize: number = 2;

  let backgroundLayers: PixelGrid[] = [];

  $: height = pixels.length;
  $: width = pixels[0].length;

  let selectedColor: PixelColor = [0, 0, 0];
  let isDrawing = false;
  let isErasing = false;
  let showBackgroundLayers = true;
  let base64Bytes: string | undefined;

  function updatePixel(x: number, y: number): void {
    pixels[y][x] = isErasing ? undefined : selectedColor;
    pixels = [...pixels]; // Trigger reactivity by creating a new array reference
    base64Bytes = undefined;
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

  function toggleEraser(): void {
    isErasing = !isErasing;
  }

  $: previewLayers = showBackgroundLayers
    ? [...backgroundLayers, pixels]
    : [pixels];
  $: gridHeight = height * pixelSize;

  $: getPixelColor = (x: number, y: number) => {
    if (pixels[y][x] !== undefined) {
      return `rgb(${pixels[y][x][0]}, ${pixels[y][x][1]}, ${pixels[y][x][2]})`;
    }
    if (showBackgroundLayers) {
      for (let i = backgroundLayers.length - 1; i >= 0; i--) {
        const bgPixel = backgroundLayers[i][y][x];
        if (bgPixel !== undefined) {
          return `rgb(${bgPixel[0]}, ${bgPixel[1]}, ${bgPixel[2]})`;
        }
      }
    }
    return "transparent";
  };

  function setAsBackgroundLayer(): void {
    backgroundLayers = [...backgroundLayers, pixels];
    pixels = generatePixelGrid(height, width);
  }

  function eraseAll(): void {
    pixels = generatePixelGrid(height, width);
  }

  function generateBase64Bytes(): void {
    base64Bytes = encodePixelsToBase64(pixels);
  }

  function copyToClipboard(): void {
    if (base64Bytes) {
      navigator.clipboard.writeText(base64Bytes);
    }
  }

  async function pasteFromClipboard(): Promise<void> {
    base64Bytes = await navigator.clipboard.readText();
    pixels = decodeBase64ToPixels(base64Bytes, height, width);
  }
</script>

<div class="flex flex-wrap space-x-4 items-center justify-around">
  <div
    class="grid border transparent-bg"
    style:--pixel-size="{pixelSize}px"
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
      {#each row as _, x}
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
          style:background-color={getPixelColor(x, y)}
        />
      {/each}
    {/each}
  </div>
  <div class="flex flex-col justify-center items-center space-y-4 w-full">
    {#if previewPixelSize !== undefined}
      <div class=" w-full">
        <div class="text-center">Preview</div>
        <Range bind:value={previewPixelSize} min={1} max={12} />
        <div class="flex justify-center">
          <PixelArtCanvas layers={previewLayers} pixelSize={previewPixelSize} />
        </div>
      </div>
    {/if}
    <Label>Show Background Layers</Label>
    <Toggle bind:checked={showBackgroundLayers} />
    <div class="flex space-x-2">
      <Button
        color={isErasing ? "light" : "primary"}
        on:click={() => (isErasing = false)}
      >
        🖌 Color
      </Button>
      <Button color={isErasing ? "primary" : "light"} on:click={toggleEraser}>
        ❌ Erase
      </Button>
    </div>
    {#if !isErasing}
      <RgbColor bind:value={selectedColor} />
    {:else}
      <Button on:click={eraseAll}>Erase All</Button>
    {/if}
    <Button on:click={setAsBackgroundLayer}>Set as Background Layer</Button>
    <Label class="text-xl">Encoded Value</Label>
    <Button on:click={generateBase64Bytes}>Generate</Button>
    {#if base64Bytes}
      <Button on:click={copyToClipboard}>Copy Encoded Value</Button>
    {/if}
    <Button on:click={pasteFromClipboard}>Paste Encoded Value</Button>
    <Textarea bind:value={base64Bytes} />
  </div>
</div>

<style>
  .transparent-bg {
    background-image: linear-gradient(45deg, #2a2a2a 25%, transparent 25%),
      linear-gradient(-45deg, #2a2a2a 25%, transparent 25%),
      linear-gradient(45deg, transparent 75%, #2a2a2a 75%),
      linear-gradient(-45deg, transparent 75%, #2a2a2a 75%);
    background-color: #222;
    background-size: calc(var(--pixel-size) * 2) calc(var(--pixel-size) * 2);
    background-position:
      0 0,
      0 var(--pixel-size),
      var(--pixel-size) calc(var(--pixel-size) * -1),
      calc(var(--pixel-size) * -1) 0;
  }
</style>
