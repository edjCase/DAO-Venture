<script lang="ts">
  import FormTemplate from "../FormTemplate.svelte";
  import {
    Input,
    Label,
    Select,
    Badge,
    Textarea,
    MultiSelect,
    SelectOptionType,
  } from "flowbite-svelte";
  import {
    CreateWorldProposalRequest,
    UnlockRequirement,
    CharacterModifier,
  } from "../../../../ic-agent/declarations/main";
  import { TrashBinOutline } from "flowbite-svelte-icons";
  import CharacterStatIcon, {
    CharacterStatIconKind,
  } from "../../../character/CharacterStatIcon.svelte";
  import UnlockRequirementEditor from "./UnlockRequirementEditor.svelte";

  let id: string | undefined;
  let name: string | undefined;
  let description: string | undefined;
  let weaponId: string | undefined;
  let unlockRequirement: UnlockRequirement | undefined;
  let modifiers: CharacterModifier[] = [];

  let numericModifierTypes: SelectOptionType<string>[] = [
    { value: "magic", name: "Magic" },
    { value: "maxHealth", name: "Max Health" },
    { value: "gold", name: "Gold" },
    { value: "speed", name: "Speed" },
    { value: "defense", name: "Defense" },
    { value: "attack", name: "Attack" },
    { value: "health", name: "Health" },
  ];
  let selectedNumericModifierType: string = numericModifierTypes[0].value;
  let numericModifierValue: string = "";

  let traitOptions: SelectOptionType<string>[] = [
    { value: "trait1", name: "Trait 1" },
    { value: "trait2", name: "Trait 2" },
    { value: "trait3", name: "Trait 3" },
  ];
  let selectedTraits: string[] = [];

  let itemOptions: SelectOptionType<string>[] = [
    { value: "item1", name: "Item 1" },
    { value: "item2", name: "Item 2" },
    { value: "item3", name: "Item 3" },
  ];
  let selectedItems: string[] = [];

  const addNumericModifier = () => {
    if (numericModifierValue) {
      const newValue = BigInt(numericModifierValue);
      const existingIndex = modifiers.findIndex(
        (m) => selectedNumericModifierType in m
      );
      if (existingIndex !== -1) {
        const existingModifier = modifiers[existingIndex] as any;
        modifiers[existingIndex] = {
          [selectedNumericModifierType]:
            existingModifier[selectedNumericModifierType] + newValue,
        } as CharacterModifier;
      } else {
        modifiers = [
          ...modifiers,
          { [selectedNumericModifierType]: newValue } as CharacterModifier,
        ];
      }
      numericModifierValue = "";
    }
  };

  const updateModifiers = () => {
    modifiers = [
      ...modifiers.filter((m) => !("trait" in m) && !("item" in m)),
      ...selectedTraits.map((trait) => ({ trait }) as CharacterModifier),
      ...selectedItems.map((item) => ({ item }) as CharacterModifier),
    ];
  };

  $: {
    updateModifiers();
  }

  const removeModifier = (index: number) => {
    modifiers = modifiers.filter((_, i) => i !== index);
  };

  const getIconKind = (key: string): CharacterStatIconKind | undefined => {
    switch (key) {
      case "attack":
        return { attack: null };
      case "defense":
        return { defense: null };
      case "speed":
        return { speed: null };
      case "magic":
        return { magic: null };
      case "health":
        return { health: null };
      case "maxHealth":
        return { maxHealth: null };
      case "gold":
        return { gold: null };
      default:
        return undefined;
    }
  };

  const getModifierName = (key: string): string => {
    const modifierType = numericModifierTypes.find(
      (type) => type.value === key
    );
    return modifierType ? modifierType.name.toString() : key;
  };

  let generateProposal = (): CreateWorldProposalRequest | string => {
    if (
      id === undefined ||
      name === undefined ||
      description === undefined ||
      weaponId === undefined
    ) {
      return "All fields except unlock requirement must be filled";
    }
    return {
      modifyGameContent: {
        class: {
          id,
          name,
          description,
          weaponId,
          unlockRequirement: unlockRequirement ? [unlockRequirement] : [],
          modifiers,
        },
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
          placeholder="unique_class_id"
        />
      </div>

      <div class="flex-1">
        <Label for="name">Name</Label>
        <Input id="name" type="text" bind:value={name} placeholder="Warrior" />
      </div>
    </div>

    <div>
      <Label for="description">Description</Label>
      <Textarea
        id="description"
        bind:value={description}
        placeholder="A skilled fighter proficient in various weapons and armor..."
      />
    </div>

    <div>
      <Label for="weaponId">Weapon Id</Label>
      <Input
        id="weaponId"
        type="text"
        bind:value={weaponId}
        placeholder="longsword"
      />
    </div>

    <div>
      <Label for="unlockRequirement">Unlock Requirement</Label>
      <UnlockRequirementEditor bind:unlockRequirement />
    </div>

    <div>
      <Label>Numeric Modifiers</Label>
      <div class="flex gap-2 mb-2">
        <Select
          id="numericModifierType"
          items={numericModifierTypes}
          bind:value={selectedNumericModifierType}
        />
        <Input
          type="number"
          bind:value={numericModifierValue}
          placeholder="Value"
        />
        <button
          on:click={addNumericModifier}
          class="bg-blue-500 text-white px-4 py-2 rounded">Add</button
        >
      </div>
    </div>
    <div class="flex gap-4">
      <div class="flex-1">
        <Label>Traits</Label>
        <MultiSelect
          items={traitOptions}
          bind:value={selectedTraits}
          placeholder="Select traits"
          size="sm"
          dropdownClass="z-50"
        />
      </div>

      <div class="flex-1">
        <Label>Items</Label>
        <MultiSelect
          items={itemOptions}
          bind:value={selectedItems}
          placeholder="Select items"
          size="sm"
          dropdownClass=""
        />
      </div>
    </div>

    {#if modifiers.length > 0}
      <div class="flex flex-wrap text-xl gap-4">
        {#each modifiers as modifier}
          {@const key = Object.keys(modifier)[0]}
          {@const iconKind = getIconKind(key)}
          <div class="flex items-center">
            <div>
              {#if iconKind !== undefined}
                <CharacterStatIcon kind={iconKind} />
              {:else}
                <span>{getModifierName(key)}</span>
              {/if}
              : {Object.values(modifier)[0]}
            </div>
            <Badge color="red" class="ml-2 p-2">
              <button
                on:click={() => removeModifier(modifiers.indexOf(modifier))}
              >
                <TrashBinOutline size="sm" />
              </button>
            </Badge>
          </div>
        {/each}
      </div>
    {/if}
  </div>
</FormTemplate>
