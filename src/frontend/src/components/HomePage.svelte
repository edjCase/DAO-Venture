<script lang="ts">
  import WorldGrid from "./world/WorldGrid.svelte";
  import { gameStateStore } from "../stores/GameStateStore";
  import LoadingButton from "./common/LoadingButton.svelte";
  import { mainAgentFactory } from "../ic-agent/Main";
  import { userStore } from "../stores/UserStore";
  import {
    AddGameContentRequest,
    Difficulty,
  } from "../ic-agent/declarations/main";

  interface ImageModule {
    default: string;
  }

  $: gameState = $gameStateStore;
  $: user = $userStore;

  let initialize = async () => {
    let mainAgent = await mainAgentFactory();

    let addGameContent = async (content: AddGameContentRequest) => {
      let result = await mainAgent.addGameContent(content);
      if ("ok" in result) {
        console.log("Added content", content);
      } else {
        console.error("Failed to add content", content, result);
      }
    };

    let imageModules = import.meta.glob("../initial_data/images/*.png");
    for (const path in imageModules) {
      const module = (await imageModules[path]()) as ImageModule;
      const response = await fetch(module.default);
      const data = await response.arrayBuffer();
      const id = path.split("/").pop()?.split(".").shift() || "";
      await addGameContent({
        image: { id: id, data: new Uint8Array(data), kind: { png: null } },
      });
    }
    let traits = await import("../initial_data/TraitData").then((module) => {
      return module.traits;
    });
    for (let trait of traits) {
      await addGameContent({ trait: trait });
    }

    let items = await import("../initial_data/ItemData").then((module) => {
      return module.items;
    });
    for (let item of items) {
      await addGameContent({ item: item });
    }

    let result = await mainAgent.initialize();
    if ("ok" in result) {
      gameStateStore.refetch();
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
      characterId: BigInt(characterId),
      difficulty: difficulty,
    });
    if ("ok" in result) {
      gameStateStore.refetch();
    } else {
      console.error("Failed to vote", result);
    }
  };
</script>

<div class="bg-gray-800 rounded p-2 text-center">
  {#if user?.worldData === undefined}
    <LoadingButton onClick={join}>Join</LoadingButton>
  {/if}
  {#if gameState !== undefined}
    {#if "notInitialized" in gameState}
      <div>Game not initialized</div>
      <LoadingButton onClick={initialize}>Initialize</LoadingButton>
    {:else if "notStarted" in gameState}
      <div class="text-3xl">Vote on next game</div>
      <div class="flex flex-col p-8">
        {#each gameState.notStarted.characterOptions as character, id}
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
                {#if character.stats.attack > 0}
                  <div>+{character.stats.attack} ⚔️</div>
                {/if}
                {#if character.stats.defense > 0}
                  <div>+{character.stats.defense} 🛡️</div>
                {/if}
                {#if character.stats.speed > 0}
                  <div>+{character.stats.speed} 🏃</div>
                {/if}
                {#if character.stats.magic > 0}
                  <div>+{character.stats.magic} 🔮</div>
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
    {:else if "inProgress" in gameState}
      <div>Turn: {gameState.inProgress.turn}</div>
      <WorldGrid />
    {:else}
      <div>Game over</div>
      <div>Total Turns: {gameState.completed.turns}</div>
      <div>Difficulty: {gameState.completed.difficulty}</div>
    {/if}
  {/if}
</div>
