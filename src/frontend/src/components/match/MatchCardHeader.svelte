<script lang="ts">
  import { TeamDetailsOrUndetermined } from "../../models/Match";
  import { TeamIdOrTie } from "../../models/Team";
  import TeamLogo from "../team/TeamLogo.svelte";

  export let team1: TeamDetailsOrUndetermined;
  export let team2: TeamDetailsOrUndetermined;
  export let winner: TeamIdOrTie | undefined;

  let crownEmojiOrEmpty = (
    winner: TeamIdOrTie | undefined,
    teamId: "team1" | "team2"
  ) => {
    if (winner === undefined) return "";
    if (teamId in winner) return "👑";
    if ("tie" in winner) return "😑";
    return "";
  };
  let getScoreText = (team: TeamDetailsOrUndetermined) => {
    if ("score" in team && team.score !== undefined && !isNaN(team.score)) {
      return team.score;
    }
    return "-";
  };
  $: team1Score = getScoreText(team1);
  $: team2Score = getScoreText(team2);
  $: team1Emoji = crownEmojiOrEmpty(winner, "team1");
  $: team2Emoji = crownEmojiOrEmpty(winner, "team2");
</script>

<div class="header">
  <div class="header-team team1">
    <TeamLogo team={team1} size="sm" borderColor={undefined} />

    <div class="score">
      {team1Score}
      <span class="emoji">{team1Emoji}</span>
    </div>
  </div>
  <div class="header-center">
    <slot />
  </div>
  <div class="header-team team2">
    <div class="score">
      <span class="emoji">{team2Emoji}</span>
      {team2Score}
    </div>
    <TeamLogo team={team2} size="sm" borderColor={undefined} />
  </div>
</div>

<style>
  .header-team {
    display: flex;
    flex-direction: row;
    align-items: center;
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
