<script lang="ts">
  import { Label, Select } from "flowbite-svelte";
  import ChoiceRequirementEditor from "./ChoiceRequirementEditor.svelte";
  import ChoiceRequirement from "../../../scenario/ChoiceRequirement.svelte";

  export let value: ChoiceRequirement;

  let requirementTypes = [
    { value: "none", name: "None" },
    { value: "item", name: "Item" },
    { value: "gold", name: "Gold" },
    { value: "class", name: "Class" },
    { value: "race", name: "Race" },
    { value: "all", name: "All" },
    { value: "any", name: "Any" },
  ];

  let selectedRequirementType = "none";

  $: {
    if (selectedRequirementType === "none") {
      value.requirement = [];
    } else if (
      selectedRequirementType !== "all" &&
      selectedRequirementType !== "any"
    ) {
      value.requirement = [
        { [selectedRequirementType]: "" } as ChoiceRequirement,
      ];
    } else {
      value.requirement = [
        { [selectedRequirementType]: "" } as ChoiceRequirement,
      ];
    }
  }
</script>

<Label for="requirement">Requirement</Label>
<Select
  id="requirement"
  items={requirementTypes}
  bind:value={selectedRequirementType}
/>
{#if value.requirement[0] !== undefined}
  <ChoiceRequirementEditor bind:value={value.requirement[0]} />
{/if}
