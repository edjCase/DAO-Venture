<script lang="ts">
  import { TeamIdOrTie } from "../ic-agent/Stadium";
  import { MatchDetail } from "../models/Match";
  import Tooltip from "./Tooltip.svelte";

  export let match: MatchDetail;
  export let team1Score: bigint | undefined;
  export let team2Score: bigint | undefined;
  export let winner: TeamIdOrTie | undefined;

  let crownEmojiOrEmpty = (teamId: "team1" | "team2") => {
    if (winner === undefined) return "";
    if (teamId in winner) return "👑";
    if ("tie" in winner) return "😑";
    return "";
  };
</script>

<div class="header">
  <div class="header-team team1">
    <Tooltip>
      <img
        class="logo"
        src={match.team1.logoUrl}
        alt="{match.team1.name} Logo"
        slot="content"
      />
      <div slot="tooltip" class="name">{match.team1.name}</div>
    </Tooltip>

    <div class="score">
      {team1Score ?? "-"}{crownEmojiOrEmpty("team1")}
    </div>
  </div>
  <div class="header-center" />
  <div class="header-team team2">
    <div class="score">
      {team2Score ?? "-"}{crownEmojiOrEmpty("team2")}
    </div>
    <Tooltip>
      <img
        class="logo"
        src={match.team2.logoUrl}
        alt="{match.team2.name} Logo"
        slot="content"
      />
      <div slot="tooltip" class="name">{match.team2.name}</div>
    </Tooltip>
  </div>
</div>

<style>
  .header-team {
    display: flex;
    flex-direction: row;
    width: 140px;
    align-items: center;
  }
  .name {
    font-size: 2rem;
    font-weight: bold;
  }
  .logo {
    width: 50px;
    height: 50px;
    border-radius: 5px;
  }

  .header {
    display: flex;
    justify-content: space-between;
  }

  .header-center {
    width: 100px;
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
  }
</style>
