<script lang="ts">
  import { TeamId, TeamIdOrTie } from "../../ic-agent/declarations/main";
  import { TeamOrUndetermined } from "../../models/Team";
  import TeamLogo from "../team/TeamLogo.svelte";

  export let team1: TeamOrUndetermined;
  export let team1Score: bigint | undefined;
  export let team2: TeamOrUndetermined;
  export let team2Score: bigint | undefined;
  export let winner: TeamIdOrTie | undefined;
  export let prediction: TeamId | undefined;

  let getTeamEmojis = (
    winner: TeamIdOrTie | undefined,
    teamId: "team1" | "team2",
  ) => {
    let emojis = [];
    if (winner) {
      if (teamId in winner) {
        emojis.push("👑");
      } else if ("tie" in winner) {
        emojis.push("😑");
      }
    }
    if (prediction && teamId in prediction) {
      emojis.push("🔮");
    }
    return emojis.join(" ");
  };

  $: team1Emoji = getTeamEmojis(winner, "team1");
  $: team2Emoji = getTeamEmojis(winner, "team2");
</script>

<div class="flex justify-between">
  <div class="flex flex-row items-center">
    <TeamLogo team={team1} size="xs" />
    <div class="text-4xl font-bold mx-4 flex items-center">
      {team1Score || "-"}
      <span class="text-base">{team1Emoji}</span>
    </div>
  </div>
  <div class="flex flex-col items-center justify-around">
    <slot />
  </div>
  <div class="flex flex-row items-center justify-end">
    <div class="text-4xl font-bold mx-4 flex items-center">
      <span class="text-base">{team2Emoji}</span>
      {team2Score || "-"}
    </div>
    <TeamLogo team={team2} size="xs" />
  </div>
</div>
