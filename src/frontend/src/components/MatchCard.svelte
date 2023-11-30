<script lang="ts" context="module">
  export type MatchVariant =
    | { completed: CompletedMatch }
    | { live: InProgressMatch }
    | { next: ScheduledMatch }
    | { upcoming: NotScheduledMatch };
</script>

<script lang="ts">
  import { LiveMatchGroup } from "../ic-agent/Stadium";

  import {
    CompletedMatch,
    InProgressMatch,
    NotScheduledMatch,
    ScheduledMatch,
  } from "../models/Season";
  import { TeamIdOrTie } from "../models/Team";
  import { liveMatchGroupStore } from "../stores/LiveMatchGroupStore";
  import MatchCardHeader from "./MatchCardHeader.svelte";

  export let matchId: bigint;
  export let match: MatchVariant;
  export let liveMatch: LiveMatchGroup | undefined;
  export let compact: boolean = false;

  liveMatchGroupStore.subscribe((liveMatchGroup) => {
    if (liveMatchGroup.id == matchId) {
      liveMatch = liveMatchGroup;
    }
  });

  let team1Score: bigint | undefined;
  let team2Score: bigint | undefined;
  let winner: TeamIdOrTie | undefined;
  if ("completed" in match && "played" in match.completed.result) {
    team1Score = match.completed.result.played.team1Score;
    team2Score = match.completed.result.played.team2Score;
    winner = match.completed.result.played.winner;
  } else {
    team1Score = undefined;
    team2Score = undefined;
    winner = undefined;
  }

  let getPlayerName = (playerId: number): string => {
    let players: { name: string }[];
    if ("completed" in match) {
      players = match.completed.players;
    } else if ("live" in match) {
      players = match.live.result.a;
    } else if ("next" in match) {
      players = match.next.players;
    } else {
      players = match.upcoming.players;
    }
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
    liveMatch: LiveMatchGroup
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
  <MatchCardHeader {match} {team1Score} {team2Score} {winner}>
    {#if "live" in match}
      <Bases state={matchState.field.offense} />
    {:else if "completed" in match}
      {#if !match.completed.winner}
        No Winner
      {:else if "team1" in match.completed.winner}
        {match.team1.name} Win!
      {:else if "team2" in match.completed.winner}
        {match.team2.name} Win!
      {:else}
        Its a tie!
      {/if}
    {:else if "allAbsent" in matchState}
      No one showed up
    {:else if "absentTeam" in matchState}
      Team {matchState.absentTeam.name} didn't show up, thus forfeit
    {:else if "stateBroken" in matchState}
      Broken: {matchState.stateBroken}
    {/if}
  </MatchCardHeader>
  {#if !compact}
    {#if "live" in match}
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
