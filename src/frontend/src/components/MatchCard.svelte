<script context="module" lang="ts">
</script>

<script lang="ts">
  import { InProgressMatchState } from "../ic-agent/Stadium";

  import { MatchDetail, StartedMatchStateDetails } from "../models/Match";

  import Bases from "./Bases.svelte";
  import Tooltip from "./Tooltip.svelte";

  export let match: MatchDetail;
  export let matchState: StartedMatchStateDetails;

  let team1Score: bigint | undefined;
  let team2Score: bigint | undefined;
  if ("inProgress" in matchState) {
    team1Score = matchState.inProgress.team1.score;
    team2Score = matchState.inProgress.team2.score;
  } else if ("completed" in matchState && "played" in matchState.completed) {
    team1Score = matchState.completed.played.team1.score;
    team2Score = matchState.completed.played.team2.score;
  }
  let getPlayerName = (playerId: number): string => {
    let player = match.team1.players.find((p) => p.id == playerId);
    if (!player) {
      player = match.team2.players.find((p) => p.id == playerId);
      if (!player) {
        return "Unknown Player";
      }
    }
    return player.name;
  };
  let getActivePlayerName = (
    team: "team1" | "team2",
    matchState: InProgressMatchState
  ): string => {
    let playerId: number;
    let emoji: string;
    if (team in matchState.offenseTeamId) {
      playerId = matchState.field.offense.atBat;
      // Batter emoji
      emoji = "🏏";
    } else {
      playerId = matchState.field.defense.pitcher;
      // Pitcher emoji
      emoji = "⚾";
    }
    let playerName = getPlayerName(playerId);
    if (team in matchState.offenseTeamId) {
      playerName = `${emoji} ${playerName}`;
    } else {
      playerName += ` ${emoji}`;
    }
    return playerName;
  };
  $: log =
    "inProgress" in matchState
      ? matchState.inProgress.log
          .reverse() // Reverse the filtered array
          .slice(0, 5) // Take only the first 5 entries
      : [];
</script>

<div class="card">
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
      {#if team1Score !== undefined}
        <div class="score">{team1Score}</div>
      {/if}
    </div>
    <div class="header-center">
      {#if "inProgress" in matchState}
        <Bases state={matchState.inProgress.field.offense} />
      {:else if "title" in match}
        <div class="title">{match.title}</div>
      {/if}
    </div>
    <div class="header-team team2">
      {#if team2Score !== undefined}
        <div class="score">{team2Score}</div>
      {/if}
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
  <div class="mid">
    {#if "inProgress" in matchState}
      <div class="team-lead">
        {getActivePlayerName("team1", matchState.inProgress)}
      </div>
    {/if}
    <div>
      {#if "inProgress" in matchState}
        <div>Round {matchState.inProgress.round}</div>
      {/if}
    </div>
    {#if "inProgress" in matchState}
      <div class="team-lead">
        {getActivePlayerName("team2", matchState.inProgress)}
      </div>
    {/if}
  </div>
  <div class="footer">
    <ul>
      {#each log as logEntry}
        <li>{logEntry.description}</li>
      {/each}
    </ul>
  </div>
</div>

<style>
  .card {
    background: black;
    border-radius: 5px;
    box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.3);
    margin: 1rem;
    width: 350px;
  }
  .card :global(a) {
    text-decoration: none;
    color: inherit;
  }
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

  .team-lead {
    font-size: 0.9rem;
  }
  .header-team.team1 .name {
    text-align: left;
  }
  .header-team.team2 .name {
    text-align: right;
  }

  .title {
    display: flex;
    align-items: center;
  }

  .score {
    font-size: 2rem;
    font-weight: bold;
    margin: 0 1rem;
  }

  .mid {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
  }
</style>
