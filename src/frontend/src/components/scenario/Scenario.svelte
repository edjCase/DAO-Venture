<script lang="ts">
  import { Button } from "flowbite-svelte";
  import { scenarioStore } from "../../stores/ScenarioStore";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { gameStateStore } from "../../stores/GameStateStore";

  export let scenarioId: bigint;

  $: scenarios = $scenarioStore;
  $: scenario = scenarios?.find((s) => s.id == scenarioId);

  let vote = (optionId: string) => async () => {
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.voteOnScenario({
      scenarioId: scenarioId,
      value: optionId,
    });
    if ("ok" in result) {
      console.log("Voted successfully");
      scenarioStore.refetch();
      gameStateStore.refetch();
    } else {
      console.error("Failed to vote:", result);
    }
  };
</script>

<div class="p-6">
  {#if scenario !== undefined}
    <div class="text-3xl text-center">
      {scenario.metaData.title}
    </div>
    <div class="text-xl my-6">
      {scenario.metaData.description}
    </div>
    {#if scenario.outcome[0] !== undefined}
      <div>Outcome</div>
      {#each scenario.outcome[0].messages as message}
        <div>{message}</div>
      {/each}
    {/if}
    <div class="flex flex-col items-center gap-2">
      <div>
        <div>Options</div>
        <ul class="text-lg text-left p-6">
          {#each scenario.metaData.choices as option, i}
            <li>
              <Button
                class="p-4 border rounded mb-2 w-full"
                on:click={vote(option.id)}
              >
                {i}. {option.description}
              </Button>
            </li>
          {/each}
        </ul>
      </div>
    </div>
  {/if}
</div>
