<script lang="ts">
  import {
    CharacterWithMetaData,
    GameWithMetaData,
  } from "../../ic-agent/declarations/main";
  import LoadingButton from "../common/LoadingButton.svelte";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import { DotsVerticalOutline } from "flowbite-svelte-icons";
  import { Dropdown, DropdownItem } from "flowbite-svelte";
  import CharacterInventory from "../character/CharacterInventory.svelte";
  import CharacterTraits from "../character/CharacterTraits.svelte";
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

<div>
  {#if character !== undefined}
    <CharacterInventory items={character.items} />
    <CharacterTraits traits={character.traits} />
  {/if}
  <DotsVerticalOutline class="dots-menu dark:text-white float-right " />
  <Dropdown triggeredBy=".dots-menu">
    <DropdownItem>
      <LoadingButton color="red" onClick={cancelGame}>
        Cancel Game
      </LoadingButton>
    </DropdownItem>
  </Dropdown>
</div>
<slot />
