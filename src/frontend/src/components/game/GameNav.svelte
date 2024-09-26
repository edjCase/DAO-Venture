<script lang="ts">
  import {
    CharacterWithMetaData,
    GameWithMetaData,
    Scenario,
  } from "../../ic-agent/declarations/main";
  import LoadingButton from "../common/LoadingButton.svelte";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import { GearSolid } from "flowbite-svelte-icons";
  import { Dropdown, DropdownItem, Toggle, Label } from "flowbite-svelte";
  import CharacterInventory from "../character/CharacterInventory.svelte";
  import ScenarioStages from "../scenario/ScenarioStages.svelte";
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

<div class="flex justify-between">
  <div class="flex justify-around flex-grow">
    {#if character !== undefined}
      <div>
        <CharacterAvatarWithStats {character} pixelSize={2} />
      </div>
      <div class="flex flex-col items-center justify-center">
        Items
        <CharacterInventory value={character.inventorySlots} />
      </div>
    {/if}
  </div>
  <div class="mr-4">
    <GearSolid />
  </div>
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
