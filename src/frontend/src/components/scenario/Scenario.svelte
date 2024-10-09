<script lang="ts">
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import ScenarioOption from "./ScenarioOption.svelte";
  import { Button, Hr } from "flowbite-svelte";
  import { toJsonString } from "../../utils/StringUtil";
  import {
    CharacterWithMetaData,
    ScenarioWithMetaData,
  } from "../../ic-agent/declarations/main";
  import ScenarioCombat from "./ScenarioCombat.svelte";
  import ScenarioReward from "./ScenarioReward.svelte";
  import { decodeImageToPixels } from "../../utils/PixelUtil";
  import PixelArtCanvas from "../common/PixelArtCanvas.svelte";
  import ScenarioStages from "./ScenarioStages.svelte";
  import GenericOption from "../common/GenericOption.svelte";
  import ScenarioKindIcon from "./ScenarioKindIcon.svelte";
  import { onMount } from "svelte";

  export let scenario: ScenarioWithMetaData;
  export let character: CharacterWithMetaData;
  export let nextScenario: () => void;

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

  let startScenario = (i: number) => async () => {
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.selectScenarioChoice({
      choice: {
        startScenario: {
          optionId: BigInt(i),
        },
      },
    });
    if ("ok" in result) {
      currentGameStore.refetch();
    } else {
      console.error("Failed start scenario:", result, i);
    }
  };

  onMount(async () => {
    // TODO this is kinda a hack, but it works for now
    if (
      "notStarted" in scenario.state &&
      scenario.state.notStarted.options.length == 1
    ) {
      await startScenario(0)();
    }
  });
</script>

<div class="text-center">
  {#if "notStarted" in scenario.state}
    {#if scenario.state.notStarted.options.length == 1}
      <div class="text-4xl font-semibold mb-4 text-primary-500">
        Traveling...
      </div>
    {:else}
      <div class="text-4xl font-semibold mb-4 text-primary-500">
        Fork in the road
      </div>
      <ul class="text-lg p-6">
        {#each scenario.state.notStarted.options as option, i}
          <li>
            <GenericOption onSelect={startScenario(i)}>
              Path {i + 1}:
              <ScenarioKindIcon value={option} />
            </GenericOption>
          </li>
        {/each}
      </ul>
    {/if}
  {:else if "started" in scenario.state}
    {#if "inProgress" in scenario.state.started.kind}
      {#if "choice" in scenario.state.started.kind.inProgress}
        <div class="text-4xl font-semibold mb-4 text-primary-500">
          {scenario.state.started.metaData.name}
        </div>
        <div class="flex justify-center">
          <PixelArtCanvas
            layers={[
              decodeImageToPixels(
                scenario.state.started.metaData.image,
                64,
                64
              ),
            ]}
            pixelSize={4}
          />
        </div>
        <div class="text-xl my-6">
          {scenario.state.started.metaData.description}
        </div>
        <div class="flex flex-col items-center gap-2">
          <div>
            <div>Options</div>
            <ul class="text-lg p-6">
              {#each scenario.state.started.kind.inProgress.choice.choices as option}
                <li>
                  <ScenarioOption {option} onSelect={selectChoice(option.id)} />
                </li>
              {/each}
            </ul>
          </div>
        </div>
      {:else if "combat" in scenario.state.started.kind.inProgress}
        <div class="text-3xl text-center mb-4">Combat</div>
        <ScenarioCombat
          combatState={scenario.state.started.kind.inProgress.combat}
        />
      {:else if "reward" in scenario.state.started.kind.inProgress}
        <ScenarioReward
          rewardState={scenario.state.started.kind.inProgress.reward}
          {character}
        />
      {:else}
        NOT IMPLEMENTED SCENARIO STATE 2 {toJsonString(scenario.state)}
      {/if}
    {:else if "completed" in scenario.state.started.kind}
      <div class="text-4xl font-semibold text-center mb-4 text-primary-500">
        {scenario.state.started.metaData.name}
      </div>
      <div class="flex justify-center">
        <PixelArtCanvas
          layers={[
            decodeImageToPixels(scenario.state.started.metaData.image, 64, 64),
          ]}
          pixelSize={4}
        />
      </div>
      <div class="text-3xl my-2">Scenario Complete</div>
      <Button on:click={nextScenario} class="mb-4">Continue</Button>
    {:else}
      NOT IMPLEMENTED SCENARIO STATE 3 {toJsonString(scenario.state)}
    {/if}

    {#if scenario.state.started.previousStages.length > 0}
      <Hr />
      <div class="text-4xl text-primary-500 mb-2">Scenario Log</div>
      <ScenarioStages stages={scenario.state.started.previousStages} />
      {scenario.state.started.metaData.description}
    {/if}
  {:else}
    NOT IMPLEMENTED SCENARIO STATE {toJsonString(scenario.state)}
  {/if}
</div>
