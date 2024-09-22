<script lang="ts">
  import StartingGame from "./StartingGame.svelte";
  import { GameWithMetaData } from "../../ic-agent/declarations/main";
  import InProgressGame from "./InProgressGame.svelte";
  import CompleteGame from "./CompleteGame.svelte";

  export let game: GameWithMetaData;
</script>

<div>
  {#if "starting" in game.state}
    <StartingGame {game} state={game.state.starting} />
  {:else if "inProgress" in game.state}
    <InProgressGame {game} />
  {:else}
    <CompleteGame state={game.state.completed} />
  {/if}
</div>
