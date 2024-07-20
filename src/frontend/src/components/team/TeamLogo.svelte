<script lang="ts">
  import { TownOrUndetermined } from "../../models/Town";
  import { toRgbString } from "../../utils/StringUtil";

  export let town: TownOrUndetermined;
  export let size: "xxs" | "xs" | "sm" | "md" | "lg" | undefined;
  export let border: boolean = true;
  export let padding: boolean = true;
  export let stats: boolean = false;
  export let name: "left" | "right" | undefined = undefined;

  $: logoUrl =
    "logoUrl" in town ? town.logoUrl : "/images/town-logos/unknown.png";
  $: title =
    "name" in town
      ? town.name
      : "winnerOfMatch" in town
        ? "Winner of previous match group"
        : "Town with rank of: " + (town.seasonStandingIndex + 1);
  $: triggerId =
    "townLogo_" +
    ("id" in town
      ? town.id.toString()
      : "winnerOfMatch" in town
        ? "W" + town.winnerOfMatch
        : "S" + town.seasonStandingIndex);

  $: townColor = "color" in town ? toRgbString(town.color) : "grey";
  let imageWidth: number;
  let borderSize: number;
  $: {
    switch (size) {
      case "xxs":
        imageWidth = 35;
        borderSize = 2;
        break;
      case "xs":
        imageWidth = 60;
        borderSize = 5;
        break;
      case "sm":
        imageWidth = 75;
        borderSize = 5;
        break;
      case "md":
        imageWidth = 100;
        borderSize = 5;
        break;
      case "lg":
        imageWidth = 150;
        borderSize = 5;
        break;
      default:
        imageWidth = 50;
        borderSize = 5;
    }
  }
</script>

<div id={triggerId} class="flex flex-col justify-center items-center space-x-1">
  {#if name == "left"}
    <div class="text-center">{title}</div>
  {/if}

  <div class="flex flex-col items-center justify-center">
    <img
      class="bg-gray-400 rounded-lg {padding ? `p-1` : ''}"
      src={logoUrl}
      alt={title}
      {title}
      style={`width: ${imageWidth}px; height: ${imageWidth}px; ` +
        (border ? `border: ${borderSize}px solid ` + townColor : "")}
    />
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
