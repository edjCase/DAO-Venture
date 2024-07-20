<script lang="ts">
  import { TownOrUndetermined } from "../../models/Town";
  import { toRgbString } from "../../utils/StringUtil";

  export let town: TownOrUndetermined;
  export let size: "xxs" | "xs" | "sm" | "md" | "lg" | undefined;
  export let border: boolean = true;
  export let padding: boolean = true;
  export let stats: boolean = false;
  export let name: "left" | "right" | undefined = undefined;

  $: title =
    "name" in town
      ? town.name
      : "winnerOfMatch" in town
        ? "Winner of previous match group"
        : "Town with rank of: " + (town.seasonStandingIndex + 1);
  $: triggerId =
    "townFlag_" +
    ("id" in town
      ? town.id.toString()
      : "winnerOfMatch" in town
        ? "W" + town.winnerOfMatch
        : "S" + town.seasonStandingIndex);

  $: townColor = "color" in town ? toRgbString(town.color) : "grey";
  let borderSize: number;
  let imageWidth: number;
  let imageHeight: number;
  $: {
    let imageSize: number;
    switch (size) {
      case "xxs":
        imageSize = 35;
        borderSize = 2;
        break;
      case "xs":
        imageSize = 60;
        borderSize = 5;
        break;
      case "sm":
        imageSize = 75;
        borderSize = 5;
        break;
      case "md":
        imageSize = 100;
        borderSize = 5;
        break;
      case "lg":
        imageSize = 150;
        borderSize = 5;
        break;
      default:
        imageSize = 50;
        borderSize = 5;
    }
    imageWidth = imageSize;
    imageHeight = imageSize;
  }
  let pixelSize = 1;
</script>

<div id={triggerId} class="flex flex-col justify-center items-center space-x-1">
  {#if name == "left"}
    <div class="text-center">{title}</div>
  {/if}

  <div class="flex flex-col items-center justify-center">
    <svg
      class="bg-gray-400 rounded-lg {padding ? 'p-1' : ''}"
      width={imageWidth}
      height={imageHeight}
      viewBox="0 0 {imageWidth} {imageHeight}"
      xmlns="http://www.w3.org/2000/svg"
      style:border={border ? `${borderSize}px solid ${townColor}` : "none"}
    >
      {#each pixelData as row, y}
        {#each row as pixel, x}
          <rect
            x={x * pixelSize}
            y={y * pixelSize}
            width={pixelSize}
            height={pixelSize}
            fill="rgb({pixel.red},{pixel.green},{pixel.blue})"
          />
        {/each}
      {/each}
    </svg>
    {#if stats && "currency" in town}
      <div class="flex items-center justify-center font-bold">
        <div class="flex items-center justify-center mx-1">
          <span class="">{town.currency}</span>
          <span class="text-md">💰</span>
        </div>
        <div class="flex items-center justify-center">
          <span class="">{town.entropy}</span>
          <span class="text-md">🔥</span>
        </div>
      </div>
    {/if}
  </div>
  {#if name == "right"}
    <div class="text-center">{title}</div>
  {/if}
</div>
