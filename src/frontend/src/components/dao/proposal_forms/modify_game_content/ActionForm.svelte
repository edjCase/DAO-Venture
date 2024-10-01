<script lang="ts">
  import FormTemplate from "../FormTemplate.svelte";
  import { Input, Label, Textarea, Button } from "flowbite-svelte";
  import {
    CreateWorldProposalRequest,
    Action,
    CombatEffect,
    ActionTarget,
    ScenarioEffect,
  } from "../../../../ic-agent/declarations/main";
  import CombatEffectChooser from "./CombatEffectChooser.svelte";
  import ScenarioEffectChooser from "./ScenarioEffectChooser.svelte";
  import { PlusSolid, TrashBinSolid } from "flowbite-svelte-icons";
  import ActionTargetEditor from "./ActionTargetEditor.svelte";

  let id: string | undefined;
  let name: string | undefined;
  let description: string | undefined;
  let combatEffects: CombatEffect[] = [];
  let scenarioEffects: ScenarioEffect[] = [];
  let target: ActionTarget = {
    scope: { any: null },
    selection: { all: null },
  };

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
      <div class="flex gap-4 items-center">
        <Label>Scenario Effects</Label>
        <Button on:click={addScenarioEffect}>
          <PlusSolid size="xs" />
        </Button>
      </div>
      {#each scenarioEffects as effect, index}
        <div class="p-4 mb-4">
          <div class="flex gap-4 items-center">
            <Label>Effect {index + 1}</Label>
            <Button on:click={() => removeScenarioEffect(index)} color="red">
              <TrashBinSolid size="xs" />
            </Button>
          </div>
          <ScenarioEffectChooser value={effect} />
        </div>
      {/each}
    </div>

    <div>
      <div class="flex gap-4 items-center">
        <Label>Combat Effects</Label>
        <Button on:click={addCombatEffect}>
          <PlusSolid size="xs" />
        </Button>
      </div>
      {#each combatEffects as effect, index}
        <div class="border p-4 mb-4">
          <div class="flex gap-4 items-center">
            <Label>Effect {index + 1}</Label>
            <Button on:click={() => removeCombatEffect(index)} color="red">
              <TrashBinSolid size="xs" />
            </Button>
          </div>
          <CombatEffectChooser bind:value={effect} />
        </div>
      {/each}
    </div>

    <ActionTargetEditor bind:value={target} />
  </div>
</FormTemplate>
