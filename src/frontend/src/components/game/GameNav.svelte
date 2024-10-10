<script lang="ts">
  import {
    CharacterWithMetaData,
    GameWithMetaData,
  } from "../../ic-agent/declarations/main";
  import CharacterInventory from "../character/CharacterInventory.svelte";
  import CharacterAvatarWithStats from "../character/CharacterAvatarWithStats.svelte";
  import { HomeSolid } from "flowbite-svelte-icons";
  import { navigate } from "svelte-routing";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import GenericBottomNavigation, {
    Item,
  } from "../common/GenericBottomNavigation.svelte";
  import QuestionCircleOutline from "flowbite-svelte-icons/QuestionCircleOutline.svelte";
  import XCircleOutline from "flowbite-svelte-icons/XCircleOutline.svelte";
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

  let items: Item[] = [];
  let drawerItems: Item[] = [
    { label: "Home", href: "/", icon: HomeSolid, onClick: () => navigate("/") },
    {
      label: "Game Help",
      href: "/game-overview",
      icon: QuestionCircleOutline,
      onClick: () => navigate("/game-overview"),
    },
    {
      label: "Forfeit",
      href: undefined,
      icon: XCircleOutline,
      onClick: cancelGame,
    },
  ];
</script>

<div class="flex flex-col h-screen">
  <div class="overflow-y-auto mt-4">
    <slot />
  </div>
  <div class="flex justify-between">
    <GenericBottomNavigation {items} {drawerItems} />
    {#if character !== undefined}
      <div class="flex justify-around flex-grow flex-wrap">
        <div class="min-w-60">
          <CharacterAvatarWithStats {character} pixelSize={2} tooltips={true} />
        </div>
        <div class="flex flex-col items-center justify-center">
          Items
          <CharacterInventory value={character.inventorySlots} />
        </div>
      </div>
    {/if}
  </div>
</div>
