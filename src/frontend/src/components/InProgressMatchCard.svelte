<script context="module" lang="ts">
</script>

<script lang="ts">
  import { InProgressMatchState } from "../ic-agent/Stadium";

  import { MatchDetail } from "../models/Match";
  import Bases from "./Bases.svelte";

  import MatchCardHeader from "./MatchCardHeader.svelte";

  export let match: MatchDetail;
  export let matchState: InProgressMatchState;
  export let compact: boolean = false;

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
  $: log = matchState.log
    .reverse() // Reverse the filtered array
    .slice(0, 5); // Take only the first 5 entries
</script>

<div class="card">
  <MatchCardHeader
    {match}
    team1Score={matchState.team1.score}
    team2Score={matchState.team2.score}
    winner={undefined}
  >
    <Bases state={matchState.field.offense} />
  </MatchCardHeader>

  {#if !compact}
    <div class="mid">
      <div class="team-lead">
        {getActivePlayerName("team1", matchState)}
      </div>
      <div>
        <div>Round {matchState.round}</div>
      </div>
      <div class="team-lead">
        {getActivePlayerName("team2", matchState)}
      </div>
    </div>
    <div class="footer">
      <ul>
        {#each log as logEntry}
          <li>{logEntry.description}</li>
        {/each}
      </ul>
    </div>
  {/if}
</div>

<style>
  .card {
    border-radius: 5px;
    box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.3);
    width: 100%;
  }
  .card :global(a) {
    text-decoration: none;
    color: inherit;
  }
  .team-lead {
    font-size: 0.9rem;
  }
  .mid {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
  }
</style>
