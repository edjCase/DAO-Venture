<script lang="ts">
  import FormTemplate from "../FormTemplate.svelte";
  import { Input, Label, Textarea, Select, Badge } from "flowbite-svelte";
  import {
    CreateWorldProposalRequest,
    Weapon,
    WeaponStats,
    WeaponRequirement,
    UnlockRequirement,
  } from "../../../../ic-agent/declarations/main";
  import UnlockRequirementEditor from "./UnlockRequirementEditor.svelte";
  import WeaponStatModifierEditor from "./WeaponStatModifierEditor.svelte";
  import { TrashBinOutline } from "flowbite-svelte-icons";

  let id: string | undefined;
  let name: string | undefined;
  let description: string | undefined;
  let unlockRequirement: UnlockRequirement | undefined;

  // Base Stats
  let baseStats: WeaponStats = {
    attacks: 1n,
    criticalChance: 5n,
    maxDamage: 10n,
    minDamage: 5n,
    statModifiers: [],
    criticalMultiplier: 2n,
    accuracy: 90n,
  };

  // Requirements
  let requirements: WeaponRequirement[] = [];

  enum RequirementType {
    Attack = "attack",
    Defense = "defense",
    Speed = "speed",
    Magic = "magic",
    MaxHealth = "maxHealth",
  }

  let selectedRequirement: RequirementType = RequirementType.Attack;
  let requirementValue: bigint = 1n;

  const addRequirement = () => {
    requirements = [
      ...requirements,
      { [selectedRequirement]: requirementValue } as WeaponRequirement,
    ];
  };

  const removeRequirement = (index: number) => {
    requirements = requirements.filter((_, i) => i !== index);
  };

  const generateProposal = (): CreateWorldProposalRequest | string => {
    if (id === undefined || name === undefined || description === undefined) {
      return "All fields except unlock requirement must be filled";
    }

    const weapon: Weapon = {
      id,
      name,
      description,
      baseStats,
      requirements,
      unlockRequirement: unlockRequirement ? [unlockRequirement] : [],
    };

    return {
      modifyGameContent: {
        weapon,
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
          placeholder="unique_weapon_id"
        />
      </div>
      <div class="flex-1">
        <Label for="name">Name</Label>
        <Input
          id="name"
          type="text"
          bind:value={name}
          placeholder="Excalibur"
        />
      </div>
    </div>

    <div>
      <Label for="description">Description</Label>
      <Textarea
        id="description"
        bind:value={description}
        placeholder="A legendary sword of immense power..."
      />
    </div>

    <div>
      <Label>Base Stats</Label>
      <div class="grid grid-cols-2 gap-4">
        <div>
          <Label>Attacks</Label>
          <Input type="number" bind:value={baseStats.attacks} label="Attacks" />
        </div>
        <div>
          <Label>Max Damage</Label>
          <Input
            type="number"
            bind:value={baseStats.maxDamage}
            label="Max Damage"
          />
        </div>
        <div>
          <Label>Min Damage</Label>
          <Input
            type="number"
            bind:value={baseStats.minDamage}
            label="Min Damage"
          />
        </div>
        <div>
          <Label>Accuracy</Label>
          <Input
            type="number"
            bind:value={baseStats.accuracy}
            label="Accuracy"
          />
        </div>
        <div>
          <Label>Critical Multiplier</Label>
          <Input
            type="number"
            bind:value={baseStats.criticalMultiplier}
            label="Critical Multiplier"
          />
        </div>
        <div>
          <Label>Critical Chance</Label>
          <Input
            type="number"
            bind:value={baseStats.criticalChance}
            label="Critical Chance"
          />
        </div>
        ``
      </div>
    </div>

    <div>
      <Label>Stat Modifiers</Label>
      <WeaponStatModifierEditor bind:statModifiers={baseStats.statModifiers} />
    </div>

    <div>
      <Label>Requirements</Label>
      <div class="flex gap-2 mb-2">
        <Select
          bind:value={selectedRequirement}
          items={Object.entries(RequirementType).map(([key, value]) => ({
            value,
            name: key,
          }))}
        />
        <Input
          type="number"
          bind:value={requirementValue}
          placeholder="Value"
        />
        <button
          on:click={addRequirement}
          class="bg-blue-500 text-white px-4 py-2 rounded">Add</button
        >
      </div>
      {#each requirements as requirement, index}
        <div class="flex items-center gap-2 bg-gray-100 rounded p-2 mb-2">
          <span>{Object.keys(requirement)[0]}</span>
          <span>{Object.values(requirement)[0]}</span>
          <Badge color="red" class="ml-auto">
            <button on:click={() => removeRequirement(index)}>
              <TrashBinOutline size="sm" />
            </button>
          </Badge>
        </div>
      {/each}
    </div>

    <div>
      <Label for="unlockRequirement">Unlock Requirement</Label>
      <UnlockRequirementEditor bind:unlockRequirement />
    </div>
  </div>
</FormTemplate>
