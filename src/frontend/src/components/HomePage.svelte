<script lang="ts">
  import WorldGrid from "./world/WorldGrid.svelte";
  import { currentGameStore } from "../stores/CurrentGameStore";
  import LoadingButton from "./common/LoadingButton.svelte";
  import { mainAgentFactory } from "../ic-agent/Main";
  import { userStore } from "../stores/UserStore";
  import LoginButton from "./common/LoginButton.svelte";
  import Difficulty from "./common/Difficulty.svelte";
  import NewGameVote from "./game/NewGameVote.svelte";
  import InitialDataLoad from "./game/InitialDataLoad.svelte";
  import GameHistory from "./game/GameHistory.svelte";
  import PixelArtEditor from "./common/PixelArtEditor.svelte";

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

  let startGameVote = async () => {
    if (currentGame === undefined) {
      console.error("Game state not loaded");
      return;
    }
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.startGameVote({
      gameId: currentGame.id,
    });
    if ("ok" in result) {
      currentGameStore.refetch();
    } else {
      console.error("Failed to start game", result);
    }
  };

  let join = async () => {
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.join();
    if ("ok" in result) {
      userStore.refetchCurrentUser();
    } else {
      console.error("Failed to join game", result);
    }
  };
  let pixels: { red: number; green: number; blue: number }[][] = Array.from(
    { length: 16 },
    () => Array.from({ length: 16 }, () => ({ red: 0, green: 0, blue: 0 }))
  );
</script>

<div class="bg-gray-800 rounded p-2 pt-8 text-center">
  {#if user?.worldData === undefined}
    <LoadingButton onClick={join}>Join</LoadingButton>
  {/if}
  {#if currentGame === undefined}
    <InitialDataLoad />
    {#if user !== undefined}
      <LoadingButton onClick={createGame}>Create New Game</LoadingButton>
      <GameHistory />
    {:else}
      <LoginButton />
    {/if}
  {:else if "notStarted" in currentGame.state}
    <div>Invite Users</div>
    <div>Start Vote</div>
    <LoadingButton onClick={startGameVote}>Start Vote for Game</LoadingButton>
  {:else if "voting" in currentGame.state}
    <NewGameVote gameId={currentGame.id} state={currentGame.state.voting} />
  {:else if "inProgress" in currentGame.state}
    <WorldGrid />
  {:else}
    <div>Game over</div>
    <div>Total Turns: {currentGame.state.completed.turns}</div>
    <div>
      Difficulty: <Difficulty value={currentGame.state.completed.difficulty} />
    </div>

    <LoadingButton onClick={createGame}>Create New Game</LoadingButton>
  {/if}
  <!-- <MermaidDiagram /> -->
  <PixelArtEditor {pixels} />
</div>
