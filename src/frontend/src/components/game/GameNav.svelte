<script lang="ts">
  import { Principal } from "@dfinity/principal";
  import {
    CharacterWithMetaData,
    GameWithMetaData,
    User,
  } from "../../ic-agent/declarations/main";
  import LoadingButton from "../common/LoadingButton.svelte";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import { DotsVerticalOutline } from "flowbite-svelte-icons";
  import { Dropdown, DropdownItem } from "flowbite-svelte";
  import CharacterInventory from "../character/CharacterInventory.svelte";
  import CharacterTraits from "../character/CharacterTraits.svelte";
  export let game: GameWithMetaData;
  export let user: User;

  $: isHost = game.hostUserId.toString() === user.id.toString();

  let cancelGame = async () => {
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.abandonGame(game.id);
    if ("ok" in result) {
      currentGameStore.refetch();
    } else {
      console.error("Failed to cancel game", result);
    }
  };

  let kick = (guestUserId: Principal) => async () => {
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.kickPlayer({
      gameId: game.id,
      playerId: guestUserId,
    });
    if ("ok" in result) {
      currentGameStore.refetch();
    } else {
      console.error("Failed to kick user", result);
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
      {#if isHost}
        <LoadingButton color="red" onClick={cancelGame}>
          Cancel Game
        </LoadingButton>
      {:else}
        <LoadingButton color="red" onClick={kick(user.id)}>Leave</LoadingButton>
      {/if}
    </DropdownItem>
  </Dropdown>
</div>
<slot />
