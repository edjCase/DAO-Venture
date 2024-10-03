<script lang="ts">
  import GamePlayer from "./game/GamePlayer.svelte";
  import { currentGameStore } from "../stores/CurrentGameStore";
  import { ChevronRightOutline } from "flowbite-svelte-icons";
  import LoadingButton from "./common/LoadingButton.svelte";
  import LoginButton from "./common/LoginButton.svelte";
  import { userStore } from "../stores/UserStore";
  import { mainAgentFactory } from "../ic-agent/Main";
  import { navigate } from "svelte-routing";
  import {
    GearSolid,
    ChevronRightSolid,
    HomeSolid,
  } from "flowbite-svelte-icons";
  import { Dropdown, DropdownItem, Button } from "flowbite-svelte";

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
  let cancelGame = async () => {
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.abandonGame();
    if ("ok" in result) {
      currentGameStore.refetch();
    } else {
      console.error("Failed to cancel game", result);
    }
  };
</script>

<div class="flex justify-between m-2">
  <HomeSolid on:click={() => navigate("/")} />
  <GearSolid />
  <Dropdown>
    <DropdownItem>
      <Button on:click={() => navigate("/game-overview")}>
        Game Help <ChevronRightSolid size="xs" class="ml-2" />
      </Button>
    </DropdownItem>
    {#if currentGame}
      <DropdownItem>
        <div class="flex justify-center">
          <LoadingButton color="red" onClick={cancelGame}>Forfeit</LoadingButton
          >
        </div>
      </DropdownItem>
    {/if}
  </Dropdown>
</div>
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
