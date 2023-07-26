<script lang="ts">
    import GameCard from './GameCard.svelte';
    import type { Game } from '../types/Game';
    export let games : Game[];
  </script>
  
  <style>
    .game-card-grid {
        display: flex;
        flex-direction: row;
        justify-content: center;
    }
  </style>
  
  <div class="game-card-grid">
    {#each games as game (game.id)}
      <GameCard game={game} />
    {/each}
  </div>