<script lang="ts">
  import { mainAgentFactory } from "../ic-agent/Main";
  import { navigate } from "svelte-routing";
  import { toJsonString } from "../utils/StringUtil";
  import { currentGameStore } from "../stores/CurrentGameStore";
  import { userStore } from "../stores/UserStore";

  export let gameIdString: string;

  $: user = $userStore;

  type State = { loading: null } | { error: string };

  let state: State = {
    loading: null,
  };

  $: user && joinGame(); // join game when user is logged in

  async function joinGame() {
    if (!gameIdString) {
      state = { error: "No game id provided" };
      return;
    }
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
    console.log(`Joining game`, gameId);
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.joinGame({ gameId: gameId });
    if ("ok" in result) {
      console.log("Joined game", gameId);
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
      } else if ("notRegistered" in result.err) {
        reason = "You are not registered";
      } else {
        reason = toJsonString(result.err);
      }
      state = { error: "Failed to join game: " + reason };
    }
  }
</script>

<div class="text-center text-xl">
  {#if user === undefined}
    <div>You need to login to join a game</div>
  {:else if "loading" in state}
    Attempting to join game...
  {:else}
    {state.error}
  {/if}
</div>
