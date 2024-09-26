<script lang="ts">
  import { scenarioStore } from "../../stores/ScenarioStore";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import ScenarioOption from "./ScenarioOption.svelte";
  import { Button, Hr } from "flowbite-svelte";
  import { onDestroy, onMount } from "svelte";
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

  export let scenario: Scenario;
  export let character: CharacterWithMetaData;
  export let nextScenario: () => void;

  let selectChoice = async (optionId: string) => {
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.selectScenarioChoice({
      choice: {
        choice: optionId,
      },
    });
    if ("ok" in result) {
      console.log("Voted successfully");
      scenarioStore.refetch();
      currentGameStore.refetch();
    } else {
      console.error("Failed select choice:", result, optionId);
    }
  };
  let intervalId: NodeJS.Timeout | undefined;
  onMount(() => {
    intervalId = setInterval(() => {
      // Get the updated vote
      scenarioStore.refetch();
    }, 3000);
  });

  onDestroy(() => {
    if (intervalId) {
      clearInterval(intervalId);
    }
  });
</script>

<div class="">
  {#if "inProgress" in scenario.state}
    {#if "choice" in scenario.state.inProgress}
      <div class="text-4xl font-semibold text-center mb-4 text-primary-500">
        {scenario.metaData.name}
      </div>
      <div class="flex justify-center">
        <PixelArtCanvas
          layers={[decodeImageToPixels(scenario.metaData.image, 64, 64)]}
          pixelSize={4}
        />
      </div>
      <div class="text-xl my-6">
        {scenario.metaData.description}
      </div>
      <div class="flex flex-col items-center gap-2">
        <div>
          <div>Options</div>
          <ul class="text-lg p-6">
            {#each scenario.state.inProgress.choice.choices as option}
              <li>
                <ScenarioOption
                  {option}
                  selected={false}
                  onSelect={selectChoice}
                />
              </li>
            {/each}
          </ul>
        </div>
      </div>
    {:else if "combat" in scenario.state.inProgress}
      <div class="text-3xl text-center mb-4">Combat</div>
      <ScenarioCombat combatState={scenario.state.inProgress.combat} />
    {:else if "reward" in scenario.state.inProgress}
      <ScenarioReward
        rewardState={scenario.state.inProgress.reward}
        {character}
      />
    {:else}
      NOT IMPLEMENTED SCENARIO STATE {toJsonString(scenario.state)}
    {/if}
  {:else if "completed" in scenario.state}
    <div class="text-4xl font-semibold text-center mb-4 text-primary-500">
      {scenario.metaData.name}
    </div>
    <div class="flex justify-center">
      <PixelArtCanvas
        layers={[decodeImageToPixels(scenario.metaData.image, 64, 64)]}
        pixelSize={4}
      />
    </div>
    <div class="text-3xl my-2">Scenario Complete</div>
    <Button on:click={nextScenario} class="mb-4">Continue</Button>
  {/if}
</div>
{#if scenario.previousStages.length > 0}
  <Hr />
  <div class="text-4xl text-primary-500 mb-2">Scenario Log</div>
  <ScenarioStages stages={scenario.previousStages} />
  {scenario.metaData.description}
{/if}
