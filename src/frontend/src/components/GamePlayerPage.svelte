<script lang="ts">
  import GamePlayer from "./game/GamePlayer.svelte";
  import { currentGameStore } from "../stores/CurrentGameStore";
  import { PlaySolid } from "flowbite-svelte-icons";
  import LoadingButton from "./common/LoadingButton.svelte";
  import LoginButton from "./common/LoginButton.svelte";
  import { userStore } from "../stores/UserStore";
  import { mainAgentFactory } from "../ic-agent/Main";
  import { Button } from "flowbite-svelte";
  import { navigate } from "svelte-routing";
  import UserAvatar from "./user/UserAvatar.svelte";
  import UserPseudonym from "./user/UserPseudonym.svelte";

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

<div class="text-center h-full">
  {#if user}
    <div class="flex flex-col items-center justify-center">
      <div class="flex items-center gap-2">
        <UserAvatar userId={user.id} />
        <UserPseudonym userId={user.id} />
        <LoginButton />
      </div>
    </div>
  {/if}
  {#if currentGame}
    <GamePlayer game={currentGame} />
  {:else}
    <div class="flex flex-col items-center justify-center h-full">
      <div class="text-6xl font-semibold mb-4 text-primary-500">DAOVenture</div>
      {#if user}
        <LoadingButton
          onClick={createGame}
          class="rounded-full border-2 border-primary-500 p-6 flex items-center gap-2 mb-4"
        >
          <span class="text-2xl">Play</span>
          <PlaySolid class="w-5 h-5 mb-1" />
        </LoadingButton>
        <Button on:click={() => navigate("/")} color="red">
          <span>Exit</span>
        </Button>
      {:else}
        <LoginButton />
      {/if}
    </div>
  {/if}
</div>
