<script lang="ts">
  import StartingGame from "./StartingGame.svelte";
  import { GameWithMetaData } from "../../ic-agent/declarations/main";
  import InProgressGame from "./InProgressGame.svelte";
  import CompleteGame from "./CompleteGame.svelte";
  import GameNav from "./GameNav.svelte";

  export let game: GameWithMetaData;
</script>

<GameNav {game}>
  {#if "starting" in game.state}
    <StartingGame state={game.state.starting} />
  {:else if "inProgress" in game.state}
    <InProgressGame state={game.state.inProgress} />
  {:else}
    <CompleteGame state={game.state.completed} />
  {/if}
</GameNav>
