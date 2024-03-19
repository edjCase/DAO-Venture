<script lang="ts">
  import { TeamId, TeamIdOrTie } from "../../ic-agent/declarations/league";
  import { TeamDetailsOrUndetermined } from "../../models/Match";
  import TeamLogo from "../team/TeamLogo.svelte";

  export let team1: TeamDetailsOrUndetermined;
  export let team2: TeamDetailsOrUndetermined;
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

  let getScoreText = (team: TeamDetailsOrUndetermined) => {
    if ("score" in team && team.score !== undefined) {
      return team.score;
    }
    return "-";
  };
  $: team1Score = getScoreText(team1);
  $: team2Score = getScoreText(team2);
  $: team1Emoji = getTeamEmojis(winner, "team1");
  $: team2Emoji = getTeamEmojis(winner, "team2");
</script>

<div class="header">
  <div class="header-team team1">
    <TeamLogo team={team1} size="sm" />

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
    <TeamLogo team={team2} size="sm" />
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
