<script lang="ts">
  import WorldGrid from "./world/WorldGrid.svelte";
  import { currentGameStore } from "../stores/CurrentGameStore";
  import LoadingButton from "./common/LoadingButton.svelte";
  import { mainAgentFactory } from "../ic-agent/Main";
  import { userStore } from "../stores/UserStore";
  import {
    AddGameContentRequest,
    Difficulty,
    Trait,
  } from "../ic-agent/declarations/main";
  import LoginButton from "./common/LoginButton.svelte";

  interface ImageModule {
    default: string;
  }

  $: currentGame = $currentGameStore;
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

    await Promise.all(
      Object.keys(imageModules).map(async (path) => {
        const module = (await imageModules[path]()) as ImageModule;
        const response = await fetch(module.default);
        const data = await response.arrayBuffer();
        const id = path.split("/").pop()?.split(".").shift() || "";
        await addGameContent({
          image: { id: id, data: new Uint8Array(data), kind: { png: null } },
        });
      })
    );

    let traits = await import("../initial_data/TraitData").then((module) => {
      return module.traits;
    });
    await Promise.all(
      traits.map(async (trait: Trait) => {
        await addGameContent({ trait: trait });
      })
    );

    let items = await import("../initial_data/ItemData").then((module) => {
      return module.items;
    });
    await Promise.all(
      items.map(async (item) => {
        await addGameContent({ item: item });
      })
    );

    let classes = await import("../initial_data/ClassData").then((module) => {
      return module.classes;
    });
    await Promise.all(
      classes.map(async (classData) => {
        await addGameContent({ class: classData });
      })
    );

    let races = await import("../initial_data/RaceData").then((module) => {
      return module.races;
    });
    await Promise.all(
      races.map(async (race) => {
        await addGameContent({ race: race });
      })
    );

    let zones = await import("../initial_data/ZoneData").then((module) => {
      return module.zones;
    });
    await Promise.all(
      zones.map(async (zone) => {
        await addGameContent({ zone: zone });
      })
    );

    let scenarios = await import("../initial_data/ScenarioData").then(
      (module) => {
        return module.scenarios;
      }
    );
    await Promise.all(
      scenarios.map(async (scenario) => {
        await addGameContent({ scenario: scenario });
      })
    );
  };
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
    if (currentGame === undefined) {
      console.error("Game state not loaded");
      return;
    }
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.startGameVote({
      gameId: currentGame.id,
    });
    if ("ok" in result) {
      currentGameStore.refetch();
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
    if (currentGame === undefined) {
      console.error("Game state not loaded");
      return;
    }
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
      gameId: currentGame.id,
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

<div class="bg-gray-800 rounded p-2 text-center">
  {#if user?.worldData === undefined}
    <LoadingButton onClick={join}>Join</LoadingButton>
  {/if}
  <LoadingButton onClick={initialize}>Initialize Data</LoadingButton>
  {#if currentGame === undefined}
    {#if user !== undefined}
      <LoadingButton onClick={createGame}>Create New Game</LoadingButton>
    {:else}
      <LoginButton />
    {/if}
  {:else if "notStarted" in currentGame.state}
    <div>Invite Users</div>
    <div>Start Vote</div>
    <LoadingButton onClick={startGameVote}>Start Vote for Game</LoadingButton>
  {:else if "voting" in currentGame.state}
    <div class="text-3xl">Vote on next game</div>
    <div class="flex flex-col p-8">
      {#each currentGame.state.voting.characterOptions as character, id}
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
  {:else if "inProgress" in currentGame.state}
    <div>Turn: {currentGame.state.inProgress.turn}</div>
    <WorldGrid />
  {:else}
    <div>Game over</div>
    <div>Total Turns: {currentGame.state.completed.turns}</div>
    <div>Difficulty: {currentGame.state.completed.difficulty}</div>
  {/if}
  <!-- <MermaidDiagram /> -->
</div>
