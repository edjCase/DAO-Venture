<script lang="ts">
  import {
    CharacterWithMetaData,
    RewardChoice,
    RewardScenarioState,
  } from "../../ic-agent/declarations/main";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import { scenarioStore } from "../../stores/ScenarioStore";
  import { toJsonString } from "../../utils/StringUtil";
  import CharacterInventorySlot from "../character/CharacterInventorySlot.svelte";
  import CharacterItem from "../character/CharacterItem.svelte";
  import CharacterStatIcon from "../character/CharacterStatIcon.svelte";
  import CharacterWeapon from "../character/CharacterWeapon.svelte";
  import LoadingButton from "../common/LoadingButton.svelte";

  export let rewardState: RewardScenarioState;
  export let character: CharacterWithMetaData;

  let selectedOptionIndex: number | undefined;
  let inventorySlot: number | undefined;

  $: firstEmptySlot = character.inventorySlots.findIndex(
    (item) => !item.item[0]
  );

  $: if (inventorySlot === undefined) {
    if (
      selectedOptionIndex !== undefined &&
      "item" in rewardState.options[selectedOptionIndex]
    ) {
      inventorySlot = firstEmptySlot !== -1 ? firstEmptySlot : undefined;
    } else {
      inventorySlot = undefined;
    }
  }

  let selectReward = async () => {
    if (selectedOptionIndex === undefined) {
      console.error("No option selected");
      return;
    }

    let selectedOption = rewardState.options[selectedOptionIndex];

    let rewardChoice: RewardChoice;
    if ("gold" in selectedOption) {
      rewardChoice = {
        gold: selectedOption.gold,
      };
    } else if ("item" in selectedOption) {
      if (inventorySlot === undefined) {
        console.error("No inventory slot selected");
        return;
      }
      rewardChoice = {
        item: {
          id: selectedOption.item,
          inventorySlot: BigInt(inventorySlot),
        },
      };
    } else if ("weapon" in selectedOption) {
      rewardChoice = {
        weapon: selectedOption.weapon,
      };
    } else if ("health" in selectedOption) {
      rewardChoice = {
        health: selectedOption.health,
      };
    } else {
      console.error("Invalid reward choice:", selectedOption);
      return;
    }

    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.selectScenarioChoice({
      choice: {
        reward: rewardChoice,
      },
    });

    if ("ok" in result) {
      scenarioStore.refetch();
      currentGameStore.refetch();
      selectedOptionIndex = undefined;
      inventorySlot = undefined;
    } else {
      console.error("Failed to select reward:", result);
    }
  };

  let selectInventorySlot = (index: number) => () => {
    inventorySlot = index;
  };

  let selectOption = (index: number) => () => {
    selectedOptionIndex = index;
  };
</script>

<div class="p-4">
  <h2 class="text-2xl font-bold mb-4">Select Your Reward</h2>
  <div class="grid grid-cols-3 gap-4">
    {#each rewardState.options as option, index}
      <div
        class="border rounded-lg p-4 cursor-pointer transition-colors duration-200 {selectedOptionIndex ===
        index
          ? 'bg-gray-700 border-blue-500'
          : 'hover:bg-gray-900'}"
        on:click={selectOption(index)}
        on:keypress={selectOption(index)}
        tabindex={index}
        role="button"
      >
        {#if "gold" in option}
          {option.gold} <CharacterStatIcon kind={{ gold: null }} />
        {:else if "item" in option}
          <CharacterItem item={option.item} />
        {:else if "weapon" in option}
          <CharacterWeapon value={option.weapon} />
        {:else if "health" in option}
          <div class="text-xl font-semibold">
            {option.health}
            <CharacterStatIcon kind={{ health: null }} />
          </div>
        {:else}
          NOT IMPLEMENTED REWARD OPTION {toJsonString(option)}
        {/if}
      </div>
    {/each}
  </div>

  {#if selectedOptionIndex !== undefined && "item" in rewardState.options[selectedOptionIndex]}
    <div class="mt-6">
      <h3 class="text-xl font-semibold mb-2">Select Inventory Slot</h3>
      <div class="grid grid-cols-5 gap-2">
        {#each character.inventorySlots as slot, i}
          <div
            class="w-16 h-16 border rounded flex items-center justify-center cursor-pointer {inventorySlot ===
            i
              ? 'border-blue-500 bg-gray-700'
              : 'hover:bg-gray-900'}"
            on:click={selectInventorySlot(i)}
            role="button"
            tabindex={i}
            on:keypress={selectInventorySlot(i)}
          >
            <CharacterInventorySlot value={slot} />
          </div>
        {/each}
      </div>
    </div>
  {/if}

  <LoadingButton onClick={selectReward}>Claim Reward</LoadingButton>
</div>
