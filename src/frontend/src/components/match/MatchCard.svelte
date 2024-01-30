<script lang="ts">
  import { MatchDetails } from "../../models/Match";
  import { TurnLog } from "../../models/Season";

  import {
    LiveMatch,
    LiveMatchGroup,
    LiveMatchState,
    liveMatchGroupStore,
  } from "../../stores/LiveMatchGroupStore";
  import Bases from "./Bases.svelte";
  import Field from "./Field.svelte";
  import MatchCardHeader from "./MatchCardHeader.svelte";
  import MatchEvent from "./MatchEvent.svelte";

  export let match: MatchDetails;
  export let compact: boolean = false;

  let liveMatch: LiveMatch | undefined;
  let turn: TurnLog | undefined;

  $: {
    const liveMatchGroup: LiveMatchGroup | undefined = $liveMatchGroupStore;
    if (liveMatchGroup && liveMatchGroup.id == Number(match.matchGroupId)) {
      liveMatch = liveMatchGroup.matches[Number(match.id)];
      if (match.team1 && match.team2) {
        match.team1.score = liveMatch?.team1.score;
        match.team2.score = liveMatch?.team2.score;
      }
      if (liveMatch && liveMatch.log.rounds.length > 0) {
        let currentRound =
          liveMatch.log.rounds[liveMatch.log.rounds.length - 1];
        turn = currentRound.turns[currentRound.turns.length - 1];
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
  let getActivePlayerName = (teamId: "team1" | "team2"): string => {
    if (!liveMatch?.liveState) {
      return "";
    }
    let team = teamId == "team1" ? liveMatch.team1 : liveMatch.team2;
    let playerId: number;
    let emoji: string;
    if (teamId in liveMatch.liveState.offenseTeamId) {
      playerId = liveMatch.liveState.bases.atBat;
      // Batter emoji
      emoji = "🏏";
    } else {
      playerId = team.positions.pitcher;
      // Pitcher emoji
      emoji = "⚾";
    }
    let playerName = getPlayerName(playerId, liveMatch.liveState);
    if (teamId in liveMatch.liveState.offenseTeamId) {
      playerName = `${emoji} ${playerName}`;
    } else {
      playerName += ` ${emoji}`;
    }
    return playerName;
  };
</script>

<div class="card" class:full={!compact}>
  <MatchCardHeader
    team1={match.team1}
    team2={match.team2}
    winner={match.winner}
  >
    {#if match.state == "InProgress"}
      {#if liveMatch}
        {#if !!liveMatch.liveState && compact}
          <Bases state={liveMatch.liveState.bases} />
        {/if}
      {:else}
        Loading...
      {/if}
    {:else if match.state == "Played"}
      {#if !match.winner}
        <div>Bad state</div>
      {:else if "team1" in match.winner}
        {match.team1?.name} Win!
      {:else if "team2" in match.winner}
        {match.team2?.name} Win!
      {:else}
        Its a tie!
      {/if}
    {:else if match.state == "Error"}
      <div>Bad state:</div>
    {/if}
  </MatchCardHeader>
  {#if !compact}
    <div class="mid">
      {#if liveMatch && !!liveMatch.liveState}
        <Field match={liveMatch} />
      {/if}
    </div>

    <div class="footer">
      {#if turn}
        {#each turn.events as e}
          <MatchEvent
            event={e}
            team1Id={match.team1.id}
            team2Id={match.team2.id}
          />
        {/each}
      {/if}
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

  .mid-header {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
  }

  .team-lead {
    font-size: 0.9rem;
  }
</style>
