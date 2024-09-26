<script lang="ts">
  import { currentGameStore } from "../stores/CurrentGameStore";
  import InitialDataLoad from "./game/InitialDataLoad.svelte";
  import GamePlayer from "./game/GamePlayer.svelte";
  import OverviewPage from "./OverviewPage.svelte";

  $: currentGame = $currentGameStore;
</script>

<div class="pb-6 text-center">
  {#if currentGame === undefined}
    <InitialDataLoad />
    <OverviewPage />
  {:else}
    <GamePlayer game={currentGame} />
  {/if}
</div>
