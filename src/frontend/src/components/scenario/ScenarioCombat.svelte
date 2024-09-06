<script lang="ts">
  import {
    CombatScenarioState,
    CombatChoice,
    ActionTargetResult,
    Action,
  } from "../../ic-agent/declarations/main";
  import { Button } from "flowbite-svelte";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { scenarioStore } from "../../stores/ScenarioStore";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import { actionStore } from "../../stores/ActionStore";
  import { creatureStore } from "../../stores/CreatureStore";
  import ScenarioCombatStats from "./ScenarioCombatStats.svelte";
  import { toJsonString } from "../../utils/StringUtil";

  export let combatState: CombatScenarioState;

  let selectedActionId: string | undefined;
  let selectedTargetIndex: number | undefined;
  let isCharacterSelected: boolean = false;

  $: actions = $actionStore;
  $: creatures = $creatureStore;

  $: availableActions = combatState.character.availableActionIds
    .map((id) => actions?.find((action) => action.id === id))
    .filter((action): action is Action => action !== undefined);

  $: availableCreatures = combatState.creatures.map((combatCreature, index) => {
    const creatureData = creatures?.find(
      (c) => c.id === combatCreature.creatureId
    );
    return {
      ...combatCreature,
      ...creatureData,
      index,
    };
  });

  $: selectedAction = availableActions.find(
    (action) => action.id === selectedActionId
  );

  $: canSelectTarget = (isEnemy: boolean) => {
    if (!selectedAction) return false;
    const { scope } = selectedAction.target;
    return (
      "any" in scope ||
      (isEnemy && "enemy" in scope) ||
      (!isEnemy && "ally" in scope)
    );
  };

  $: isAutoSelected = (isEnemy: boolean) => {
    if (!selectedAction) return false;
    const { selection } = selectedAction.target;
    return (
      ("all" in selection ||
        ("random" in selection && selection.random.count > 0)) &&
      canSelectTarget(isEnemy)
    );
  };

  let selectTarget = (creaturIndexOrCharacter: number | "character") => () => {
    if (
      selectedAction &&
      "chosen" in selectedAction.target.selection &&
      canSelectTarget(creaturIndexOrCharacter !== "character")
    ) {
      if (creaturIndexOrCharacter === "character") {
        selectedTargetIndex = undefined;
        isCharacterSelected = true;
      } else {
        selectedTargetIndex = creaturIndexOrCharacter;
        isCharacterSelected = false;
      }
    }
  };

  let selectAction = (id: string) => () => {
    selectedActionId = id;
    if (selectedAction && "chosen" in selectedAction.target.selection) {
      selectedTargetIndex = undefined;
      isCharacterSelected = false;
    }
  };

  async function performAction() {
    if (!selectedActionId) {
      console.error("No action selected");
      return;
    }

    let target: ActionTargetResult | undefined;
    if (isCharacterSelected) {
      target = { character: null };
    } else if (selectedTargetIndex !== undefined) {
      target = { creature: BigInt(selectedTargetIndex) };
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
      selectedActionId = undefined;
      selectedTargetIndex = undefined;
      isCharacterSelected = false;
    } else {
      console.error("Failed to perform combat action:", result);
    }
  }
</script>

<div class="flex flex-col gap-4">
  <h2 class="text-2xl font-bold">Combat</h2>

  <div class="flex flex-wrap justify-around">
    {#each availableCreatures as creature, i}
      <div
        class="border p-4 rounded-lg cursor-pointer max-w-36 bg-gray-800
        {selectedTargetIndex === creature.index
          ? 'border-green-500'
          : isAutoSelected(true)
            ? 'border-yellow-500'
            : canSelectTarget(true)
              ? 'border-blue-500 hover:border-blue-400'
              : 'border-gray-600'}"
        on:click={selectTarget(creature.index)}
        on:keypress={selectTarget(creature.index)}
        role="button"
        tabindex={i}
      >
        <h4 class="font-semibold mb-2">{creature.name || creature.id}</h4>
        <ScenarioCombatStats value={creature} />
      </div>
    {/each}
  </div>

  <div
    class="p-4 rounded-lg border cursor-pointer bg-gray-800
    {isCharacterSelected
      ? 'border-green-500'
      : isAutoSelected(false)
        ? 'border-yellow-500'
        : canSelectTarget(false)
          ? 'border-blue-500 hover:border-blue-400'
          : 'border-gray-600'}"
    on:click={selectTarget("character")}
    on:keypress={selectTarget("character")}
    role="button"
    tabindex="0"
  >
    <h3 class="text-xl font-semibold mb-2">Your Character</h3>
    <ScenarioCombatStats value={combatState.character} />
  </div>

  <h3 class="text-xl font-semibold mt-4 mb-2">Available Actions</h3>
  <div class="flex flex-wrap justify-around">
    {#each availableActions as action, i}
      <div
        class="border border-gray-600 p-4 rounded-lg cursor-pointer max-w-36
        {selectedActionId === action.id
          ? 'bg-gray-700 border-blue-500'
          : 'bg-gray-800 hover:bg-gray-700'}"
        on:click={selectAction(action.id)}
        on:keypress={selectAction(action.id)}
        role="button"
        tabindex={i}
      >
        <h4 class="font-semibold mb-2">{action.name}</h4>
        <p class="text-sm">{action.description}</p>
        <p class="text-xs mt-2">
          Target: {#if "any" in action.target.scope}
            Any
          {:else if "ally" in action.target.scope}
            Self
          {:else if "enemy" in action.target.scope}
            Enemy
          {:else}
            NOT IMPLEMENTED TARGET SCOPE {toJsonString(action.target.scope)}
          {/if}
          -
          {#if "chosen" in action.target.selection}
            Chosen
          {:else if "all" in action.target.selection}
            All
          {:else if "random" in action.target.selection}
            Random
          {:else}
            NOT IMPLEMENTED TARGET SELECTION {toJsonString(
              action.target.selection
            )}
          {/if}
        </p>
      </div>
    {/each}
  </div>

  {#if selectedAction && "chosen" in selectedAction.target.selection && !isCharacterSelected && selectedTargetIndex === undefined}
    <p class="text-yellow-400 mt-2">Please select a target for this action.</p>
  {/if}

  <Button
    on:click={performAction}
    class="mt-4"
    disabled={!selectedActionId ||
      (selectedAction &&
        "chosen" in selectedAction.target.selection &&
        !isCharacterSelected &&
        selectedTargetIndex === undefined)}
  >
    Perform Action
  </Button>
</div>
