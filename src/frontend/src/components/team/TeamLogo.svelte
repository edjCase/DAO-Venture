<script lang="ts">
  import { toRgbString } from "../../utils/StringUtil";

  export let team:
    | {
        logoUrl: string;
        name: string;
        id: bigint;
        color: [number, number, number];
      }
    | { winnerOfMatch: number }
    | { seasonStandingIndex: number };
  export let size: "xxs" | "xs" | "sm" | "md" | "lg" | undefined;
  export let border: boolean = true;
  export let padding: boolean = true;
  export let name: "left" | "right" | undefined = undefined;

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

  let teamColor = "color" in team ? toRgbString(team.color) : "grey";
</script>

<div id={triggerId} class="flex justify-center items-center space-x-1">
  {#if name == "left"}
    <div class="text-center">{title}</div>
  {/if}
  <img
    class="logo {padding ? `p-1` : ''} {size ? `size-${size}` : ''}"
    src={logoUrl}
    alt={title}
    {title}
    style={border ? "border: 5px solid " + teamColor : ""}
  />
  {#if name == "right"}
    <div class="text-center">{title}</div>
  {/if}
</div>

<style>
  .logo {
    background-color: rgba(120, 120, 120, 0.5);
    border-radius: 25%;
  }

  .size-xxs {
    width: 25px;
    height: 25px;
  }
  .size-xs {
    width: 50px;
    height: 50px;
  }
  .size-sm {
    width: 75px;
    height: 75px;
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
