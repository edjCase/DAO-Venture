<script lang="ts">
  import { Popover } from "flowbite-svelte";

  export let team: { logoUrl: string; name: string } | undefined;
  export let size: "sm" | "md" | "lg" | undefined;
  export let borderColor: string | undefined;
  export let popoverText: string | undefined;

  $: logoUrl = team?.logoUrl || "/images/team-logos/unknown.png";
  $: alt = team?.name || "Undetermined";
</script>

<div>
  <div id="teamLogo">
    <img
      class="logo {size ? `size-${size}` : ''}"
      src={logoUrl}
      {alt}
      style={borderColor ? "border: 1px solid " + borderColor : ""}
    />
  </div>
  {#if popoverText}
    <Popover
      class="w-64 text-sm font-light "
      title={team?.name || "Undertermined"}
      triggeredBy="#teamLogo"
    >
      {popoverText}
    </Popover>
  {/if}
</div>

<style>
  .logo {
    background-color: rgba(120, 120, 120, 0.5);
    border-radius: 25%;
    padding: 5px;
  }

  .size-sm {
    width: 50px;
    height: 50px;
  }
  .size-md {
    width: 100px;
    height: 100px;
  }
  .size-lg {
    width: 150px;
    height: 150px;
  }
</style>
