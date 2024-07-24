<script lang="ts">
  import { Town } from "../../ic-agent/declarations/main";
  import PixelArtFlag from "../common/PixelArtFlag.svelte";
  import ResourceIcon from "../icons/ResourceIcon.svelte";

  export let town: Town;
  export let size: "xxs" | "xs" | "sm" | "md" | "lg" | undefined;
  export let stats: boolean = false;
  export let name: "left" | "right" | undefined = undefined;

  $: title = town.name;
  $: triggerId = "townFlag_" + town.id.toString();
</script>

<div id={triggerId} class="flex flex-col justify-center items-center space-x-1">
  {#if name == "left"}
    <div class="text-center">{title}</div>
  {/if}

  <div class="flex flex-col items-center justify-center">
    {#if stats}
      <div class="flex items-center justify-center font-bold">
        <div class="flex items-center justify-center mx-1">
          <span class="">{town.resources.food}</span>
          <ResourceIcon kind={{ food: null }} />
        </div>
        <div class="flex items-center justify-center">
          <ResourceIcon kind={{ wood: null }} />
          <span class="">{town.resources.wood}</span>
        </div>
      </div>
    {/if}
    <PixelArtFlag pixels={town.flagImage.pixels} {size} />
    {#if stats}
      <div class="flex items-center justify-center font-bold">
        <div class="flex items-center justify-center mx-1">
          <span class="">{town.resources.gold}</span>
          <ResourceIcon kind={{ gold: null }} />
        </div>
        <div class="flex items-center justify-center">
          <ResourceIcon kind={{ stone: null }} />
          <span class="">{town.resources.stone}</span>
        </div>
      </div>
    {/if}
  </div>
  {#if name == "right"}
    <div class="text-center">{title}</div>
  {/if}
</div>
