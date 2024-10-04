<script lang="ts">
  import GamePlayer from "./game/GamePlayer.svelte";
  import { currentGameStore } from "../stores/CurrentGameStore";
  import { ChevronRightOutline } from "flowbite-svelte-icons";
  import LoadingButton from "./common/LoadingButton.svelte";
  import LoginButton from "./common/LoginButton.svelte";
  import { userStore } from "../stores/UserStore";
  import { mainAgentFactory } from "../ic-agent/Main";

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
</script>

<div class="text-center">
  {#if currentGame}
    <GamePlayer game={currentGame} />
  {:else}
    <div class="flex flex-col items-center justify-center h-full">
      {#if user}
        <LoadingButton onClick={createGame}>
          Play
          <ChevronRightOutline class="w-3 h-3 ml-1" />
        </LoadingButton>
      {:else}
        <LoginButton />
      {/if}
    </div>
  {/if}
</div>
