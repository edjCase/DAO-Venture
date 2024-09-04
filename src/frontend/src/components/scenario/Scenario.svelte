<script lang="ts">
  import { scenarioStore } from "../../stores/ScenarioStore";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import GameImage from "../common/GameImage.svelte";
  import ScenarioOption from "./ScenarioOption.svelte";
  import { Button } from "flowbite-svelte";
  import { onDestroy, onMount } from "svelte";
  import CharacterStatIcon from "../character/CharacterStatIcon.svelte";
  import { toJsonString } from "../../utils/StringUtil";
  import { AccordionItem, Accordion } from "flowbite-svelte";
  import { Scenario } from "../../ic-agent/declarations/main";

  export let scenario: Scenario;
  export let nextScenario: () => void;

  $: currentGame = $currentGameStore;

  let vote = async (optionId: string) => {
    if (currentGame === undefined) {
      console.error("Game not found");
      return;
    }
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.selectScenarioChoice({
      choiceId: optionId,
    });
    if ("ok" in result) {
      console.log("Voted successfully");
      scenarioStore.refetch();
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
                <ScenarioOption {option} selected={false} onSelect={vote} />
              </li>
            {/if}
          {/each}
        </ul>
      </div>
    </div>
  {:else}
    {@const choiceId = scenario.outcome[0].choiceId}
    {@const option = scenario.metaData.choices.find((c) => c.id == choiceId)}
    <div class="text-3xl text-primary-500">Choice</div>
    <div class="text-xl">
      {#if option !== undefined}
        {option.description}
      {:else}
        COULD NOT FIND OPTION {choiceId}
      {/if}
    </div>
    <div class="text-3xl text-primary-500">Outcome</div>
    <div>TODO</div>

    <Button on:click={nextScenario}>Continue</Button>
    <div class="text-3xl text-primary-500">Outcome Log</div>
    <ul class="text-sm">
      {#each scenario.outcome[0].log as logEntry}
        <li>
          {#if "text" in logEntry}
            {logEntry.text}
          {:else if "combat" in logEntry}
            <Accordion flush>
              <AccordionItem>
                <div slot="header">Combat Log</div>
                <div>
                  {#each logEntry.combat.turns as turn}
                    <div>
                      {#each turn.attacks as attack}
                        {#if "character" in turn.attacker}
                          You
                        {:else}
                          The creature
                        {/if}
                        {#if "hit" in attack}
                          hit for {attack.hit.damage} damage
                        {:else if "miss" in attack}
                          missed
                        {:else}
                          NOT IMPLEMENTED ATTACK TYPE {toJsonString(attack)}
                        {/if}
                      {/each}
                    </div>
                  {/each}
                </div>
              </AccordionItem>
            </Accordion>
          {:else if "healthDelta" in logEntry}
            HEALTH
            {logEntry.healthDelta >= 0 ? "+" : ""}{logEntry.healthDelta}
            <CharacterStatIcon kind={{ maxHealth: null }} />
          {:else if "maxHealthDelta" in logEntry}
            MAX HEALTH
            {logEntry.maxHealthDelta >= 0 ? "+" : ""}{logEntry.maxHealthDelta}
            <CharacterStatIcon kind={{ maxHealth: null }} />
          {:else if "attackDelta" in logEntry}
            {logEntry.attackDelta >= 0 ? "+" : ""}{logEntry.attackDelta}
            <CharacterStatIcon kind={{ maxHealth: null }} />
          {:else if "defenseDelta" in logEntry}
            {logEntry.defenseDelta >= 0 ? "+" : ""}{logEntry.defenseDelta}
            <CharacterStatIcon kind={{ maxHealth: null }} />
          {:else if "speedDelta" in logEntry}
            {logEntry.speedDelta >= 0 ? "+" : ""}{logEntry.speedDelta}
            <CharacterStatIcon kind={{ maxHealth: null }} />
          {:else if "magicDelta" in logEntry}
            {logEntry.magicDelta >= 0 ? "+" : ""}{logEntry.magicDelta}
            <CharacterStatIcon kind={{ maxHealth: null }} />
          {:else if "goldDelta" in logEntry}
            {logEntry.goldDelta >= 0 ? "+" : ""}{logEntry.goldDelta}
            <CharacterStatIcon kind={{ gold: null }} />
          {:else if "addItem" in logEntry}
            +{logEntry.addItem}
          {:else if "removeItem" in logEntry}
            -{logEntry.removeItem}
          {:else if "addTrait" in logEntry}
            +{logEntry.addTrait}
          {:else if "removeTrait" in logEntry}
            -{logEntry.removeTrait}
          {:else}
            NOT IMPLEMENTED LOG ENTRY TYPE {toJsonString(logEntry)}
          {/if}
        </li>
      {/each}
    </ul>
  {/if}
</div>
