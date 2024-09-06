<script lang="ts">
  import {
    CombatScenarioState,
    CombatChoice,
    ActionTargetResult,
  } from "../../ic-agent/declarations/main";
  import { Button, Select } from "flowbite-svelte";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { scenarioStore } from "../../stores/ScenarioStore";
  import { currentGameStore } from "../../stores/CurrentGameStore";

  export let combatState: CombatScenarioState;

  let selectedActionId: string | undefined;
  let selectedTargeIndexString: string = "0";

  $: availableActions = combatState.character.availableActionIds;
  $: availableTargets = combatState.creatures.map((creature, i) => ({
    value: i.toString(),
    name: creature.creatureId,
  }));

  $: if (availableActions.length > 0 && selectedActionId === undefined) {
    selectedActionId = availableActions[0];
  }

  async function performAction() {
    if (!selectedActionId) {
      console.error("No action selected");
      return;
    }

    let target: ActionTargetResult | undefined;
    if (selectedTargeIndexString !== undefined) {
      target = { creature: BigInt(selectedTargeIndexString) };
    }

    const action: CombatChoice = {
      actionId: selectedActionId,
      target: target ? [target] : [],
    };

    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.selectScenarioChoice({
      choice: {
        combat: action,
      },
    });

    if ("ok" in result) {
      console.log("Combat action successful");
      scenarioStore.refetch();
      currentGameStore.refetch();
    } else {
      console.error("Failed to perform combat action:", result);
    }
  }
</script>

<div class="flex flex-col gap-4">
  <h2 class="text-2xl font-bold">Combat</h2>

  <div class="p-4 rounded-lg">
    <h3 class="text-xl font-semibold mb-2">Your Character</h3>
    <p>Shield: {combatState.character.shield}</p>
    <p>
      Status Effects: {combatState.character.statusEffects
        .map((effect) => effect.kind)
        .join(", ")}
    </p>
  </div>

  <div class="p-4 rounded-lg">
    <h3 class="text-xl font-semibold mb-2">Creatures</h3>
    {#each combatState.creatures as creature}
      <div class="border border-gray-300 p-2 rounded mb-2">
        <p>ID: {creature.creatureId}</p>
        <p>Health: {creature.health}/{creature.maxHealth}</p>
        <p>Shield: {creature.shield}</p>
        <p>
          Status Effects: {creature.statusEffects
            .map((effect) => effect.kind)
            .join(", ")}
        </p>
      </div>
    {/each}
  </div>

  <div class="flex gap-2 items-center">
    <Select
      bind:value={selectedActionId}
      items={availableActions.map((id) => ({ value: id, name: id }))}
      class="flex-grow"
    />
    <Select
      bind:value={selectedTargeIndexString}
      items={availableTargets}
      class="flex-grow"
    />
    <Button on:click={performAction}>Perform Action</Button>
  </div>
</div>
