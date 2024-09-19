<script lang="ts">
  import { PixelColor, PixelGrid, Rgb } from "../../utils/PixelUtil";
  import PixelArtEditor from "./PixelArtEditor.svelte";

  export let width: number;
  export let height: number;
  export let pixelSize: number = 16;
  export let previewPixelSize: number | undefined;

  let pixels: PixelGrid | undefined;

  let palette: Rgb[] = [
    [23, 32, 56], // 172038
    [37, 58, 94], // 253a5e
    [60, 94, 139], // 3c5e8b
    [79, 143, 186], // 4f8fba
    [115, 190, 211], // 73bed3
    [164, 221, 219], // a4dddb
    [25, 51, 45], // 19332d
    [37, 86, 46], // 25562e
    [70, 130, 50], // 468232
    [117, 167, 67], // 75a743
    [168, 202, 88], // a8ca58
    [208, 218, 145], // d0da91
    [77, 43, 50], // 4d2b32
    [122, 72, 65], // 7a4841
    [173, 119, 87], // ad7757
    [192, 148, 115], // c09473
    [215, 181, 148], // d7b594
    [231, 213, 179], // e7d5b3
    [52, 28, 39], // 341c27
    [96, 44, 44], // 602c2c
    [136, 75, 43], // 884b2b
    [190, 119, 43], // be772b
    [222, 158, 65], // de9e41
    [232, 193, 112], // e8c170
    [36, 21, 39], // 241527
    [65, 29, 49], // 411d31
    [117, 36, 56], // 752438
    [165, 48, 48], // a53030
    [207, 87, 60], // cf573c
    [218, 134, 62], // da863e
    [30, 29, 57], // 1e1d39
    [64, 39, 81], // 402751
    [122, 54, 123], // 7a367b
    [162, 62, 140], // a23e8c
    [198, 81, 151], // c65197
    [223, 132, 165], // df84a5
    [9, 10, 20], // 090a14
    [16, 20, 31], // 10141f
    [21, 29, 40], // 151d28
    [32, 46, 55], // 202e37
    [57, 74, 80], // 394a50
    [87, 114, 119], // 577277
    [129, 151, 150], // 819796
    [168, 181, 178], // a8b5b2
    [199, 207, 204], // c7cfcc
    [235, 237, 233], // ebede9
  ];

  let pixelate = (sourceImage: HTMLImageElement, canvas: HTMLCanvasElement) => {
    // Derived from https://github.com/giventofly/pixelit/blob/master/src/pixelit.js
    let ctx = canvas.getContext("2d")!;
    canvas.width = width * pixelSize;
    canvas.height = height * pixelSize;
    let scaledW = width;
    let scaledH = height;

    //make temporary canvas to make new scaled copy
    // const tempCanvas = document.createElement("canvas");

    // Set temp canvas width/height & hide (fixes higher scaled cutting off image bottom)
    canvas.width = canvas.width;
    canvas.height = canvas.height;
    // canvas.style.visibility = "hidden";
    canvas.style.position = "fixed";
    canvas.style.top = "0";
    canvas.style.left = "0";

    // get the context
    // const tempContext = tempCanvas.getContext("2d")!;
    // draw the image into the canvas
    ctx.drawImage(sourceImage, 0, 0, scaledW, scaledH);
    // document.body.appendChild(tempCanvas);
    // //configs to pixelate
    // ctx.imageSmoothingEnabled = false;

    // //draw to final canvas
    // ctx.drawImage(
    //   tempCanvas,
    //   0,
    //   0,
    //   scaledW,
    //   scaledH,
    //   0,
    //   0,
    //   width * pixelSize,
    //   height * pixelSize
    // );
    // //remove temp element
    // tempCanvas.remove();
    convertPalette(canvas, palette);
    pixels = getPixelGrid();
  };

  let colorSim = (rgbColor: Rgb, compareColor: Rgb) => {
    let i;
    let max;
    let d = 0;
    for (i = 0, max = rgbColor.length; i < max; i++) {
      d += (rgbColor[i] - compareColor[i]) * (rgbColor[i] - compareColor[i]);
    }
    return Math.sqrt(d);
  };

  let similarColor = (actualColor: Rgb, palette: Rgb[]) => {
    let currentSim = colorSim(actualColor, palette[0]);
    let selectedColor = palette[0];
    let nextColor;
    palette.forEach((color) => {
      nextColor = colorSim(actualColor, color);
      if (nextColor <= currentSim) {
        selectedColor = color;
        currentSim = nextColor;
      }
    });
    return selectedColor;
  };
  let convertPalette = (canvas: HTMLCanvasElement, palette: Rgb[]) => {
    const w = canvas.width;
    const h = canvas.height;
    let ctx = canvas.getContext("2d")!;
    var imgPixels = ctx.getImageData(0, 0, w, h);
    for (var y = 0; y < imgPixels.height; y++) {
      for (var x = 0; x < imgPixels.width; x++) {
        var i = y * 4 * imgPixels.width + x * 4;
        //var avg = (imgPixels.data[i] + imgPixels.data[i + 1] + imgPixels.data[i + 2]) / 3;
        const finalcolor = similarColor(
          [imgPixels.data[i], imgPixels.data[i + 1], imgPixels.data[i + 2]],
          palette
        );
        imgPixels.data[i] = finalcolor[0];
        imgPixels.data[i + 1] = finalcolor[1];
        imgPixels.data[i + 2] = finalcolor[2];
      }
    }
    ctx.putImageData(imgPixels, 0, 0, 0, 0, imgPixels.width, imgPixels.height);
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

  let getPixelGrid = (): PixelGrid => {
    const ctx = pixelCanvas.getContext("2d");
    if (!ctx) throw new Error("Could not get canvas context");

    const imageData = ctx.getImageData(0, 0, width, height);
    const data = imageData.data;

    const pixelGrid: PixelGrid = [];
    for (let y = 0; y < height; y++) {
      const row: PixelColor[] = [];
      for (let x = 0; x < width; x++) {
        const i = (y * width + x) * 4;
        const r = data[i];
        const g = data[i + 1];
        const b = data[i + 2];
        const a = data[i + 3];

        // If fully transparent, set as undefined
        row.push(a === 0 ? undefined : [r, g, b]);
      }
      pixelGrid.push(row);
    }
    return pixelGrid;
  };
</script>

<input
  type="file"
  accept="image/*"
  bind:this={fileInput}
  on:change={handleFileSelect}
/>
<img bind:this={sourceImage} style="display: none;" alt="source" />
<canvas bind:this={pixelCanvas} style="display: none;" />
{#if pixels}
  <PixelArtEditor {pixels} {pixelSize} {previewPixelSize} />
{/if}
