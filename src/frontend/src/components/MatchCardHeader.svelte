<script lang="ts">
  import { TeamDetails } from "../models/Match";
  import { TeamIdOrTie } from "../models/Team";
  import Tooltip from "./Tooltip.svelte";

  export let team1: TeamDetails;
  export let team2: TeamDetails;
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
        src={team1.logoUrl}
        alt="{team1.name} Logo"
        slot="content"
      />
      <div slot="tooltip" class="name">{team1.name}</div>
    </Tooltip>

    <div class="score">
      {team1.score == undefined ? "-" : team1.score}
      <span class="emoji">{crownEmojiOrEmpty("team1")}</span>
    </div>
  </div>
  <div class="header-center">
    <slot />
  </div>
  <div class="header-team team2">
    <div class="score">
      {team2.score == undefined ? "-" : team2.score}
      <span class="emoji">{crownEmojiOrEmpty("team2")}</span>
    </div>
    <Tooltip>
      <img
        class="logo"
        src={team2.logoUrl}
        alt="{team2.name} Logo"
        slot="content"
      />
      <div slot="tooltip" class="name">{team2.name}</div>
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
