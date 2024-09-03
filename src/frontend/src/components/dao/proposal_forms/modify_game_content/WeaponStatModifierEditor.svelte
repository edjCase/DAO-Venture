<script lang="ts">
  import { Select, Input, Badge } from "flowbite-svelte";
  import { TrashBinOutline } from "flowbite-svelte-icons";
  import type {
    CharacterStatKind__1,
    StatModifier,
    WeaponAttribute,
  } from "../../../../ic-agent/declarations/main";

  export let statModifiers: StatModifier[];

  enum WeaponAttributeEnum {
    Damage = "damage",
    Attacks = "attacks",
    CriticalChance = "criticalChance",
    MaxDamage = "maxDamage",
    MinDamage = "minDamage",
    CriticalMultiplier = "criticalMultiplier",
    Accuracy = "accuracy",
  }

  enum CharacterStatEnum {
    Magic = "magic",
    Gold = "gold",
    Speed = "speed",
    Defense = "defense",
    Attack = "attack",
    Health = "health",
  }

  let selectedStatAttribute: WeaponAttributeEnum = WeaponAttributeEnum.Damage;
  let selectedCharacterStat: CharacterStatEnum = CharacterStatEnum.Attack;
  let statModifierFactor: number = 1;

  const weaponAttributeOptions = Object.entries(WeaponAttributeEnum).map(
    ([key, value]) => ({ value, name: key })
  );
  const characterStatOptions = Object.entries(CharacterStatEnum).map(
    ([key, value]) => ({ value, name: key })
  );

  const addStatModifier = () => {
    statModifiers = [
      ...statModifiers,
      {
        attribute: { [selectedStatAttribute]: null } as WeaponAttribute,
        characterStat: {
          [selectedCharacterStat]: null,
        } as CharacterStatKind__1,
        factor: statModifierFactor,
      },
    ];
  };

  const removeStatModifier = (index: number) => {
    statModifiers = statModifiers.filter((_, i) => i !== index);
  };
</script>

<div>
  <div class="flex gap-2 mb-2">
    <Select bind:value={selectedStatAttribute} items={weaponAttributeOptions} />
    <Select bind:value={selectedCharacterStat} items={characterStatOptions} />
    <Input type="number" bind:value={statModifierFactor} placeholder="Factor" />
    <button
      on:click={addStatModifier}
      class="bg-blue-500 text-white px-4 py-2 rounded">Add</button
    >
  </div>
  {#each statModifiers as modifier, index}
    <div class="flex items-center gap-2 bg-gray-100 rounded p-2 mb-2">
      <span>{Object.keys(modifier.attribute)[0]}</span>
      <span>{Object.keys(modifier.characterStat)[0]}</span>
      <span>{modifier.factor}</span>
      <Badge color="red" class="ml-auto">
        <button on:click={() => removeStatModifier(index)}>
          <TrashBinOutline size="sm" />
        </button>
      </Badge>
    </div>
  {/each}
</div>
