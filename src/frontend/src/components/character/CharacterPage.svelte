<script lang="ts">
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import Difficulty from "../common/Difficulty.svelte";
  import Character from "./Character.svelte";

  $: currentGame = $currentGameStore;
</script>

{#if currentGame !== undefined}
  {#if "notStarted" in currentGame.state}
    <div>Game not started</div>
  {:else if "voting" in currentGame.state}
    <div>Vote for the next character</div>
  {:else if "inProgress" in currentGame.state}
    <Character character={currentGame.state.inProgress.character} />
  {:else}
    <div>Game over</div>
    <div>Total Turns: {currentGame.state.completed.turns}</div>
    <div>
      Difficulty: <Difficulty value={currentGame.state.completed.difficulty} />
    </div>
    <Character character={currentGame.state.completed.character} />
  {/if}
{/if}
