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
    ActionEffect,
    ActionEffectKind,
    ActionEffectTarget,
    ActionTarget,
  } from "../../../../ic-agent/declarations/main";
  import MinMaxTimingForm from "./MinMaxTimingForm.svelte";
  import { actionStore } from "../../../../stores/ActionStore";
  import EntitySelector from "./EntitySelector.svelte";

  let id: string | undefined;
  let name: string | undefined;
  let description: string | undefined;
  let effects: ActionEffect[] = [];
  let target: ActionTarget = {
    scope: { any: null },
    selection: { all: null },
  };
  let upgradedActionId: string;

  const effectKinds: SelectOptionType<string>[] = [
    { value: "damage", name: "Damage" },
    { value: "heal", name: "Heal" },
    { value: "block", name: "Block" },
    { value: "addStatusEffect", name: "Add Status Effect" },
  ];

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

  const statusEffectKinds: SelectOptionType<string>[] = [
    { value: "weak", name: "Weak" },
    { value: "vulnerable", name: "Vulnerable" },
    { value: "stunned", name: "Stunned" },
    { value: "retaliating", name: "Retaliating" },
  ];

  function addEffect() {
    effects = [...effects, createDefaultEffect()];
  }

  function removeEffect(index: number) {
    effects = effects.filter((_, i) => i !== index);
  }

  function createDefaultEffect(): ActionEffect {
    return {
      kind: { damage: { min: 1n, max: 1n, timing: { immediate: null } } },
      target: { self: null },
    };
  }

  let updateEffectKind = (index: number) => (event: Event) => {
    let kindValue = (event.target as HTMLSelectElement).value;
    effects = effects.map((effect, i) => {
      if (i === index) {
        let newKind: ActionEffectKind;
        switch (kindValue) {
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

  let updateEffectTarget = (index: number) => (event: Event) => {
    let targetValue = (event.target as HTMLSelectElement).value;
    effects = effects.map((effect, i) => {
      if (i === index) {
        const newTarget: ActionEffectTarget =
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
    if (effects.length === 0) return "At least one effect is required";

    const action: Action = {
      id,
      name,
      description,
      effects,
      target,
      upgradedActionId: !upgradedActionId ? [] : [upgradedActionId],
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
      <Label>Effects</Label>
      {#each effects as effect, index}
        <div class="border p-4 mb-4 rounded">
          <Select
            items={effectKinds}
            on:change={updateEffectKind(index)}
            value={Object.keys(effect.kind)[0]}
          />
          {#if "damage" in effect.kind}
            <MinMaxTimingForm bind:value={effect.kind.damage} />
          {:else if "heal" in effect.kind}
            <MinMaxTimingForm bind:value={effect.kind.heal} />
          {:else if "block" in effect.kind}
            <MinMaxTimingForm bind:value={effect.kind.block} />
          {:else if "addStatusEffect" in effect.kind}
            <div class="flex gap-2 mt-2">
              <Select
                items={statusEffectKinds}
                bind:value={effect.kind.addStatusEffect.kind}
              />
              <Input
                type="number"
                bind:value={effect.kind.addStatusEffect.duration[0]}
                placeholder="Duration"
              />
            </div>
          {/if}
          <div>Target</div>
          <Select
            items={[
              { value: "targets", name: "Targets" },
              { value: "self", name: "Self" },
            ]}
            on:change={updateEffectTarget(index)}
            value={Object.keys(effect.target)[0]}
          />
          <button
            class="mt-2 bg-red-500 text-white px-2 py-1 rounded"
            on:click={() => removeEffect(index)}
          >
            Remove Effect
          </button>
        </div>
      {/each}
      <button
        class="bg-blue-500 text-white px-4 py-2 rounded"
        on:click={addEffect}
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
    <div>
      <Label for="upgradedActionId">Upgraded Action Id</Label>
      <EntitySelector
        bind:value={upgradedActionId}
        store={actionStore}
        label="Upgraded Action"
      />
    </div>
  </div>
</FormTemplate>
