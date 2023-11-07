<script context="module" lang="ts">
</script>

<script lang="ts">
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
</script>

<div class="card">
  <div class="header">
    <div class="team">
      <div class="top">
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
      <div class="mid">
        <!-- TODO -->
        <!-- {#if 'inProgress' in matchState && "activePlayerName" in matchState.inProgress.}
          <div class="team-lead">{match.team1.activePlayerName}</div>
        {/if} -->
      </div>
      <div class="bottom" />
    </div>
    <div class="center">
      <div class="top">
        {#if "inProgress" in matchState}
          <Bases state={matchState.inProgress.field.offense} />
        {:else if "title" in match}
          <div class="title">{match.title}</div>
        {/if}
      </div>

      <div class="mid">
        {#if "inProgress" in matchState}
          <div>Round {matchState.inProgress.round}</div>
        {/if}
      </div>
      <div class="bottom" />
    </div>
    <div class="team">
      <div class="top">
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
      <div class="mid">
        <!-- TODO -->
        <!-- {#if "activePlayerName" in match.team2}
          <div class="team-lead">{match.team2.activePlayerName}</div>
        {/if} -->
      </div>
      <div class="bottom" />
    </div>
  </div>
</div>

<style>
  .card {
    background: black;
    border-radius: 5px;
    box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.3);
    margin: 1rem;
  }
  .card :global(a) {
    text-decoration: none;
    color: inherit;
  }
  .team {
    display: flex;
    flex-direction: column;
  }
  .name {
    font-size: 2rem;
    font-weight: bold;
  }
  .logo {
    width: 50px;
    height: 50px;
  }

  .header {
    display: flex;
    justify-content: space-between;
  }
  .top {
    display: flex;
    flex-direction: row;
    align-items: center;
    height: 50px;
  }
  .top,
  .mid,
  .bottom {
    max-width: 120px;
  }

  .team-lead {
    font-size: 0.9rem;
    text-align: center;
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
</style>
