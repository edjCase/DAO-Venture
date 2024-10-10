<script lang="ts">
  import {
    CharacterWithMetaData,
    GameWithMetaData,
  } from "../../ic-agent/declarations/main";
  import CharacterInventory from "../character/CharacterInventory.svelte";
  import CharacterAvatarWithStats from "../character/CharacterAvatarWithStats.svelte";
  import {
    ArrowUpRightFromSquareOutline,
    ChevronDoubleUpOutline,
  } from "flowbite-svelte-icons";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { Button } from "flowbite-svelte";
  import LoadingButton from "../common/LoadingButton.svelte";
  import GenericBottomNavigation from "../common/GenericBottomNavigation.svelte";
  export let game: GameWithMetaData;

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

<div class="flex flex-col h-full pb-4">
  <div class="overflow-y-auto mt-4">
    <slot />
  </div>
  <div class="flex justify-between">
    <GenericBottomNavigation
      items={[]}
      drawerLocation="bottom"
      drawerIcon={ChevronDoubleUpOutline}
      hideOnClickOutside={false}
    >
      <div
        slot="side-content"
        class="flex flex-col items-center justify-center"
      >
        {#if character !== undefined}
          <div class="flex justify-around flex-grow flex-wrap">
            <div class="min-w-60">
              <CharacterAvatarWithStats
                {character}
                pixelSize={2}
                tooltips={true}
              />
            </div>
            <div class="flex flex-col items-center justify-center">
              Items
              <CharacterInventory value={character.inventorySlots} />
            </div>
          </div>
        {/if}
        <div class="flex items-center justify-end gap-2 mt-8 w-full">
          <Button href="/" target="_blank" color="light">
            Website
            <ArrowUpRightFromSquareOutline size="xs" class="ml-1" />
          </Button>
          <Button href="/game-overview" target="_blank" color="light">
            Help
            <ArrowUpRightFromSquareOutline size="xs" class="ml-1" />
          </Button>
          <LoadingButton color="red" onClick={cancelGame}>
            Forfeit
          </LoadingButton>
        </div>
      </div>
    </GenericBottomNavigation>
  </div>
</div>
