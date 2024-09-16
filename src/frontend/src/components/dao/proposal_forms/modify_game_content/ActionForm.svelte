<script lang="ts">
  import FormTemplate from "../FormTemplate.svelte";
  import {
    Input,
    Label,
    Textarea,
    Select,
    SelectOptionType,
  } from "flowbite-svelte";
  import {
    CreateWorldProposalRequest,
    Action,
    CombatEffect,
    CombatEffectKind,
    CombatEffectTarget,
    ActionTarget,
    ScenarioEffect,
  } from "../../../../ic-agent/declarations/main";
  import MinMaxTimingForm from "./MinMaxTimingForm.svelte";
  import { actionStore } from "../../../../stores/ActionStore";
  import EntitySelector from "./EntitySelector.svelte";
  import CombatEffectEditor from "./CombatEffectEditor.svelte";
  import CombatEffectChooser from "./CombatEffectChooser.svelte";

  let id: string | undefined;
  let name: string | undefined;
  let description: string | undefined;
  let combatEffects: CombatEffect[] = [];
  let scenarioEffects: ScenarioEffect[] = [];
  let target: ActionTarget = {
    scope: { any: null },
    selection: { all: null },
  };

  const combatEffectKinds: SelectOptionType<string>[] = [
    { value: "damage", name: "Damage" },
    { value: "heal", name: "Heal" },
    { value: "block", name: "Block" },
    { value: "addStatusEffect", name: "Add Status Effect" },
  ];
  let selectedCombatEffectKind: string = combatEffectKinds[0].value;

  const scenarioEffectKinds: SelectOptionType<string>[] = [
    { value: "attribute", name: "Attribute" },
  ];
  let selectedScenarioEffectKind: string = scenarioEffectKinds[0].value;

  const targetScopes: SelectOptionType<string>[] = [
    { value: "any", name: "Any" },
    { value: "ally", name: "Ally" },
    { value: "enemy", name: "Enemy" },
  ];
  let selectedScope: string = targetScopes[0].value;

  const targetSelections: SelectOptionType<string>[] = [
    { value: "all", name: "All" },
    { value: "random", name: "Random" },
    { value: "chosen", name: "Chosen" },
  ];

  let selectedSelection: string = targetSelections[0].value;

  function addCombatEffect() {
    combatEffects = [...combatEffects, createDefaultCombatEffect()];
  }

  function removeCombatEffect(index: number) {
    combatEffects = combatEffects.filter((_, i) => i !== index);
  }

  function createDefaultCombatEffect(): CombatEffect {
    return {
      kind: { damage: { min: 1n, max: 1n, timing: { immediate: null } } },
      target: { self: null },
    };
  }

  let updateCombatEffectKind = (index: number) => () => {
    combatEffects = combatEffects.map((effect, i) => {
      if (i === index) {
        let newKind: CombatEffectKind;
        switch (selectedCombatEffectKind) {
          case "damage":
            newKind = {
              damage: { min: 1n, max: 1n, timing: { immediate: null } },
            };
            break;
          case "heal":
            newKind = {
              heal: { min: 1n, max: 1n, timing: { immediate: null } },
            };
            break;
          case "addStatusEffect":
            newKind = {
              addStatusEffect: { kind: { weak: null }, duration: [] },
            };
            break;
          case "block":
            newKind = {
              block: { min: 1n, max: 1n, timing: { immediate: null } },
            };
            break;
          default:
            newKind = effect.kind;
        }
        return { ...effect, kind: newKind };
      }
      return effect;
    });
  };

  let updateCombatEffectTarget = (index: number) => () => {
    combatEffects = combatEffects.map((effect, i) => {
      if (i === index) {
        const newTarget: CombatEffectTarget =
          targetValue === "self" ? { self: null } : { targets: null };
        return { ...effect, target: newTarget };
      }
      return effect;
    });
  };

  let generateProposal = (): CreateWorldProposalRequest | string => {
    if (!id) return "Id must be filled";
    if (!name) return "Name must be filled";
    if (!description) return "Description must be filled";

    const action: Action = {
      id,
      name,
      description,
      scenarioEffects,
      combatEffects,
      target,
    };

    return {
      modifyGameContent: {
        action,
      },
    };
  };
</script>

<FormTemplate {generateProposal}>
  <div class="space-y-4 mt-4">
    <div class="flex gap-4">
      <div class="flex-1">
        <Label for="id">Id</Label>
        <Input
          id="id"
          type="text"
          bind:value={id}
          placeholder="unique_action_id"
        />
      </div>
      <div class="flex-1">
        <Label for="name">Name</Label>
        <Input id="name" type="text" bind:value={name} placeholder="Fireball" />
      </div>
    </div>

    <div>
      <Label for="description">Description</Label>
      <Textarea
        id="description"
        bind:value={description}
        placeholder="A powerful fireball attack..."
      />
    </div>

    <div>
      <div>Scenario Effects</div>
      {#each scenarioEffects as effect, index}
        <div class="border p-4 mb-4 rounded">
          <Select
            items={scenarioEffectKinds}
            on:change={updateScenarioEffectKind(index)}
            bind:value={selectedScenarioEffectKind}
          />
          {#if "attribute" in effect}
            {a}
          {/if}
        </div>
      {/each}
    </div>

    <div>
      <Label>Combat Effects</Label>
      {#each combatEffects as effect, index}
        <div class="border p-4 mb-4 rounded">
          <CombatEffectChooser {effect} />
          <button
            class="mt-2 bg-red-500 text-white px-2 py-1 rounded"
            on:click={() => removeCombatEffect(index)}
          >
            Remove Effect
          </button>
        </div>
      {/each}
      <button
        class="bg-blue-500 text-white px-4 py-2 rounded"
        on:click={addCombatEffect}
      >
        Add Effect
      </button>
    </div>

    <div>
      <Label>Target</Label>
      <div class="flex gap-4">
        <div class="flex-1">
          <Label for="targetScope">Scope</Label>
          <Select
            id="targetScope"
            items={targetScopes}
            bind:value={selectedScope}
          />
        </div>
        <div class="flex-1">
          <Label for="targetSelection">Selection</Label>
          <Select
            id="targetSelection"
            items={targetSelections}
            bind:value={selectedSelection}
          />
        </div>
      </div>
      {#if "random" in target.selection}
        <div class="mt-2">
          <Label for="randomCount">Random Count</Label>
          <Input
            id="randomCount"
            type="number"
            bind:value={target.selection.random.count}
          />
        </div>
      {/if}
    </div>
  </div>
</FormTemplate>
