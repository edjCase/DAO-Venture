<script lang="ts">
  import {
    CharacterWithMetaData,
    GameWithMetaData,
  } from "../../ic-agent/declarations/main";
  import CharacterInventory from "../character/CharacterInventory.svelte";
  import CharacterAvatarWithStats from "../character/CharacterAvatarWithStats.svelte";
  import { Dropdown, DropdownItem, Button } from "flowbite-svelte";
  import {
    HomeSolid,
    GearSolid,
    ChevronRightSolid,
  } from "flowbite-svelte-icons";
  import { navigate } from "svelte-routing";
  import LoadingButton from "../common/LoadingButton.svelte";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import { mainAgentFactory } from "../../ic-agent/Main";
  export let game: GameWithMetaData;

  $: currentGame = $currentGameStore;

  let character: CharacterWithMetaData | undefined;
  $: {
    if ("inProgress" in game.state) {
      character = game.state.inProgress.character;
    } else if ("completed" in game.state) {
      if ("forfeit" in game.state.completed.outcome) {
        character = game.state.completed.outcome.forfeit.character[0];
      } else if ("victory" in game.state.completed.outcome) {
        character = game.state.completed.outcome.victory.character;
      } else if ("death" in game.state.completed.outcome) {
        character = game.state.completed.outcome.death.character;
      } else {
        character = undefined;
      }
    } else {
      character = undefined;
    }
  }

  let cancelGame = async () => {
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.abandonGame();
    if ("ok" in result) {
      currentGameStore.refetch();
    } else {
      console.error("Failed to cancel game", result);
    }
  };
</script>

<div class="flex flex-col h-screen">
  <div class="flex justify-between border-b-2 pb-2">
    <div class="flex justify-around flex-grow flex-wrap">
      {#if character !== undefined}
        <div class="min-w-60">
          <CharacterAvatarWithStats {character} pixelSize={2} tooltips={true} />
        </div>
        <div class="flex flex-col items-center justify-center">
          Items
          <CharacterInventory value={character.inventorySlots} />
        </div>
      {/if}
    </div>
  </div>
  <div class="overflow-y-auto">
    <div class="flex justify-between m-2">
      <HomeSolid on:click={() => navigate("/")} />
      <GearSolid />
      <Dropdown>
        <DropdownItem>
          <Button on:click={() => navigate("/game-overview")}>
            Game Help <ChevronRightSolid size="xs" class="ml-2" />
          </Button>
        </DropdownItem>
        {#if currentGame}
          <DropdownItem>
            <div class="flex justify-center">
              <LoadingButton color="red" onClick={cancelGame}>
                Forfeit
              </LoadingButton>
            </div>
          </DropdownItem>
        {/if}
      </Dropdown>
    </div>
    <slot />
  </div>
</div>
