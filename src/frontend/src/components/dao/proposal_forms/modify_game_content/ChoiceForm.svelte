<script lang="ts">
  import {
    Choice,
    ChoiceRequirement,
  } from "../../../../ic-agent/declarations/main";
  import { Input, Label, Textarea, Select } from "flowbite-svelte";

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
        { [selectedRequirementType]: [] } as ChoiceRequirement,
      ];
    }
  }

  function addSubRequirement() {
    if (
      value.requirement &&
      ("all" in value.requirement || "any" in value.requirement)
    ) {
      value.requirement[selectedRequirementType].push({ trait: "" });
    }
  }

  function removeSubRequirement(index: number) {
    if (
      value.requirement &&
      ("all" in value.requirement || "any" in value.requirement)
    ) {
      value.requirement[selectedRequirementType] = value.requirement[
        selectedRequirementType
      ].filter((_, i) => i !== index);
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

  {#if selectedRequirementType === "trait" || selectedRequirementType === "item" || selectedRequirementType === "class" || selectedRequirementType === "race"}
    <Input
      type="text"
      bind:value={value.requirement[0].trait}
      placeholder={`Enter ${selectedRequirementType}`}
    />
  {:else if selectedRequirementType === "gold"}
    <Input
      type="number"
      bind:value={value.requirement.gold}
      placeholder="Enter gold amount"
    />
  {:else if selectedRequirementType === "all" || selectedRequirementType === "any"}
    {#each value.requirement[selectedRequirementType] as subReq, index}
      <div class="flex gap-2 mt-2">
        <Select
          items={requirementTypes.filter(
            (r) => r.value !== "none" && r.value !== "all" && r.value !== "any"
          )}
          bind:value={Object.keys(subReq)[0]}
        />
        <Input
          type="text"
          bind:value={subReq[Object.keys(subReq)[0]]}
          placeholder={`Enter ${Object.keys(subReq)[0]}`}
        />
        <button
          class="bg-red-500 text-white px-2 py-1 rounded"
          on:click={() => removeSubRequirement(index)}>Remove</button
        >
      </div>
    {/each}
    <button
      class="bg-blue-500 text-white px-2 py-1 rounded mt-2"
      on:click={addSubRequirement}>Add Sub-requirement</button
    >
  {/if}
</div>
