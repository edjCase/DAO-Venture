<script lang="ts">
  import { currentGameStore } from "../stores/CurrentGameStore";
  import LoadingButton from "./common/LoadingButton.svelte";
  import { mainAgentFactory } from "../ic-agent/Main";
  import { userStore } from "../stores/UserStore";
  import InitialDataLoad from "./game/InitialDataLoad.svelte";
  import GamePlayer from "./game/GamePlayer.svelte";
  import OverviewPage from "./OverviewPage.svelte";

  $: currentGame = $currentGameStore;
  $: user = $userStore;

  let createGame = async () => {
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.createGame({});
    if ("ok" in result) {
      currentGameStore.refetch();
    } else {
      console.error("Failed to create game", result);
    }
  };
  let login = async () => {
    await userStore.login();
  };
</script>

<div class="bg-gray-800 rounded p-2 py-8 text-center">
  <!-- <ImageToPixelArt width={32} height={32} pixelSize={10} previewPixelSize={2} /> -->
  {#if currentGame === undefined}
    <InitialDataLoad />
    <OverviewPage />
    {#if user !== undefined}
      <LoadingButton onClick={createGame}>Play First Game</LoadingButton>
    {:else}
      <section class="py-8">
        <h2 class="text-xl font-bold mb-4">Join the Quest</h2>
        <p class="mb-4">
          Ready to start your adventure? Login now and become part of the
          legend!
        </p>
        <LoadingButton onClick={login}>Join</LoadingButton>
      </section>
    {/if}
  {:else}
    <GamePlayer game={currentGame} />
  {/if}
</div>
