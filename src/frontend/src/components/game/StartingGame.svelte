<script lang="ts">
  import {
    GameWithMetaData,
    StartingGameStateWithMetaData,
  } from "../../ic-agent/declarations/main";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import GameNav from "./GameNav.svelte";
  import CharacterInventory from "../character/CharacterInventory.svelte";
  import CharacterAvatar from "../character/CharacterAvatar.svelte";
  import LoadingButton from "../common/LoadingButton.svelte";

  export let game: GameWithMetaData;
  export let state: StartingGameStateWithMetaData;

  let characterIndex: number | undefined = undefined;
  let selectCharacter = (id: number) => () => {
    characterIndex = id;
  };
  let confirm = async () => {
    if (characterIndex === undefined) {
      return;
    }
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.startGame({
      characterId: BigInt(characterIndex),
    });
    if ("ok" in result) {
      currentGameStore.refetch();
    } else {
      console.error("Failed start game", result, characterIndex);
    }
  };
</script>

<GameNav {game}>
  <div class="text-3xl">Pick Character</div>
  <div class="flex items-center">
    <div class="flex flex-col gap-2 justify-left box-border">
      {#each state.characterOptions as character, id}
        <button on:click={selectCharacter(id)}>
          <div class={characterIndex === id ? "bg-gray-600" : ""}>
            <CharacterAvatar {character} pixelSize={4} />
          </div>
        </button>
      {/each}
    </div>
    <div>
      {#if characterIndex !== undefined}
        {@const character = state.characterOptions[characterIndex]}
        <div class="text-3xl text-primary-500">
          {character.race.name}
          {character.class.name}
        </div>
        <div class="mb-4">
          {#if character.health > 100}
            <div>+{character.health - 100n} 🫀</div>
          {:else if character.health < 100}
            <div>-{100n - character.health} 🫀</div>
          {/if}
          {#if character.gold > 0}
            <div>+{character.gold} 🪙</div>
          {/if}
          <div class="text-xl text-primary-500">Actions</div>
          {#each character.actions as action}
            <div>+{action.action.name}</div>
          {/each}
          <div class="text-xl text-primary-500">Items</div>
          <div class="flex justify-center">
            <CharacterInventory value={character.inventorySlots} />
          </div>
        </div>
        <LoadingButton onClick={confirm}>Confirm</LoadingButton>
      {/if}
    </div>
  </div>
</GameNav>
