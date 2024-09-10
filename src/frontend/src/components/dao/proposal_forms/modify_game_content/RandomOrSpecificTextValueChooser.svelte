<script lang="ts">
  import { Select } from "flowbite-svelte";
  import { RandomOrSpecificTextValue } from "../../../../ic-agent/declarations/main";
  import RandomOrSpecificTextValueEditor from "./RandomOrSpecificTextValueEditor.svelte";
  export let value: RandomOrSpecificTextValue;

  let options = [
    {
      name: "Random",
      value: "random",
    },
    {
      name: "Specific",
      value: "specific",
    },
  ];

  let selectedOption = options[0].value;

  function updateValue() {
    if (selectedOption === "random") {
      value = { random: null };
    } else {
      value = { specific: { raw: "" } };
    }
  }
</script>

<Select bind:value={selectedOption} items={options} on:change={updateValue} />
<RandomOrSpecificTextValueEditor bind:value />
