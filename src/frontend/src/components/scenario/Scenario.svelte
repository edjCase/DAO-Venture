<script lang="ts">
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import ScenarioOption from "./ScenarioOption.svelte";
  import { Hr } from "flowbite-svelte";
  import { toJsonString } from "../../utils/StringUtil";
  import {
    CharacterWithMetaData,
    Scenario,
  } from "../../ic-agent/declarations/main";
  import ScenarioCombat from "./ScenarioCombat.svelte";
  import ScenarioReward from "./ScenarioReward.svelte";
  import { decodeImageToPixels } from "../../utils/PixelUtil";
  import PixelArtCanvas from "../common/PixelArtCanvas.svelte";
  import ScenarioStages from "./ScenarioStages.svelte";
  import { scenarioMetaDataStore } from "../../stores/ScenarioMetaDataStore";

  export let scenario: Scenario;
  export let character: CharacterWithMetaData;

  let selectChoice = (optionId: string) => async () => {
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.selectScenarioChoice({
      choice: {
        choice: optionId,
      },
    });
    if ("ok" in result) {
      currentGameStore.refetch();
    } else {
      console.error("Failed select choice:", result, optionId);
    }
  };

  $: metaDataList = $scenarioMetaDataStore;
  $: metaData = metaDataList?.find((meta) => meta.id === scenario.metaDataId);
</script>

<div class="text-center">
  {#if "choice" in scenario.currentStage}
    <div class="text-4xl font-semibold mb-4 text-primary-500">
      {metaData?.name}
    </div>
    <div class="flex justify-center">
      {#if metaData?.image}
        <PixelArtCanvas
          layers={[decodeImageToPixels(metaData.image, 64, 64)]}
          pixelSize={4}
        />
      {/if}
    </div>
    <div class="text-xl my-6">
      {metaData?.description}
    </div>
    <div class="flex flex-col items-center gap-2">
      <div>
        <div>Options</div>
        <ul class="text-lg p-6">
          {#each scenario.currentStage.choice.choices as option}
            <li>
              <ScenarioOption {option} onSelect={selectChoice(option.id)} />
            </li>
          {/each}
        </ul>
      </div>
    </div>
  {:else if "combat" in scenario.currentStage}
    <div class="text-3xl text-center mb-4">Combat</div>
    <ScenarioCombat combatState={scenario.currentStage.combat} />
  {:else if "reward" in scenario.currentStage}
    <ScenarioReward rewardState={scenario.currentStage.reward} {character} />
  {:else}
    NOT IMPLEMENTED SCENARIO STATE 2 {toJsonString(scenario.currentStage)}
  {/if}

  {#if scenario.previousStages.length > 0}
    <Hr />
    <div class="text-4xl text-primary-500 mb-2">Scenario Log</div>
    <ScenarioStages stages={scenario.previousStages} />
    {metaData?.description}
  {/if}
</div>
