<script lang="ts">
  import { scenarioStore } from "../../stores/ScenarioStore";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import GameImage from "../common/GameImage.svelte";
  import ScenarioOption from "./ScenarioOption.svelte";
  import { Button } from "flowbite-svelte";
  import { onDestroy, onMount } from "svelte";
  import { toJsonString } from "../../utils/StringUtil";
  import { Scenario, ScenarioMetaData } from "../../ic-agent/declarations/main";
  import ScenarioStages from "./ScenarioStages.svelte";
  import ScenarioCombat from "./ScenarioCombat.svelte";

  export let scenario: Scenario;
  export let scenarioMetaData: ScenarioMetaData;
  export let nextScenario: () => void;

  $: currentGame = $currentGameStore;

  let vote = async (optionId: string) => {
    if (currentGame === undefined) {
      console.error("Game not found");
      return;
    }
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
      if (currentGame === undefined) {
        return;
      }
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
  {#if "choice" in scenario.state}
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
          {#each scenario.metaData.choices as option}
            {#if scenario.state.choice.choiceIds.includes(option.id)}
              <li>
                <ScenarioOption {option} selected={false} onSelect={vote} />
              </li>
            {/if}
          {/each}
        </ul>
      </div>
    </div>
  {:else if "combat" in scenario.state}
    <div class="text-3xl text-center mb-4">Combat</div>
    <ScenarioCombat combatState={scenario.state.combat} />
  {:else if "complete" in scenario.state}
    <Button on:click={nextScenario}>Continue</Button>
  {:else}
    NOT IMPLEMENTED SCENARIO STATE {toJsonString(scenario.state)}
  {/if}
  <ScenarioStages stages={scenario.previousStages} {scenarioMetaData} />
</div>
