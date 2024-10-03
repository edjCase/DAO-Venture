<script lang="ts">
  import {
    CombatScenarioState,
    CombatChoice,
    ActionTargetResult,
    CharacterActionKind,
    CharacterWithMetaData,
  } from "../../ic-agent/declarations/main";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { scenarioStore } from "../../stores/ScenarioStore";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import { actionStore } from "../../stores/ActionStore";
  import { creatureStore } from "../../stores/CreatureStore";
  import ScenarioCombatStats from "./ScenarioCombatStats.svelte";
  import { toJsonString } from "../../utils/StringUtil";
  import CombatEffect from "./CombatEffect.svelte";
  import CharacterAvatar from "../character/CharacterAvatar.svelte";
  import LoadingButton from "../common/LoadingButton.svelte";

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

  $: enemyCreatures = combatState.creatures.map((combatCreature, index) => {
    const creatureData = creatures?.find(
      (c) => c.id === combatCreature.creatureId
    );
    return {
      ...creatureData,
      ...combatCreature,
      alive: combatCreature.health > 0,
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

  $: canSelectTarget = (creatureIndexOrCharacter: number | "character") => {
    let isEnemy;
    if (creatureIndexOrCharacter !== "character") {
      isEnemy = true;
      let creature = enemyCreatures[creatureIndexOrCharacter];
      if (!creature.alive) return false;
    } else {
      isEnemy = false;
    }
    if (!selectedAction) return false;
    const { scope } = selectedAction.target;
    return (
      "any" in scope ||
      (isEnemy && "enemy" in scope) ||
      (!isEnemy && "ally" in scope)
    );
  };

  $: isAutoSelected = (creatureIndexOrCharacter: number | "character") => {
    if (!selectedAction) return false;
    const { scope, selection } = selectedAction.target;
    return (
      ("all" in selection ||
        ("random" in selection && selection.random.count > 0) ||
        ("chosen" in selection && "ally" in scope)) &&
      canSelectTarget(creatureIndexOrCharacter)
    );
  };

  $: currentGame = $currentGameStore;

  let character: CharacterWithMetaData | undefined;
  $: {
    if (currentGame !== undefined) {
      if ("inProgress" in currentGame.state) {
        character = currentGame.state.inProgress.character;
      } else {
        character = undefined;
      }
    }
  }

  let selectTarget = (creaturIndexOrCharacter: number | "character") => () => {
    if (
      selectedAction &&
      "chosen" in selectedAction.target.selection &&
      canSelectTarget(creaturIndexOrCharacter)
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
      } else if (
        "enemy" in action.target.scope &&
        enemyCreatures.filter((c) => c.alive).length === 1
      ) {
        // Auto-select the only enemy if there's just one alive
        selectedTargetIndex = enemyCreatures[0].index;
        isCharacterSelected = false;
      } else {
        selectedTargetIndex = undefined;
        isCharacterSelected = false;
      }
    }
  };

  let performActionLoading = false;

  async function performAction() {
    if (!selectedActionKind) {
      console.error("No action selected");
      return;
    }
    performActionLoading = true;

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
    try {
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
    } finally {
      performActionLoading = false;
    }
  }

  $: actionGroups = [
    { action: skillAction, kind: { skill: null }, label: "Skill" },
    { action: itemAction, kind: { item: null }, label: "Item" },
    { action: weaponAction, kind: { weapon: null }, label: "Weapon" },
  ];

  $: needToSelectTarget =
    selectedAction &&
    "chosen" in selectedAction.target.selection &&
    !isCharacterSelected &&
    selectedTargetIndex === undefined &&
    !("ally" in selectedAction.target.scope);
</script>

<div class="flex flex-col gap-4">
  <div class="flex flex-row gap-4 justify-around items-center">
    <div
      class="p-4 cursor-pointer border-2 drop-shadow-xl bg-gray-700 border-gray-500
    {isCharacterSelected
        ? 'border-green-500'
        : isAutoSelected('character')
          ? 'border-yellow-500'
          : canSelectTarget('character')
            ? 'border-blue-500 hover:border-blue-400'
            : 'border-gray-600'}"
      on:click={selectTarget("character")}
      on:keypress={selectTarget("character")}
      role="button"
      tabindex="0"
    >
      <ScenarioCombatStats value={combatState.character} />
      {#if character !== undefined}
        <CharacterAvatar pixelSize={2} {character} />
      {/if}
    </div>
    <div class="flex flex-col gap-4 justify-around">
      {#each enemyCreatures as creature, i}
        <div
          class="p-4 cursor-pointer max-w-48 border-2 drop-shadow-xl bg-gray-700 border-gray-500
        {selectedTargetIndex === creature.index
            ? 'border-green-500'
            : isAutoSelected(creature.index)
              ? 'border-yellow-500'
              : canSelectTarget(creature.index)
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
  </div>
  <div>
    <h3 class="text-xl font-semibold text-right w-1/4">Actions</h3>
    <div class="flex flex-col flex-wrap justify-around gap-1">
      {#each actionGroups as { action, kind, label }}
        <div class="flex justify-around">
          <div class="text-xl mt-2 font-semibold text-right pr-2 w-36">
            <div class="text-primary-500">
              {#if performActionLoading}
                -
              {:else}
                {action?.name || "-"}
              {/if}
            </div>
            <span class="text-sm">{label}</span>
          </div>
          <div
            class="flex-grow border-2 drop-shadow-xl border-gray-500 min-h-16"
          >
            {#if performActionLoading}
              <div class="animate-pulse h-full w-full bg-gray-600"></div>
            {:else if !action}
              <div class="h-full flex items-center justify-center">
                <h4 class="font-semibold">
                  No {label} Action Available
                </h4>
              </div>
            {:else}
              <div
                class="h-full flex flex-col justify-center {JSON.stringify(
                  selectedActionKind
                ) === JSON.stringify(kind)
                  ? 'bg-gray-600 border-blue-500'
                  : 'bg-gray-800 hover:bg-gray-600'}"
                on:click={selectAction(kind)}
                on:keypress={selectAction(kind)}
                role="button"
                tabindex="0"
              >
                <p class="text-xs">
                  Target: {#if "any" in action.target.scope}
                    Any
                  {:else if "ally" in action.target.scope}
                    Self
                  {:else if "enemy" in action.target.scope}
                    Enemy
                  {:else}
                    NOT IMPLEMENTED TARGET SCOPE {toJsonString(
                      action.target.scope
                    )}
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
              </div>
            {/if}
          </div>
        </div>
      {/each}
    </div>
  </div>

  <LoadingButton
    onClick={performAction}
    class="mt-4"
    disabled={!selectedActionKind || needToSelectTarget}
    color={needToSelectTarget ? "yellow" : "primary"}
  >
    {needToSelectTarget ? "Select Target" : "Perform Action"}
  </LoadingButton>
</div>
