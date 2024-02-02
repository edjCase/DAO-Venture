<script lang="ts">
  import { TeamDetails } from "../../models/Match";
  import { TeamIdOrTie } from "../../models/Team";
  import TeamLogo from "../team/TeamLogo.svelte";
  import { Popover } from "flowbite-svelte";

  export let team1: TeamDetails | undefined;
  export let team2: TeamDetails | undefined;
  export let winner: TeamIdOrTie | undefined;

  let crownEmojiOrEmpty = (teamId: "team1" | "team2") => {
    if (winner === undefined) return "";
    if (teamId in winner) return "👑";
    if ("tie" in winner) return "😑";
    return "";
  };
  let getScoreText = (score: number | undefined) => {
    if (score === undefined || isNaN(score)) return "-";
    return score;
  };
  $: team1Score = getScoreText(team1?.score);
  $: team2Score = getScoreText(team2?.score);
</script>

<div class="header">
  <div class="header-team team1">
    <TeamLogo
      team={team1}
      size="sm"
      borderColor={undefined}
      popoverText={team1?.id.toString()}
    />

    <div class="score">
      {team1Score}
      <span class="emoji">{crownEmojiOrEmpty("team1")}</span>
    </div>
  </div>
  <div class="header-center">
    <slot />
  </div>
  <div class="header-team team2">
    <div class="score">
      {team2Score}
      <span class="emoji">{crownEmojiOrEmpty("team2")}</span>
    </div>
    <TeamLogo
      team={team2}
      size="sm"
      borderColor={undefined}
      popoverText={team1?.id.toString()}
    />
    <Popover
      class="w-64 text-sm font-light "
      title={team2?.name || "Undertermined"}
      triggeredBy="#team2Logo"
    >
      {team1?.id}
    </Popover>
  </div>
</div>

<style>
  .header-team {
    display: flex;
    flex-direction: row;
    align-items: center;
  }
  .name {
    font-size: 2rem;
    font-weight: bold;
  }
  .header {
    display: flex;
    justify-content: space-between;
  }

  .header-center {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: space-around;
  }

  .team2 {
    justify-content: right;
  }

  .header-team.team1 .name {
    text-align: left;
  }
  .header-team.team2 .name {
    text-align: right;
  }

  .score {
    font-size: 2rem;
    font-weight: bold;
    margin: 0 1rem;
    display: flex;
    align-items: center;
  }
  .emoji {
    font-size: 1rem;
  }
</style>
