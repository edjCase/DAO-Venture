<script lang="ts">
  import {
    CharacterWithMetaData,
    GameWithMetaData,
  } from "../../ic-agent/declarations/main";
  import LoadingButton from "../common/LoadingButton.svelte";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import { GearSolid } from "flowbite-svelte-icons";
  import { Dropdown, DropdownItem } from "flowbite-svelte";
  import CharacterInventory from "../character/CharacterInventory.svelte";
  import CharacterAvatarWithStats from "../character/CharacterAvatarWithStats.svelte";
  export let game: GameWithMetaData;

  let cancelGame = async () => {
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.abandonGame();
    if ("ok" in result) {
      currentGameStore.refetch();
    } else {
      console.error("Failed to cancel game", result);
    }
  };

  let character: CharacterWithMetaData | undefined;
  $: {
    if ("inProgress" in game.state) {
      character = game.state.inProgress.character;
    } else if ("completed" in game.state) {
      character = game.state.completed.character;
    } else {
      character = undefined;
    }
  }
</script>

<div class="flex justify-between">
  <div class="flex justify-around flex-grow">
    {#if character !== undefined}
      <div>
        <CharacterAvatarWithStats {character} pixelSize={2} tooltips={true} />
      </div>
      <div class="flex flex-col items-center justify-center">
        Items
        <CharacterInventory value={character.inventorySlots} />
      </div>
    {/if}
  </div>
  <div class="mr-4">
    <GearSolid />
    <Dropdown>
      <DropdownItem>
        <LoadingButton color="red" onClick={cancelGame}>Forfeit</LoadingButton>
      </DropdownItem>
    </Dropdown>
  </div>
</div>
<slot />
