<script lang="ts">
  import { Link } from "svelte-routing";
  import type { Match } from "../types/Match";
  export let match: Match;
</script>

<div class="match-card">
  <Link to={`/matches/${match.id}`}>
    <div class="match-card-title">
      <div>
        <img src={match.team1.logo} alt="{match.team1.name} Logo" />
      </div>
      <div>vs</div>
      <div>
        <img src={match.team2.logo} alt="{match.team2.name} Logo" />
      </div>
    </div>
    <div class="match-card-content">
      <span class="match-card-date">{match.start.toDateString()}</span>
      {#if match.team1.matchStats?.score && match.team2.matchStats?.score}
        <span class="match-card-score">
          {match.team1.matchStats?.score} - {match.team2.matchStats?.score}
        </span>
      {:else}
        <span>TBD</span>
      {/if}
    </div>
  </Link>
</div>

<style>
  .match-card {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    padding: 1rem;
    border: 1px solid #ccc;
    border-radius: 5px;
    box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.3);
    margin: 1rem;
  }
  .match-card :global(a) {
    text-decoration: none;
    color: inherit;
  }

  .match-card-title {
    margin: 0;
    font-size: 1.5rem;
    display: flex;
    align-items: center;
  }

  .match-card-content {
    display: flex;
    flex-direction: column;
  }

  .match-card-date {
    text-align: center;
  }

  .match-card-score {
    font-size: 2rem;
    font-weight: bold;
  }
</style>
