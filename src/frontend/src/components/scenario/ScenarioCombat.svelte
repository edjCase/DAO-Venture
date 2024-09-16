<script lang="ts">
  import {
    CombatScenarioState,
    CombatChoice,
    ActionTargetResult,
    CharacterActionKind,
  } from "../../ic-agent/declarations/main";
  import { Button } from "flowbite-svelte";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { scenarioStore } from "../../stores/ScenarioStore";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import { actionStore } from "../../stores/ActionStore";
  import { creatureStore } from "../../stores/CreatureStore";
  import ScenarioCombatStats from "./ScenarioCombatStats.svelte";
  import { toJsonString } from "../../utils/StringUtil";
  import CombatEffect from "./CombatEffect.svelte";

  export let combatState: CombatScenarioState;

  let selectedActionKind: CharacterActionKind | undefined;
  let selectedTargetIndex: number | undefined;
  let isCharacterSelected: boolean = false;

  $: actions = $actionStore;
  $: creatures = $creatureStore;

  $: skillAction = combatState.character.skillActionId[0]
    ? actions?.find(
        (action) => action.id === combatState.character.skillActionId[0]
      )
    : undefined;
  $: itemAction = combatState.character.itemActionId[0]
    ? actions?.find(
        (action) => action.id === combatState.character.itemActionId[0]
      )
    : undefined;
  $: weaponAction = combatState.character.weaponActionId[0]
    ? actions?.find(
        (action) => action.id === combatState.character.weaponActionId[0]
      )
    : undefined;

  $: availableCreatures = combatState.creatures.map((combatCreature, index) => {
    const creatureData = creatures?.find(
      (c) => c.id === combatCreature.creatureId
    );
    return {
      ...creatureData,
      ...combatCreature,
      index,
    };
  });

  $: selectedAction =
    selectedActionKind === undefined
      ? undefined
      : "skill" in selectedActionKind
        ? skillAction
        : "item" in selectedActionKind
          ? itemAction
          : weaponAction;

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
    const { scope, selection } = selectedAction.target;
    return (
      ("all" in selection ||
        ("random" in selection && selection.random.count > 0) ||
        ("chosen" in selection && "ally" in scope)) &&
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

  let selectAction = (kind: CharacterActionKind) => () => {
    selectedActionKind = kind;
    const action =
      "skill" in kind
        ? skillAction
        : "item" in kind
          ? itemAction
          : weaponAction;
    if (action && "chosen" in action.target.selection) {
      if ("ally" in action.target.scope) {
        // Auto-select character for self-targeting abilities
        selectedTargetIndex = undefined;
        isCharacterSelected = true;
      } else {
        selectedTargetIndex = undefined;
        isCharacterSelected = false;
      }
    }
  };

  async function performAction() {
    if (!selectedActionKind) {
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
      kind: selectedActionKind,
      target: target ? [target] : [],
    };

    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.selectScenarioChoice({
      choice: {
        combat: action,
      },
    });

    if ("ok" in result) {
      scenarioStore.refetch();
      currentGameStore.refetch();
      selectedActionKind = undefined;
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
    {#each [{ action: skillAction, kind: { skill: null }, label: "Skill" }, { action: itemAction, kind: { item: null }, label: "Item" }, { action: weaponAction, kind: { weapon: null }, label: "Weapon" }] as { action, kind, label }}
      {#if action}
        <div
          class="border border-gray-600 p-4 rounded-lg cursor-pointer max-w-36
          {JSON.stringify(selectedActionKind) === JSON.stringify(kind)
            ? 'bg-gray-700 border-blue-500'
            : 'bg-gray-800 hover:bg-gray-700'}"
          on:click={selectAction(kind)}
          on:keypress={selectAction(kind)}
          role="button"
          tabindex="0"
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
          <div class="flex flex-col justify-center">
            {#if action.combatEffects.length > 0}
              {#each action.combatEffects as effect}
                <div>
                  <CombatEffect value={effect} />
                </div>
              {/each}
            {/if}
          </div>
          <p class="text-xs mt-2 font-semibold">{label}</p>
        </div>
      {:else}
        <div
          class="border border-gray-600 p-4 rounded-lg max-w-36 bg-gray-800 opacity-50"
        >
          <h4 class="font-semibold mb-2">No {label} Action Available</h4>
        </div>
      {/if}
    {/each}
  </div>

  {#if selectedAction && "chosen" in selectedAction.target.selection && !isCharacterSelected && selectedTargetIndex === undefined && !("ally" in selectedAction.target.scope)}
    <p class="text-yellow-400 mt-2">Please select a target for this action.</p>
  {/if}

  <Button
    on:click={performAction}
    class="mt-4"
    disabled={!selectedActionKind ||
      (selectedAction &&
        "chosen" in selectedAction.target.selection &&
        !isCharacterSelected &&
        selectedTargetIndex === undefined &&
        !("ally" in selectedAction.target.scope))}
  >
    Perform Action
  </Button>
</div>
