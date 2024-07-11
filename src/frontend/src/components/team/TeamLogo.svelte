<script lang="ts">
  import { TeamOrUndetermined } from "../../models/Team";
  import { toRgbString } from "../../utils/StringUtil";

  export let team: TeamOrUndetermined;
  export let size: "xxs" | "xs" | "sm" | "md" | "lg" | undefined;
  export let border: boolean = true;
  export let padding: boolean = true;
  export let stats: boolean = false;
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

  $: teamColor = "color" in team ? toRgbString(team.color) : "grey";
  let imageWidth: number;
  $: {
    switch (size) {
      case "xxs":
        imageWidth = 25;
        break;
      case "xs":
        imageWidth = 60;
        break;
      case "sm":
        imageWidth = 75;
        break;
      case "md":
        imageWidth = 100;
        break;
      case "lg":
        imageWidth = 150;
        break;
      default:
        imageWidth = 50;
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
        (border ? "border: 5px solid " + teamColor : "")}
    />
    {#if stats && "currency" in team}
      <div class="flex items-center justify-center font-bold">
        <div class="flex items-center justify-center mx-1">
          <span class="">{team.currency}</span>
          <span class="text-md">💰</span>
        </div>
        <div class="flex items-center justify-center">
          <span class="">{team.entropy}</span>
          <span class="text-md">🔥</span>
        </div>
      </div>
    {/if}
  </div>
  {#if name == "right"}
    <div class="text-center">{title}</div>
  {/if}
</div>
