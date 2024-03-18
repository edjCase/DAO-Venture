<script lang="ts">
  import { Popover } from "flowbite-svelte";

  export let team:
    | { logoUrl: string; name: string; id: bigint }
    | { winnerOfMatch: number }
    | { seasonStandingIndex: number };
  export let size: "sm" | "md" | "lg" | undefined;
  export let borderColor: string | undefined;
  export let popover: boolean = true;

  $: logoUrl =
    "logoUrl" in team ? team.logoUrl : "/images/team-logos/unknown.png";
  $: title =
    "name" in team
      ? team.name
      : "winnerOfMatch" in team
        ? "Winner of previous match group"
        : "Team with rank of: " + (team.seasonStandingIndex + 1);
  $: triggerId =
    "teamLogo_" +
    ("id" in team
      ? team.id.toString()
      : "winnerOfMatch" in team
        ? "W" + team.winnerOfMatch
        : "S" + team.seasonStandingIndex);
</script>

<div>
  <div id={triggerId}>
    <img
      class="logo {size ? `size-${size}` : ''}"
      src={logoUrl}
      alt={title}
      style={borderColor ? "border: 1px solid " + borderColor : ""}
    />
  </div>
  {#if popover}
    <Popover
      class="w-64 text-sm font-light "
      {title}
      triggeredBy={"#" + triggerId}
    ></Popover>
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
