<script lang="ts">
  import { Link } from "svelte-routing";
  import type { Game } from "../types/Game";
  export let game: Game;
</script>

<div class="game-card">
  <Link to={`/game/${game.id}`}>
    <div class="game-card-title">
      <div>
        <img src={game.team1.logo} alt="{game.team1.name} Logo" />
      </div>
      <div>vs</div>
      <div>
        <img src={game.team2.logo} alt="{game.team2.name} Logo" />
      </div>
    </div>
    <div class="game-card-content">
      <span class="game-card-location">{game.stadium.name}</span>
      <span class="game-card-date">{game.start.toDateString()}</span>
      {#if game.team1.gameStats?.score && game.team2.gameStats?.score}
        <span class="game-card-score">
          {game.team1.gameStats?.score} - {game.team2.gameStats?.score}
        </span>
      {:else}
        <span>TBD</span>
      {/if}
    </div>
  </Link>
</div>

<style>
  .game-card {
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
  .game-card :global(a) {
    text-decoration: none;
    color: inherit;
  }

  .game-card-title {
    margin: 0;
    font-size: 1.5rem;
    display: flex;
    align-items: center;
  }

  .game-card-content {
    display: flex;
    flex-direction: column;
  }

  .game-card-date {
    text-align: center;
  }

  .game-card-location {
    margin: 0.5rem 0;
    font-size: 1.2rem;
    text-align: center;
  }

  .game-card-score {
    font-size: 2rem;
    font-weight: bold;
  }
</style>
