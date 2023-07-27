<script lang="ts">
  import PlayerGameStats from "../components/PlayerGameStats.svelte";
  import type { Game, Team } from "../types/Game";
  import Events from "../components/Events.svelte";
  import ScoreHeader from "../components/ScoreHeader.svelte";
  import { gamesStore } from "../stores/GameStore";
  import { get } from "svelte/store";

  export let id;

  let game: Game = get(gamesStore).find((item) => item.id == id);
</script>

{#if game}
  <section id="game-details">
    <ScoreHeader {game} />

    <div class="team-stats-container">
      <div class="team-stats">
        <h1>{game.team1.name}</h1>
        <PlayerGameStats teamInfo={game.team1} />
      </div>
      <div class="team-stats">
        <h1>{game.team2.name}</h1>
        <PlayerGameStats teamInfo={game.team2} />
      </div>
    </div>

    <section class="game-events">
      <h2>Events</h2>
      <Events {game} />
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

  .game-events {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
</style>
