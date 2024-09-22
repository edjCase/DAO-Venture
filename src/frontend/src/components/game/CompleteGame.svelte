<script lang="ts">
  import { CompletedGameStateWithMetaData } from "../../ic-agent/declarations/main";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import LoadingButton from "../common/LoadingButton.svelte";

  export let state: CompletedGameStateWithMetaData;

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

<div>Game over</div>
<div>Victory: {state.victory}</div>

<LoadingButton onClick={createGame}>Create New Game</LoadingButton>
