<script lang="ts">
  import {
    CharacterWithMetaData,
    GameWithMetaData,
    Scenario,
  } from "../../ic-agent/declarations/main";
  import LoadingButton from "../common/LoadingButton.svelte";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import { DotsVerticalOutline } from "flowbite-svelte-icons";
  import { Dropdown, DropdownItem, Toggle, Label } from "flowbite-svelte";
  import CharacterInventory from "../character/CharacterInventory.svelte";
  import ScenarioStages from "../scenario/ScenarioStages.svelte";
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
  let scenario: Scenario | undefined;
  $: {
    if ("inProgress" in game.state) {
      character = game.state.inProgress.character;
      scenario = undefined; // TODO
    } else if ("completed" in game.state) {
      character = game.state.completed.character;
      scenario = undefined;
    } else {
      character = undefined;
      scenario = undefined;
    }
  }

  let showStages = false;
</script>

<div>
  {#if character !== undefined}
    <CharacterInventory value={character.inventorySlots} />
  {/if}
  <DotsVerticalOutline class="dots-menu dark:text-white float-right " />
  <Dropdown triggeredBy=".dots-menu">
    <DropdownItem>
      <LoadingButton color="red" onClick={cancelGame}>Forfeit</LoadingButton>

      <div class="flex flex-col items-center">
        <Label>Show Stages</Label>
        <Toggle bind:checked={showStages} />
      </div>
    </DropdownItem>
  </Dropdown>
</div>
<slot />

{#if scenario !== undefined && showStages}
  <ScenarioStages stages={scenario.previousStages} />
{/if}
