<script lang="ts">
  import { MatchDetails } from "../../models/Match";

  import {
    LiveMatch,
    LiveMatchGroup,
    LiveMatchState,
    liveMatchGroupStore,
  } from "../../stores/LiveMatchGroupStore";
  import Bases from "./Bases.svelte";
  import MatchCardHeader from "./MatchCardHeader.svelte";

  export let match: MatchDetails;
  export let compact: boolean = false;

  let liveMatch: LiveMatch | undefined;

  $: {
    const liveMatchGroup: LiveMatchGroup | undefined = $liveMatchGroupStore;
    if (liveMatchGroup && liveMatchGroup.id == Number(match.matchGroupId)) {
      liveMatch = liveMatchGroup.matches[Number(match.id)];
      if (match.team1 && match.team2) {
        match.team1.score = liveMatch?.team1.score;
        match.team2.score = liveMatch?.team2.score;
      }
    }
  }

  let getPlayerName = (playerId: number, state: LiveMatchState): string => {
    let player = state.players.find((p) => p.id == playerId);
    if (!player) {
      return "Unknown Player";
    }
    return player.name;
  };
  let getActivePlayerName = (
    team: "team1" | "team2",
    state: LiveMatchState
  ): string => {
    let playerId: number;
    let emoji: string;
    if (team in state.offenseTeamId) {
      playerId = state.bases.atBat;
      // Batter emoji
      emoji = "🏏";
    } else {
      playerId =
        state.players.find(
          (p) => "pitcher" in p.position && p.teamId == state.offenseTeamId
        )?.id || 0;
      // Pitcher emoji
      emoji = "⚾";
    }
    let playerName = getPlayerName(playerId, state);
    if (team in state.offenseTeamId) {
      playerName = `${emoji} ${playerName}`;
    } else {
      playerName += ` ${emoji}`;
    }
    return playerName;
  };
  $: log =
    liveMatch?.log
      .slice()
      .reverse() // Reverse the filtered array
      .slice(0, 5) || []; // Take only the first 5 entries
</script>

<div class="card" class:full={!compact}>
  <MatchCardHeader
    team1={match.team1}
    team2={match.team2}
    winner={match.winner}
  >
    {#if match.state == "InProgress"}
      {#if liveMatch}
        {#if !!liveMatch.liveState}
          <Bases state={liveMatch.liveState.bases} />
        {/if}
      {:else}
        Loading...
      {/if}
    {:else if match.state == "Played"}
      {#if !match.winner}
        <div>Bad state: {match.error}</div>
      {:else if "team1" in match.winner}
        {match.team1?.name} Win!
      {:else if "team2" in match.winner}
        {match.team2?.name} Win!
      {:else}
        Its a tie!
      {/if}
    {:else if match.state == "Error"}
      <div>Bad state: {match.error}</div>
    {/if}
  </MatchCardHeader>
  {#if !compact}
    {#if liveMatch && !!liveMatch.liveState}
      <div class="mid">
        <div class="team-lead">
          {getActivePlayerName("team1", liveMatch.liveState)}
        </div>
        <div>
          <div>Round {liveMatch.liveState.round}</div>
        </div>
        <div class="team-lead">
          {getActivePlayerName("team2", liveMatch.liveState)}
        </div>
      </div>
    {:else}
      <div class="mid" />
    {/if}

    <div class="footer">
      <ul>
        {#each log as logEntry}
          <li>{logEntry.message}</li>
        {/each}
      </ul>
    </div>
  {/if}
</div>

<style>
  /* Card styles for matches */
  .card {
    background-color: var(--color-bg-dark);
    color: var(--color-text-light);
    padding: 0.5em;
    border: 1px solid var(--color-border);
    border-radius: 8px;
    width: 100%;
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
