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
  export let size: "xs" | "sm" | "md" | "lg" | undefined;
  export let border: boolean = true;
  export let padding: boolean = true;

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

<div id={triggerId} class="flex justify-center">
  <img
    class="logo {padding ? `p-1` : ''} {size ? `size-${size}` : ''}"
    src={logoUrl}
    alt={title}
    style={border ? "border: 5px solid " + teamColor : ""}
  />
</div>

<style>
  .logo {
    background-color: rgba(120, 120, 120, 0.5);
    border-radius: 25%;
  }

  .size-xs {
    width: 25px;
    height: 25px;
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
