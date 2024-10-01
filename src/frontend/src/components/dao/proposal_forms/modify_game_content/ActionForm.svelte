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
    ActionTarget,
    ScenarioEffect,
  } from "../../../../ic-agent/declarations/main";
  import CombatEffectChooser from "./CombatEffectChooser.svelte";
  import ScenarioEffectChooser from "./ScenarioEffectChooser.svelte";

  let id: string | undefined;
  let name: string | undefined;
  let description: string | undefined;
  let combatEffects: CombatEffect[] = [];
  let scenarioEffects: ScenarioEffect[] = [];
  let target: ActionTarget = {
    scope: { any: null },
    selection: { all: null },
  };

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

  function addScenarioEffect() {
    scenarioEffects = [...scenarioEffects, createDefaultScenarioEffect()];
  }

  function removeScenarioEffect(index: number) {
    scenarioEffects = scenarioEffects.filter((_, i) => i !== index);
  }

  function createDefaultScenarioEffect(): ScenarioEffect {
    return {
      attribute: { value: 1n, attribute: { strength: null } },
    };
  }
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
      <Label>Scenario Effects</Label>
      {#each scenarioEffects as effect, index}
        <div class="border p-4 mb-4">
          <ScenarioEffectChooser value={effect} />
          <button
            class="mt-2 bg-red-500 text-white px-2 py-1"
            on:click={() => removeScenarioEffect(index)}
          >
            Remove Effect
          </button>
        </div>
      {/each}
      <button
        class="bg-blue-500 text-white px-4 py-2"
        on:click={addScenarioEffect}
      >
        Add Effect
      </button>
    </div>

    <div>
      <Label>Combat Effects</Label>
      {#each combatEffects as effect, index}
        <div class="border p-4 mb-4">
          <CombatEffectChooser bind:value={effect} />
          <button
            class="mt-2 bg-red-500 text-white px-2 py-1"
            on:click={() => removeCombatEffect(index)}
          >
            Remove Effect
          </button>
        </div>
      {/each}
      <button
        class="bg-blue-500 text-white px-4 py-2"
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
