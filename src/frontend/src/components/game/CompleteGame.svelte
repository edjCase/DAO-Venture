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

  let endGame = async () => {
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.abandonGame();
    if ("ok" in result) {
      currentGameStore.refetch();
    } else {
      console.error("Failed to create game", result);
    }
  };
  let achievements: Achievement[] = [];
</script>

{#if "victory" in state.outcome}
  YOU WON
  <CharacterAvatarWithStats
    character={state.outcome.victory.character}
    pixelSize={4}
  />
{:else if "forfeit" in state.outcome}
  YOU FORFEITED
  {#if state.outcome.forfeit.character[0] !== undefined}
    <CharacterAvatarWithStats
      character={state.outcome.forfeit.character[0]}
      pixelSize={4}
    />
  {/if}
{:else if "death" in state.outcome}
  YOU DIED
  <CharacterAvatarWithStats
    character={state.outcome.death.character}
    pixelSize={4}
  />
{/if}

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

<LoadingButton onClick={endGame}>End Game</LoadingButton>
