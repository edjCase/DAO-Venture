<script lang="ts">
  import { TeamIdOrTie } from "../ic-agent/Stadium";
  import { MatchDetail } from "../models/Match";
  import { liveMatchGroupStore } from "../stores/LiveMatchGroupStore";
  import {
    MatchVariant,
    seasonStatusStore as scheduleStore,
  } from "../stores/ScheduleStore";
  import MatchCardHeader from "./MatchCardHeader.svelte";

  export let match: MatchVariant;
  export let compact: boolean = false;

  let matchDetails: MatchDetail | undefined;

  scheduleStore.subscribe((matchGroup) => {
    matchDetails = matchGroup.matches[match.live.index];
  });

  let team1Score: bigint | undefined;
  let team2Score: bigint | undefined;
  let winner: TeamIdOrTie | undefined;
  if ("completed" in match) {
    team1Score = match.completed.team1Score;
    team2Score = match.completed.team2Score;
    winner = match.completed.winner;
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
