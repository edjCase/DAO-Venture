<script lang="ts">
  import PlayerMatchStats from "../components/PlayerMatchStats.svelte";
  import type { Match, Team } from "../types/Match";
  import Events from "../components/Events.svelte";
  import ScoreHeader from "../components/ScoreHeader.svelte";
  import { matchStore } from "../stores/MatchStore";
  import { get } from "svelte/store";

  export let id;

  let match: Match = get(matchStore).find((item) => item.id == id);
</script>

{#if match}
  <section id="match-details">
    <ScoreHeader {match} />

    <div class="team-stats-container">
      <div class="team-stats">
        <h1>{match.team1.name}</h1>
        <PlayerMatchStats teamInfo={match.team1} />
      </div>
      <div class="team-stats">
        <h1>{match.team2.name}</h1>
        <PlayerMatchStats teamInfo={match.team2} />
      </div>
    </div>

    <section class="match-events">
      <h2>Events</h2>
      <Events {match} />
    </section>
  </section>
{/if}

<style>
  .team-stats-container {
    display: flex;
    justify-content: space-around;
  }
  .team-stats {
    width: 40%;
  }
  h1,
  h2 {
    color: var(--text-color);
  }

  h1 {
    text-align: center;
  }

  section {
    margin-bottom: 20px;
  }

  .match-events {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
</style>
