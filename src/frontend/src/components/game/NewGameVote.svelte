<script lang="ts">
  import {
    VotingSummary,
    CharacterWithMetaData,
    VotingSummary_1,
    Difficulty,
  } from "../../ic-agent/declarations/main";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import LoadingButton from "../common/LoadingButton.svelte";

  export let gameId: bigint;
  export let state: {
    characterVotes: VotingSummary;
    characterOptions: Array<CharacterWithMetaData>;
    difficultyVotes: VotingSummary_1;
  };

  let characterId: number | undefined = undefined;
  let difficulty: Difficulty | undefined = undefined;
  let vote = async () => {
    if (characterId === undefined) {
      console.error("Character not selected");
      return;
    }
    if (difficulty === undefined) {
      console.error("Difficulty not selected");
      return;
    }
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.voteOnNewGame({
      gameId: gameId,
      characterId: BigInt(characterId),
      difficulty: difficulty,
    });
    if ("ok" in result) {
      currentGameStore.refetch();
    } else {
      console.error("Failed to vote", result);
    }
  };
</script>

<div class="text-3xl">Vote on next game</div>
<div class="flex flex-col p-8">
  {#each state.characterOptions as character, id}
    <button
      on:click={() => {
        characterId = id;
      }}
    >
      <div
        class="border rounded p-4 mb-4 w-full {characterId == id
          ? 'bg-gray-700'
          : ''}"
      >
        <div class="text-2xl">
          {character.race.name}
          {character.class.name}
        </div>
        <div>
          {#if character.health > 100}
            <div>+{character.health - 100n} 🫀</div>
          {:else if character.health < 100}
            <div>-{100n - character.health} 🫀</div>
          {/if}
          {#if character.gold > 0}
            <div>+{character.gold} 🪙</div>
          {/if}
          {#if character.attack > 0}
            <div>+{character.attack} ⚔️</div>
          {/if}
          {#if character.defense > 0}
            <div>+{character.defense} 🛡️</div>
          {/if}
          {#if character.speed > 0}
            <div>+{character.speed} 🏃</div>
          {/if}
          {#if character.magic > 0}
            <div>+{character.magic} 🔮</div>
          {/if}
          {#each character.traits as trait}
            <div>+{trait.name}</div>
          {/each}
          {#each character.items as item}
            <div>+{item.name}</div>
          {/each}
        </div>
      </div>
    </button>
  {/each}
</div>
<div>
  <button
    on:click={() => {
      difficulty = { easy: null };
    }}
  >
    <div
      class="border rounded p-4 mb-4 w-full {difficulty !== undefined &&
      'easy' in difficulty
        ? 'bg-gray-700'
        : ''}"
    >
      Easy
    </div>
  </button>
  <button
    on:click={() => {
      difficulty = { medium: null };
    }}
  >
    <div
      class="border rounded p-4 mb-4 w-full {difficulty !== undefined &&
      'medium' in difficulty
        ? 'bg-gray-700'
        : ''}"
    >
      Medium
    </div>
  </button>
  <button
    on:click={() => {
      difficulty = { hard: null };
    }}
  >
    <div
      class="border rounded p-4 mb-4 w-full {difficulty !== undefined &&
      'hard' in difficulty
        ? 'bg-gray-700'
        : ''}"
    >
      Hard
    </div>
  </button>
</div>
<LoadingButton onClick={vote}>Vote</LoadingButton>
