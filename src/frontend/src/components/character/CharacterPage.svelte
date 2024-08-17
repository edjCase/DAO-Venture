<script lang="ts">
  import { gameStateStore } from "../../stores/GameStateStore";
  import Character from "./Character.svelte";

  $: gameState = $gameStateStore;
</script>

{#if gameState !== undefined}
  {#if "notInitialized" in gameState}
    <div>Game not initialized</div>
  {:else if "notStarted" in gameState}
    <div>Game not started</div>
  {:else if "inProgress" in gameState}
    <div>Turn: {gameState.inProgress.turn}</div>
    <Character character={gameState.inProgress.character} />
  {:else}
    <div>Game over</div>
    <div>Total Turns: {gameState.completed.turns}</div>
    <div>Difficulty: {gameState.completed.difficulty}</div>
    <Character character={gameState.completed.character} />
  {/if}
{/if}
