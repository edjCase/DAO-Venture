<script lang="ts">
  import { onMount } from "svelte";
  import { PixelGrid } from "../../utils/PixelUtil";

  export let layers: PixelGrid[];
  export let pixelSize: number = 1;
  export let border: boolean = false;

  let canvas: HTMLCanvasElement;
  $: width = layers[0][0].length;
  $: height = layers[0].length;

  onMount(() => {
    redraw();
  });

  $: layers && width && height && redraw();

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

  function redraw() {
    if (!canvas) return;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    layers.forEach((pixelLayer) => drawLayer(ctx, pixelLayer));
  }
</script>

<canvas
  bind:this={canvas}
  width={width * pixelSize}
  height={height * pixelSize}
  style="image-rendering: crisp-edges;"
  class={"inline-block" + (border ? "border border-gray-300 shadow-md" : "")}
/>
