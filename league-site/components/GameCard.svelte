

<script>
  import { Link } from "svelte-routing";
  export let game;
</script>

<div class="game-card">
  <span class="game-card-title">{game.team1} vs {game.team2}</span>
  <span class="game-card-location">Location: {game.stadium}</span>
  {#if game.team1Score && game.team2Score}
    <span class="game-card-score">{game.team1Score} - {game.team2Score}</span>
  {:else}
    <span >TBD</span>
  {/if}
  <Link to={`/game/${game.id}`}>View Game</Link>
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
  }

  .game-card-title {
    margin: 0;
    font-size: 1.5rem;
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