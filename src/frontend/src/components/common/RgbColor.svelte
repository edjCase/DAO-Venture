<script lang="ts">
  import { Input } from "flowbite-svelte";
  import { Rgb } from "../../utils/PixelUtil";
  import { PenSolid } from "flowbite-svelte-icons";

  export let value: Rgb = [0, 0, 0];
  export let disabled: boolean = false;
  let stringRgb: string = `#${value[0].toString(16).padStart(2, "0")}${value[1].toString(16).padStart(2, "0")}${value[2].toString(16).padStart(2, "0")}`;

  $: {
    let red = parseInt(stringRgb.slice(1, 3), 16);
    let green = parseInt(stringRgb.slice(3, 5), 16);
    let blue = parseInt(stringRgb.slice(5, 7), 16);
    value = [red, green, blue];
  }
</script>

<div class="flex items-center">
  <PenSolid />
  <Input
    {disabled}
    type="color"
    bind:value={stringRgb}
    defaultClass="h-16 w-16"
  />
</div>
