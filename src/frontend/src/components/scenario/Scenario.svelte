<script lang="ts">
  import { scenarioStore } from "../../stores/ScenarioStore";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import GameImage from "../common/GameImage.svelte";
  import ScenarioOption from "./ScenarioOption.svelte";
  import { Button } from "flowbite-svelte";
  import { onDestroy, onMount } from "svelte";
  import { toJsonString } from "../../utils/StringUtil";
  import {
    CharacterWithMetaData,
    Scenario,
  } from "../../ic-agent/declarations/main";
  import ScenarioStages from "./ScenarioStages.svelte";
  import ScenarioCombat from "./ScenarioCombat.svelte";
  import ScenarioReward from "./ScenarioReward.svelte";

  export let scenario: Scenario;
  export let character: CharacterWithMetaData;
  export let nextScenario: () => void;

  let vote = async (optionId: string) => {
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
      <div class="text-3xl text-center mb-4">
        {scenario.metaData.name}
      </div>
      <div class="flex justify-center">
        <GameImage id={scenario.metaData.imageId} />
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
                <ScenarioOption {option} selected={false} onSelect={vote} />
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
    <Button on:click={nextScenario}>Continue</Button>
  {/if}
  <ScenarioStages stages={scenario.previousStages} />
</div>
