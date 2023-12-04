<script lang="ts">
  import { MatchDetails } from "../models/Match";

  import {
    InProgressMatchState,
    LiveMatch,
    LiveMatchGroup,
    liveMatchGroupStore,
  } from "../stores/LiveMatchGroupStore";
  import Bases from "./Bases.svelte";
  import MatchCardHeader from "./MatchCardHeader.svelte";

  export let match: MatchDetails;
  export let compact: boolean = false;

  let liveMatch: LiveMatch | undefined;

  liveMatchGroupStore.subscribe(
    (liveMatchGroup: LiveMatchGroup | undefined) => {
      if (liveMatchGroup && liveMatchGroup.id == Number(match.matchGroupId)) {
        liveMatch = liveMatchGroup.matches[Number(match.id)];
      }
    }
  );

  let getPlayerName = (
    playerId: number,
    liveMatch: InProgressMatchState
  ): string => {
    let player = liveMatch.players.find((p) => p.id == playerId);
    if (!player) {
      return "Unknown Player";
    }
    return player.name;
  };
  let getActivePlayerName = (
    team: "team1" | "team2",
    liveMatch: InProgressMatchState
  ): string => {
    let playerId: number;
    let emoji: string;
    if (team in liveMatch.offenseTeamId) {
      playerId = liveMatch.field.offense.atBat;
      // Batter emoji
      emoji = "🏏";
    } else {
      playerId = liveMatch.field.defense.pitcher;
      // Pitcher emoji
      emoji = "⚾";
    }
    let playerName = getPlayerName(playerId, liveMatch);
    if (team in liveMatch.offenseTeamId) {
      playerName = `${emoji} ${playerName}`;
    } else {
      playerName += ` ${emoji}`;
    }
    return playerName;
  };
  $: log =
    liveMatch?.log
      .reverse() // Reverse the filtered array
      .slice(0, 5) || []; // Take only the first 5 entries
</script>

<div class="card">
  <MatchCardHeader
    team1={match.team1}
    team2={match.team2}
    winner={match.winner}
  >
    {#if match.state == "InProgress"}
      {#if liveMatch}
        {#if "inProgress" in liveMatch.state}
          <Bases state={liveMatch.state.inProgress.field.offense} />
        {/if}
      {:else}
        Loading...
      {/if}
    {:else if match.state == "Played"}
      {#if !match.winner}
        <div>Bad state</div>
      {:else if "team1" in match.winner}
        {match.team1.name} Win!
      {:else if "team2" in match.winner}
        {match.team2.name} Win!
      {:else}
        Its a tie!
      {/if}
    {:else if match.state == "AllAbsent"}
      No one showed up
    {:else if match.state == "Team1Absent"}
      Team {match.team1.name} didn't show up, thus forfeit
    {:else if match.state == "Team2Absent"}
      Team {match.team2.name} didn't show up, thus forfeit
    {:else if match.state == "Error"}
      Error
    {/if}
  </MatchCardHeader>
  {#if !compact}
    {#if liveMatch && "inProgress" in liveMatch.state}
      <div class="mid">
        <div class="team-lead">
          {getActivePlayerName("team1", liveMatch.state.inProgress)}
        </div>
        <div>
          <div>Round {liveMatch.state.inProgress.round}</div>
        </div>
        <div class="team-lead">
          {getActivePlayerName("team2", liveMatch.state.inProgress)}
        </div>
      </div>
      <div class="footer">
        <ul>
          {#each log as logEntry}
            <li>{logEntry.message}</li>
          {/each}
        </ul>
      </div>
    {:else}
      <div class="mid" />
      <div class="footer" />
    {/if}
  {/if}
</div>

<style>
  /* Card styles for matches */
  .card {
    background-color: var(--color-bg-dark);
    color: var(--color-text-light);
    padding: 0.5em;
    margin: 0.5em;
    border: 1px solid var(--color-border);
    border-radius: 8px;
    padding: 1em;
    margin: 1em;
    width: 400px;
  }

  .card:hover {
    border-color: var(--color-primary);
  }

  .mid {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
  }

  .team-lead {
    font-size: 0.9rem;
  }
</style>
