<script lang="ts">
  import {
    Label,
    Select,
    Input,
    MultiSelect,
    Badge,
    SelectOptionType,
  } from "flowbite-svelte";
  import { TrashBinOutline } from "flowbite-svelte-icons";
  import { CharacterModifier } from "../../../../ic-agent/declarations/main";
  import CharacterStatIcon, {
    getIconKind,
  } from "../../../character/CharacterStatIcon.svelte";
  import { onMount } from "svelte";
  import { mainAgentFactory } from "../../../../ic-agent/Main";

  export let modifiers: CharacterModifier[];

  let numericModifiers: CharacterModifier[] = [];
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

  let traitOptions: SelectOptionType<string>[] = [];
  let selectedTraits: string[] = [];

  let itemOptions: SelectOptionType<string>[] = [];
  let selectedItems: string[] = [];

  onMount(async () => {
    let mainAgent = await mainAgentFactory();

    try {
      const [traits, items] = await Promise.all([
        mainAgent.getTraits(),
        mainAgent.getItems(),
      ]);

      traitOptions = traits.map((trait) => ({
        value: trait.id,
        name: trait.name,
      }));

      itemOptions = items.map((item) => ({
        value: item.id,
        name: item.name,
      }));
    } catch (error) {
      console.error("Error fetching data:", error);
      // Handle the error appropriately
    }
  });

  const addNumericModifier = () => {
    if (numericModifierValue) {
      const newValue = BigInt(numericModifierValue);
      const existingIndex = numericModifiers.findIndex(
        (m) => selectedNumericModifierType in m
      );
      if (existingIndex !== -1) {
        const existingModifier = numericModifiers[existingIndex] as any;
        numericModifiers[existingIndex] = {
          [selectedNumericModifierType]:
            existingModifier[selectedNumericModifierType] + newValue,
        } as CharacterModifier;
      } else {
        numericModifiers = [
          ...numericModifiers,
          { [selectedNumericModifierType]: newValue } as CharacterModifier,
        ];
      }
      numericModifierValue = "";
      updateModifiers();
    }
  };

  const removeNumericModifier = (index: number) => {
    numericModifiers = numericModifiers.filter((_, i) => i !== index);
    updateModifiers();
  };

  const updateModifiers = () => {
    modifiers = [
      ...numericModifiers,
      ...selectedTraits.map((trait) => ({ trait }) as CharacterModifier),
      ...selectedItems.map((item) => ({ item }) as CharacterModifier),
    ];
  };

  $: {
    updateModifiers();
  }

  const getModifierName = (key: string): string => {
    const modifierType = numericModifierTypes.find(
      (type) => type.value === key
    );
    return modifierType ? modifierType.name.toString() : key;
  };
</script>

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

{#if numericModifiers.length > 0}
  <div class="flex flex-wrap text-xl gap-4">
    {#each numericModifiers as modifier, index}
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
          <button on:click={() => removeNumericModifier(index)}>
            <TrashBinOutline size="sm" />
          </button>
        </Badge>
      </div>
    {/each}
  </div>
{/if}

<div>
  <Label>Traits</Label>
  <MultiSelect
    items={traitOptions}
    bind:value={selectedTraits}
    placeholder="Select traits"
    size="lg"
    dropdownClass="z-50"
    on:change={updateModifiers}
  />
</div>

<div>
  <Label>Items</Label>
  <MultiSelect
    items={itemOptions}
    bind:value={selectedItems}
    placeholder="Select items"
    size="lg"
    dropdownClass=""
    on:change={updateModifiers}
  />
</div>
