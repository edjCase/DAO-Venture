<script lang="ts">
  import { Button, Label, Range } from "flowbite-svelte";
  import { convertToDynamicPalette, PixelGrid } from "../../utils/PixelUtil";
  import PixelArtEditor from "./PixelArtEditor.svelte";

  export let width: number;
  export let height: number;
  export let pixelSize: number = 16;
  export let previewPixelSize: number | undefined;

  let pixels: PixelGrid | undefined;
  let maxColors = 50;

  let pixelate = (sourceImage: HTMLImageElement, canvas: HTMLCanvasElement) => {
    // Derived from https://github.com/giventofly/pixelit/blob/master/src/pixelit.js
    let ctx = canvas.getContext("2d");
    if (!ctx) throw new Error("Could not get canvas context");
    canvas.width = width * pixelSize;
    canvas.height = height * pixelSize;
    let scaledW = width;
    let scaledH = height;

    //make temporary canvas to make new scaled copy
    // const tempCanvas = document.createElement("canvas");

    // Set temp canvas width/height & hide (fixes higher scaled cutting off image bottom)
    canvas.width = canvas.width;
    canvas.height = canvas.height;
    canvas.style.position = "fixed";
    canvas.style.top = "0";
    canvas.style.left = "0";

    ctx.drawImage(sourceImage, 0, 0, scaledW, scaledH);

    const imageData = ctx.getImageData(0, 0, width, height);
    pixels = convertToDynamicPalette(imageData, maxColors);
  };

  let pixelCanvas: HTMLCanvasElement;
  let sourceImage: HTMLImageElement;
  let fileInput: HTMLInputElement;

  function handleFileSelect() {
    const file = fileInput.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        sourceImage.src = e.target?.result as string;
        sourceImage.onload = () => pixelate(sourceImage, pixelCanvas);
      };
      reader.readAsDataURL(file);
    }
  }
</script>

<div class="flex justify-around">
  <div class="">
    <Label>Max Color Count: {maxColors}</Label>
    <Range bind:value={maxColors} min={0} max={254} />
  </div>
  <div class="">
    <input type="file" accept="image/*" bind:this={fileInput} />
    <img bind:this={sourceImage} style="display: none;" alt="source" />
  </div>
</div>
<Button on:click={handleFileSelect}>Pixelate Image</Button>
<canvas bind:this={pixelCanvas} style="display: none;" />
{#if pixels}
  <PixelArtEditor {pixels} {pixelSize} {previewPixelSize} />
{/if}
