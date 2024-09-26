<script lang="ts">
  import { Button, Label, Range } from "flowbite-svelte";
  import { convertToDynamicPalette, PixelGrid } from "../../utils/PixelUtil";
  import PixelArtEditor from "./PixelArtEditor.svelte";

  export let width: number;
  export let height: number;
  export let pixelSize: number = 16;

  let pixels: PixelGrid | undefined;
  let maxColors = 50;
  let pixelating = false;

  let pixelate = (sourceImage: HTMLImageElement, canvas: HTMLCanvasElement) => {
    // Derived from https://github.com/giventofly/pixelit/blob/master/src/pixelit.js
    let ctx = canvas.getContext("2d");
    if (!ctx) throw new Error("Could not get canvas context");
    canvas.width = width * pixelSize;
    canvas.height = height * pixelSize;

    //make temporary canvas to make new scaled copy
    // const tempCanvas = document.createElement("canvas");

    canvas.style.position = "fixed";
    canvas.style.top = "0";
    canvas.style.left = "0";
    // Draw the image onto the canvas
    ctx.drawImage(sourceImage, 0, 0, width, height);

    // Get the lower resolution image data from the canvas
    const imageData = ctx.getImageData(0, 0, width, height);
    pixels = convertToDynamicPalette(imageData, maxColors);
  };

  let pixelCanvas: HTMLCanvasElement;
  let sourceImage: HTMLImageElement;
  let fileInput: HTMLInputElement;

  function handleFileSelect() {
    const file = fileInput.files?.[0];
    if (file) {
      pixelating = true;
      const reader = new FileReader();
      reader.onload = (e) => {
        sourceImage.src = e.target?.result as string;
        sourceImage.onload = () => {
          try {
            pixelate(sourceImage, pixelCanvas);
          } catch (e) {
            console.error("Error pixelating image", e);
          }
          pixelating = false;
        };
      };
      reader.readAsDataURL(file);
    }
  }
</script>

<div class="flex flex-col justify-around" hidden={pixelating}>
  <div class="">
    <Label>Max Color Count: {maxColors}</Label>
    <Range bind:value={maxColors} min={0} max={254} />
  </div>
  <div class="">
    <input type="file" accept="image/*" bind:this={fileInput} />
    <img bind:this={sourceImage} style="display: none;" alt="source" />
  </div>
</div>
<Button on:click={handleFileSelect}>
  {pixelating ? "Pixelating..." : "Pixelate Image"}
</Button>
<canvas bind:this={pixelCanvas} style="display: none;" />
{#if pixels}
  <PixelArtEditor {pixels} {pixelSize} />
{/if}
