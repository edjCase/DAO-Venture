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
  import CopyTextButton from "../common/CopyTextButton.svelte";
  import { Principal } from "@dfinity/principal";

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
  let kick = (guestUserId: Principal) => async () => {
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.kickPlayer({
      gameId: game.id,
      playerId: guestUserId,
    });
    if ("ok" in result) {
      currentGameStore.refetch();
    } else {
      console.error("Failed to kick user", result);
    }
  };

  $: inviteUrl = window.location.origin + "/join/" + game.id;
  $: isHost = game.hostUserId.toString() === user.id.toString();
</script>

<div
  class="bg-gray-800 rounded p-2 text-center flex flex-col items-center justify-center"
>
  {#if "notStarted" in game.state}
    <div class="border rounded p-6 mb-4 min-w-96">
      <div class="text-3xl text-primary-500">Lobby</div>
      <div class="flex items-center justify-center gap-1">
        <UserAvatar userId={game.hostUserId} size="xs" />
        <UserPseudonym userId={game.hostUserId} />
        (Host)
      </div>
      {#if game.guestUserIds.length > 0}
        {#each game.guestUserIds as guestUserId}
          <div class="flex items-center justify-center gap-1">
            <UserAvatar userId={guestUserId} size="xs" />
            <UserPseudonym userId={guestUserId} />
            {#if guestUserId.toString() === user.id.toString()}(You){/if}
            {#if isHost}
              <LoadingButton onClick={kick(guestUserId)}>Kick</LoadingButton>
            {/if}
          </div>
        {/each}
      {/if}
      <div class="text-xl text-primary-500 mt-4">Invite Url</div>
      <div class="flex items-center justify-center gap-2">
        <div>{inviteUrl}</div>
        <CopyTextButton value={inviteUrl} tooltip={false} />
      </div>
    </div>
    <LoadingButton onClick={startGameVote}>Start Game</LoadingButton>
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
