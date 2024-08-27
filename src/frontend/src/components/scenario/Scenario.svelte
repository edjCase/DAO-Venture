<script lang="ts">
  import { scenarioStore } from "../../stores/ScenarioStore";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import ChoiceRequirement from "./ChoiceRequirement.svelte";
  import GameImage from "../common/GameImage.svelte";

  export let scenarioId: bigint;

  $: currentGame = $currentGameStore;

  $: scenarios = $scenarioStore;
  $: scenario = scenarios?.find((s) => s.id == scenarioId);

  let vote = (optionId: string) => async () => {
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
</script>

<div class="p-6">
  {#if scenario !== undefined}
    <div class="flex justify-center">
      <GameImage id={scenario.metaData.imageId} />
    </div>
    <div class="text-3xl text-center">
      {scenario.metaData.name}
    </div>
    <div class="text-xl my-6">
      {scenario.metaData.description}
    </div>
    <div class="mb-5">
      <div class="mb-2">Outcome</div>
      {#if scenario.outcome[0] !== undefined}
        <ul class="text-sm">
          {#each scenario.outcome[0].messages as message}
            <li>{message}</li>
          {/each}
        </ul>
      {:else}
        <div class="text-sm">Unresolved</div>
      {/if}
    </div>
    <div class="flex flex-col items-center gap-2">
      <div>
        <div>Options</div>
        <ul class="text-lg p-6">
          {#each scenario.metaData.choices as option}
            {#if scenario.availableChoiceIds.includes(option.id)}
              <li>
                <button
                  class={"p-4 border rounded mb-2 w-full text-left" +
                    (option.id == scenario.voteData.yourVote[0]?.choice[0]
                      ? " bg-gray-900"
                      : "")}
                  on:click={vote(option.id)}
                >
                  {option.description}
                  {#if option.requirement[0] !== undefined}
                    <ChoiceRequirement value={option.requirement[0]} />
                  {/if}
                </button>
              </li>
            {/if}
          {/each}
        </ul>
      </div>
    </div>
  {/if}
</div>
