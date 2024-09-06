<script lang="ts">
  import {
    Choice,
    ChoiceRequirement,
  } from "../../../../ic-agent/declarations/main";
  import { Input, Label, Textarea, Select } from "flowbite-svelte";
  import ChoiceRequirementEditor from "./ChoiceRequirementEditor.svelte";

  export let value: Choice;

  let requirementTypes = [
    { value: "none", name: "None" },
    { value: "trait", name: "Trait" },
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

<div class="border p-4 mb-4 rounded">
  <Label for="id">Id</Label>
  <Input id="id" type="text" bind:value={value.id} placeholder="choice_id" />

  <Label for="description">Description</Label>
  <Textarea
    id="description"
    bind:value={value.description}
    placeholder="Describe the choice..."
  />

  <Label for="pathId">Path Id</Label>
  <Input
    id="pathId"
    type="text"
    bind:value={value.pathId}
    placeholder="path_id"
  />

  <Label for="requirement">Requirement</Label>
  <Select
    id="requirement"
    items={requirementTypes}
    bind:value={selectedRequirementType}
  />
  {#if value.requirement[0] !== undefined}
    <ChoiceRequirementEditor bind:value={value.requirement[0]} />
  {/if}
</div>
