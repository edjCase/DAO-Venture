<script lang="ts">
  import { Input, Select } from "flowbite-svelte";
  import { AttributeChoiceRequirement } from "../../../../ic-agent/declarations/main";
  import { toJsonString } from "../../../../utils/StringUtil";

  export let value: AttributeChoiceRequirement;

  let attributeItems = [
    { name: "Strength", value: "strength" },
    { name: "Wisdom", value: "wisdom" },
    { name: "Dexterity", value: "dexterity" },
    { name: "Charisma", value: "charisma" },
  ];
  let selectedAttribute = Object.keys(value.attribute)[0];

  function handleAttributeChange() {
    switch (selectedAttribute) {
      case "strength":
        value.attribute = { strength: null };
        break;
      case "wisdom":
        value.attribute = { wisdom: null };
        break;
      case "dexterity":
        value.attribute = { dexterity: null };
        break;
      case "charisma":
        value.attribute = { charisma: null };
        break;
    }
  }
</script>

<Select
  items={attributeItems}
  bind:value={selectedAttribute}
  on:change={handleAttributeChange}
/>

<span>
  {#if "strength" in value.attribute}
    Strength
  {:else if "wisdom" in value.attribute}
    Wisdom
  {:else if "dexterity" in value.attribute}
    Dexterity
  {:else if "charisma" in value.attribute}
    Charisma
  {:else}
    NOT IMPLMENETED ATTRIBUTE {toJsonString(value.attribute)}
  {/if}
</span>

<Input type="number" bind:value={value.value} />
