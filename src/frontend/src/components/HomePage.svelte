<script lang="ts">
  import { currentGameStore } from "../stores/CurrentGameStore";
  import LoadingButton from "./common/LoadingButton.svelte";
  import { mainAgentFactory } from "../ic-agent/Main";
  import { userStore } from "../stores/UserStore";
  import InitialDataLoad from "./game/InitialDataLoad.svelte";
  import GamePlayer from "./game/GamePlayer.svelte";
  import LoginPage from "./LoginPage.svelte";

  $: currentGame = $currentGameStore;
  $: user = $userStore;

  let createGame = async () => {
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.createGame();
    if ("ok" in result) {
      currentGameStore.refetch();
    } else {
      console.error("Failed to create game", result);
    }
  };
</script>

<div class="bg-gray-800 rounded p-2 py-8 text-center">
  {#if user === undefined}
    <LoginPage />
  {:else}
    {#if currentGame === undefined}
      <InitialDataLoad />
      <div class="text-3xl">OMG SO EXCITING, ITS YOUR FIRST GAME</div>
      <div class="text-3xl mb-4">Good luck...</div>
      <LoadingButton onClick={createGame}>Play First Game</LoadingButton>
    {:else}
      <GamePlayer game={currentGame} user={user.data} />
    {/if}
    <!-- <MermaidDiagram /> -->
  {/if}
</div>
