<script lang="ts">
  import { onMount, tick } from "svelte";
  import { PixelGrid } from "../../utils/PixelUtil";

  export let layers: PixelGrid[];
  export let pixelSize: number = 1;
  export let border: boolean = false;

  let canvas: HTMLCanvasElement;
  $: width = layers[0][0].length;
  $: height = layers[0].length;

  $: canvasWidth = width * pixelSize;
  $: canvasHeight = height * pixelSize;

  onMount(() => {
    redraw();
  });

  $: pixelSize && layers && redrawWithDelay(); // Delay to allow resize to take effect

  let drawLayer = (ctx: CanvasRenderingContext2D, layerPixels: PixelGrid) => {
    layerPixels.forEach((row, y) => {
      row.forEach((color, x) => {
        let rectX = x * pixelSize;
        let rectY = y * pixelSize;
        let rectWidth = pixelSize;
        let rectHeight = pixelSize;
        if (color === undefined) {
          // ctx.clearRect(rectX, rectY, rectWidth, rectHeight);
        } else {
          ctx.fillStyle = `rgb(${color[0]}, ${color[1]}, ${color[2]})`;
          ctx.fillRect(rectX, rectY, rectWidth, rectHeight);
        }
      });
    });
  };

  async function redrawWithDelay() {
    await tick();
    redraw();
  }

  function redraw() {
    console.log("redraw");
    if (!canvas) {
      console.log("no canvas");
      return;
    }
    const ctx = canvas.getContext("2d");
    if (!ctx) {
      console.log("no ctx");
      return;
    }

    ctx.clearRect(0, 0, canvas.width, canvas.height);

    layers.forEach((pixelLayer) => drawLayer(ctx, pixelLayer));
  }
</script>

<canvas
  bind:this={canvas}
  width={canvasWidth}
  height={canvasHeight}
  style="image-rendering: pixelated;"
  class={"inline-block" + (border ? " border border-gray-300 shadow-md" : "")}
/>
