<script lang="ts">
  import { scenarioStore } from "../../stores/ScenarioStore";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import GameImage from "../common/GameImage.svelte";
  import ScenarioOption from "./ScenarioOption.svelte";
  import { Button } from "flowbite-svelte";
  import { onDestroy, onMount } from "svelte";
  import { toJsonString } from "../../utils/StringUtil";

  export let scenarioId: bigint;
  export let nextScenario: () => void;

  $: currentGame = $currentGameStore;

  $: scenarios = $scenarioStore;
  $: scenario = scenarios?.find((s) => s.id == scenarioId);

  let vote = async (optionId: string) => {
    if (currentGame === undefined) {
      console.error("Game not found");
      return;
    }
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.voteOnScenario({
      gameId: currentGame.id,
      scenarioId: scenarioId,
      value: optionId,
    });
    if ("ok" in result) {
      console.log("Voted successfully");
      scenarioStore.refetchByGameId(currentGame.id);
      currentGameStore.refetch();
    } else {
      console.error("Failed to vote:", result);
    }
  };
  let intervalId: NodeJS.Timeout | undefined;
  onMount(() => {
    intervalId = setInterval(() => {
      // Get the updated vote
      if (currentGame === undefined) {
        return;
      }
      scenarioStore.refetchByGameId(currentGame.id);
    }, 3000);
  });

  onDestroy(() => {
    if (intervalId) {
      clearInterval(intervalId);
    }
  });
</script>

<div class="">
  {#if scenario !== undefined}
    <div class="text-3xl text-center mb-4">
      {scenario.metaData.name}
    </div>
    <div class="flex justify-center">
      <GameImage id={scenario.metaData.imageId} />
    </div>
    {#if scenario.outcome[0] === undefined}
      <div class="text-xl my-6">
        {scenario.metaData.description}
      </div>
      <div class="flex flex-col items-center gap-2">
        <div>
          <div>Options</div>
          <ul class="text-lg p-6">
            {#each scenario.metaData.choices as option}
              {#if scenario.availableChoiceIds.includes(option.id)}
                <li>
                  <ScenarioOption
                    {option}
                    vote={scenario.voteData}
                    onSelect={vote}
                  />
                </li>
              {/if}
            {/each}
          </ul>
        </div>
      </div>
    {:else}
      {@const choiceOrUndecided = scenario.outcome[0]?.choiceOrUndecided[0]}
      <div class="text-3xl text-primary-500">Choice</div>
      <div class="text-xl">
        {#if choiceOrUndecided !== undefined}
          {@const option = scenario.metaData.choices.find(
            (c) => c.id == choiceOrUndecided
          )}
          {#if option !== undefined}
            {option.description}
          {:else}
            COULD NOT FIND OPTION {choiceOrUndecided}
          {/if}
        {:else}
          Undecided...
        {/if}
      </div>
      <div class="text-3xl text-primary-500">Outcome</div>
      <div>TODO</div>

      <Button on:click={nextScenario}>Continue</Button>
      <div class="text-3xl text-primary-500">Outcome Log</div>
      <ul class="text-sm">
        {#each scenario.outcome[0].messages as message}
          <li>{message}</li>
        {/each}
      </ul>
    {/if}
  {/if}
</div>
