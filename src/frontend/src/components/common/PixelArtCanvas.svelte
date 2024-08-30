<script lang="ts">
  import { onMount } from "svelte";
  import { PixelGrid } from "../../utils/PixelUtil";

  export let pixels: PixelGrid;
  export let pixelSize: number = 2;
  export let border: boolean = false;
  let canvas: HTMLCanvasElement;
  let width = pixels[0].length;
  let height = pixels.length;

  onMount(() => {
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    pixels.forEach((row, y) => {
      row.forEach((color, x) => {
        let rectX = x * pixelSize;
        let rectY = y * pixelSize;
        let rectWidth = pixelSize;
        let rectHeight = pixelSize;
        if (color === undefined) {
          ctx.clearRect(rectX, rectY, rectWidth, rectHeight);
        } else {
          ctx.fillStyle = `rgb(${color[0]}, ${color[1]}, ${color[2]})`;
          ctx.fillRect(rectX, rectY, rectWidth, rectHeight);
        }
      });
    });
  });
</script>

<canvas
  bind:this={canvas}
  width={width * pixelSize}
  height={height * pixelSize}
  style="image-rendering: crisp-edges;"
  class={border ? "border border-gray-300 shadow-md" : ""}
/>
