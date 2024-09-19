<script lang="ts">
  import { Select } from "flowbite-svelte";
  import { Attribute } from "../../../../ic-agent/declarations/main";

  export let value: Attribute;

  let items = [
    { value: "strength", name: "Strength" },
    { value: "dexterity", name: "Dexterity" },
    { value: "wisdom", name: "Wisdom" },
    { value: "charisma", name: "Charisma" },
  ];

  let selectedAttribute: string = Object.keys(value)[0];

  let updateAttribute = () => {
    switch (selectedAttribute) {
      case "strength":
        value = { strength: null };
        break;
      case "dexterity":
        value = { dexterity: null };
        break;
      case "wisdom":
        value = { wisdom: null };
        break;
      case "charisma":
        value = { charisma: null };
        break;
      default:
        throw new Error("Invalid attribute: " + selectedAttribute);
    }
  };
</script>

<Select {items} bind:value={selectedAttribute} on:change={updateAttribute} />
