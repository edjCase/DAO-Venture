<script lang="ts">
  import { onMount } from "svelte";

  type RGBColor = [number, number, number];

  export let pixels: RGBColor[][];
  export let pixelSize: number = 20;
  export let border: boolean = false;
  let canvas: HTMLCanvasElement;
  let width = pixels[0]?.length || 0;
  let height = pixels.length;

  onMount(() => {
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    pixels.forEach((row, y) => {
      row.forEach((color, x) => {
        ctx.fillStyle = `rgb(${color[0]}, ${color[1]}, ${color[2]})`;
        ctx.fillRect(x * pixelSize, y * pixelSize, pixelSize, pixelSize);
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
