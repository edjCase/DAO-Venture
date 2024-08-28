<script lang="ts">
  import { Input } from "flowbite-svelte";
  type Rgb = { red: number; green: number; blue: number };

  export let value: Rgb = { red: 0, green: 0, blue: 0 };
  export let disabled: boolean = false;
  export let type: "horizontal" | "vertical" = "horizontal";
  let stringRgb: string = `#${value.red.toString(16).padStart(2, "0")}${value.blue.toString(16).padStart(2, "0")}${value.green.toString(16).padStart(2, "0")}`;

  $: {
    let red = parseInt(stringRgb.slice(1, 3), 16);
    let green = parseInt(stringRgb.slice(3, 5), 16);
    let blue = parseInt(stringRgb.slice(5, 7), 16);
    value = { red, green, blue };
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
