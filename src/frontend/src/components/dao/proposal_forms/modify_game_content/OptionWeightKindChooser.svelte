<script lang="ts">
  import { Select } from "flowbite-svelte";
  import { WeightKind } from "../../../../ic-agent/declarations/main";
  import CharacterAttributeChooser from "./CharacterAttributeChooser.svelte";

  export let value: WeightKind;

  const items = [
    { value: "raw", name: "Raw" },
    { value: "attributeScaled", name: "Attribute Scaled" },
  ];

  let selectedEffect: string = Object.keys(value)[0];

  const updateEffect = () => {
    if (selectedEffect === "raw") {
      value = { raw: null };
    } else if (selectedEffect === "attributeScaled") {
      value = { attributeScaled: { dexterity: null } };
    }
  };
</script>

<Select {items} bind:value={selectedEffect} on:change={updateEffect} />
{#if "attributeScaled" in value}
  <CharacterAttributeChooser bind:value={value.attributeScaled} />
{/if}
