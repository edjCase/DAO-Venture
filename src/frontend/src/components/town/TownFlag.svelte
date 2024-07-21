<script lang="ts">
  import { Town } from "../../ic-agent/declarations/main";
  import PixelArtFlag from "../common/PixelArtFlag.svelte";

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
    <PixelArtFlag pixels={town.flagImage.pixels} {size} />
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
