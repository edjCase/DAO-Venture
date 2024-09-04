<script lang="ts">
  import {
    CompletedGameStateWithMetaData,
    Difficulty,
    GameWithMetaData,
  } from "../../ic-agent/declarations/main";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import LoadingButton from "../common/LoadingButton.svelte";
  import DifficultyChooser from "./DifficultyChooser.svelte";

  export let game: GameWithMetaData;
  export let state: CompletedGameStateWithMetaData;

  let difficulty: Difficulty = game.difficulty;

  let createGame = async () => {
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.createGame({
      difficulty: difficulty,
    });
    if ("ok" in result) {
      currentGameStore.refetch();
    } else {
      console.error("Failed to create game", result);
    }
  };
</script>

<div>Game over</div>

<DifficultyChooser bind:value={difficulty} />
<LoadingButton onClick={createGame}>Create New Game</LoadingButton>
