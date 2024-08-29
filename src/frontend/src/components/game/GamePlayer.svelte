<script lang="ts">
  import WorldGrid from "../world/WorldGrid.svelte";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import LoadingButton from "../common/LoadingButton.svelte";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import Difficulty from "../common/Difficulty.svelte";
  import NewGameVote from "./NewGameVote.svelte";
  import { GameWithMetaData, User } from "../../ic-agent/declarations/main";
  import UserAvatar from "../user/UserAvatar.svelte";
  import UserPseudonym from "../user/UserPseudonym.svelte";
  import { PlusSolid } from "flowbite-svelte-icons";
  import { Button } from "flowbite-svelte";

  export let game: GameWithMetaData;
  export let user: User;

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
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.startGameVote({
      gameId: game.id,
    });
    if ("ok" in result) {
      currentGameStore.refetch();
    } else {
      console.error("Failed to start game", result);
    }
  };
</script>

<div
  class="bg-gray-800 rounded p-2 pt-8 text-center flex flex-col items-center justify-center"
>
  {#if "notStarted" in game.state}
    <div class="border rounded w-48 p-6">
      <div>Lobby</div>
      <div>
        <UserAvatar userId={game.hostUserId} size="xs" />
        <UserPseudonym userId={game.hostUserId} />
        (Host)
      </div>
      {#if game.guestUserIds.length > 0}
        <div>Guests</div>
        {#each game.guestUserIds as guestUserId}
          <div><UserAvatar userId={guestUserId} size="xs" /></div>
        {/each}
      {/if}
      <div class="flex items-center justify-center gap-2">
        Invite Users
        <Button><PlusSolid size="xs" /></Button>
      </div>
    </div>
    <div>Start Vote</div>
    <LoadingButton onClick={startGameVote}>Start Vote for Game</LoadingButton>
  {:else if "voting" in game.state}
    <NewGameVote gameId={game.id} state={game.state.voting} />
  {:else if "inProgress" in game.state}
    <WorldGrid />
  {:else}
    <div>Game over</div>
    <div>Total Turns: {game.state.completed.turns}</div>
    <div>
      Difficulty: <Difficulty value={game.state.completed.difficulty} />
    </div>

    <LoadingButton onClick={createGame}>Create New Game</LoadingButton>
  {/if}
  <!-- <MermaidDiagram /> -->
</div>
