<script lang="ts">
  import { onMount } from "svelte";
  import { mainAgentFactory } from "../ic-agent/Main";
  import { navigate } from "svelte-routing";
  import { toJsonString } from "../utils/StringUtil";
  import { currentGameStore } from "../stores/CurrentGameStore";

  export let gameIdString: string;

  type State = { loading: null } | { error: string };

  let state: State = {
    loading: null,
  };

  onMount(() => {
    if (!gameIdString) {
      state = { error: "No game id provided" };
    } else {
      let gameId: bigint | undefined;
      try {
        const parsed = parseInt(gameIdString);
        if (!isNaN(parsed)) {
          gameId = BigInt(parsed);
        }
      } catch {
        gameId = undefined;
      }
      if (gameId === undefined) {
        state = { error: "Invalid game id: " + gameIdString };
        return;
      }
      joinGame(gameId);
    }
  });

  async function joinGame(id: bigint) {
    console.log(`Joining game`, id);
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.joinGame({ gameId: id });
    if ("ok" in result) {
      console.log("Joined game", id);
      await currentGameStore.refetch();
      navigate(`/`);
    } else {
      let reason: string;
      if ("alreadyJoined" in result.err) {
        reason = "You have already joined this game";
        await currentGameStore.refetch();
        navigate(`/`);
        return;
      } else if ("gameNotFound" in result.err) {
        reason = "Game not found";
      } else if ("lobbyClosed" in result.err) {
        reason = "Lobby is closed";
      } else {
        reason = toJsonString(result.err);
      }
      state = { error: "Failed to join game: " + result.err };
    }
  }
</script>

<div class="text-center text-xl">
  {#if "loading" in state}
    Attempting to join game...
  {:else}
    {state.error}
  {/if}
</div>
