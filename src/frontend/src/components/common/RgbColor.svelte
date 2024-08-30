<script lang="ts">
  import { Input } from "flowbite-svelte";
  import { Rgb } from "../../utils/PixelUtil";

  export let value: Rgb = [0, 0, 0];
  export let disabled: boolean = false;
  export let type: "horizontal" | "vertical" = "horizontal";
  let stringRgb: string = `#${value[0].toString(16).padStart(2, "0")}${value[1].toString(16).padStart(2, "0")}${value[2].toString(16).padStart(2, "0")}`;

  $: {
    let red = parseInt(stringRgb.slice(1, 3), 16);
    let green = parseInt(stringRgb.slice(3, 5), 16);
    let blue = parseInt(stringRgb.slice(5, 7), 16);
    value = [red, green, blue];
  }

  let typeClasses: string = "";
  $: {
    switch (type) {
      case "horizontal":
        typeClasses = `items-center`;
        break;
      case "vertical":
        typeClasses = `flex-col items-center`;
        break;
    }
  }
</script>

<div class="flex {typeClasses} gap-4">
  <Input
    {disabled}
    type="color"
    bind:value={stringRgb}
    defaultClass="h-16 w-16"
  />
</div>
