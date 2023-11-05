<script context="module" lang="ts">
  export type InProgressTeamDetails = {
    name: string;
    logoUrl: string;
    score: bigint;
    activePlayerName: string;
  };
  export type CompletedTeamDetails = {
    name: string;
    logoUrl: string;
    score: bigint | undefined;
  };
  export type TeamDetails = InProgressTeamDetails | CompletedTeamDetails;

  export type BaseState = {
    firstBase: number | undefined;
    secondBase: number | undefined;
    thirdBase: number | undefined;
  };

  export type InProgressMatchDetail = {
    team1: TeamDetails;
    team2: TeamDetails;
    baseState: BaseState;
    round: bigint | undefined;
  };
  export type CompletedMatchDetail = {
    title: string;
    team1: CompletedTeamDetails;
    team2: CompletedTeamDetails;
  };

  export type MatchDetail = InProgressMatchDetail | CompletedMatchDetail;
</script>

<script lang="ts">
  import Bases from "./Bases.svelte";
  import Tooltip from "./Tooltip.svelte";

  export let match: MatchDetail;
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
        {#if match.team1.score !== undefined}
          <div class="score">{match.team1.score}</div>
        {/if}
      </div>
      <div class="mid">
        {#if "activePlayerName" in match.team1}
          <div class="team-lead">{match.team1.activePlayerName}</div>
        {/if}
      </div>
      <div class="bottom" />
    </div>
    <div class="center">
      <div class="top">
        {#if "baseState" in match}
          <Bases state={match.baseState} />
        {:else if "title" in match}
          <div class="title">{match.title}</div>
        {/if}
      </div>

      <div class="mid">
        {#if "round" in match}
          <div>Round {match.round}</div>
        {/if}
      </div>
      <div class="bottom" />
    </div>
    <div class="team">
      <div class="top">
        {#if match.team2.score !== undefined}
          <div class="score">{match.team2.score}</div>
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
        {#if "activePlayerName" in match.team2}
          <div class="team-lead">{match.team2.activePlayerName}</div>
        {/if}
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
