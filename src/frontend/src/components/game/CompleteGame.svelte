<script lang="ts">
  import {
    Achievement,
    CompletedGameStateWithMetaData,
  } from "../../ic-agent/declarations/main";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import CharacterAvatarWithStats from "../character/CharacterAvatarWithStats.svelte";
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
  let achievements: Achievement[] = [];
</script>

{#if state.victory}
  YOU WON
{:else}
  YOUR ADVENTURE CAME TO A HORRIBLE END
{/if}
<CharacterAvatarWithStats character={state.character} pixelSize={4} />

<div>
  <div>Achievements</div>
  {#if achievements.length > 0}
    {#each achievements as achievement}
      <div>{achievement.name}</div>
    {/each}
  {:else}
    None
  {/if}
</div>

<LoadingButton onClick={createGame}>Create New Game</LoadingButton>
