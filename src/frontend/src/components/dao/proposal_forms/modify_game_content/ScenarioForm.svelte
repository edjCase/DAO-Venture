<script lang="ts">
  import FormTemplate from "../FormTemplate.svelte";
  import {
    Input,
    Label,
    Textarea,
    Select,
    SelectOptionType,
  } from "flowbite-svelte";
  import {
    CreateWorldProposalRequest,
    ScenarioMetaData,
    ScenarioPath,
    LocationKind,
    ScenarioCategory,
    UnlockRequirement,
  } from "../../../../ic-agent/declarations/main";
  import UnlockRequirementEditor from "./UnlockRequirementEditor.svelte";
  import ScenarioPathForm from "./ScenarioPathForm.svelte";

  let id: string | undefined;
  let name: string | undefined;
  let description: string | undefined;
  let imageId: string | undefined;
  let paths: ScenarioPath[] = [];
  let location: LocationKind = { common: null };
  let category: ScenarioCategory = { other: null };
  let unlockRequirement: UnlockRequirement | undefined;

  const categories: SelectOptionType<string>[] = [
    { value: "other", name: "Other" },
    { value: "store", name: "Store" },
    { value: "combat", name: "Combat" },
  ];

  const locationTypes: SelectOptionType<string>[] = [
    { value: "common", name: "Common" },
    { value: "zoneIds", name: "Specific Zones" },
  ];
  let selectedLocationType: string = locationTypes[0].value;

  let zoneIds: string[] = [];

  function addPath() {
    paths = [
      ...paths,
      {
        id: "",
        kind: { choice: { choices: [] } },
        description: "",
        nextPathOptions: [],
      },
    ];
  }

  function removePath(index: number) {
    paths = paths.filter((_, i) => i !== index);
  }

  $: {
    location =
      selectedLocationType === "common"
        ? { common: null }
        : { zoneIds: zoneIds };
  }

  let generateProposal = (): CreateWorldProposalRequest | string => {
    if (!id) return "Id must be filled";
    if (!name) return "Name must be filled";
    if (!description) return "Description must be filled";
    if (!imageId) return "Image Id must be filled";

    const scenario: ScenarioMetaData = {
      id,
      name,
      description,
      imageId,
      paths,
      location,
      category,
      unlockRequirement: unlockRequirement ? [unlockRequirement] : [],
    };

    return {
      modifyGameContent: {
        scenario,
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
          placeholder="unique_scenario_id"
        />
      </div>
      <div class="flex-1">
        <Label for="name">Name</Label>
        <Input
          id="name"
          type="text"
          bind:value={name}
          placeholder="Epic Battle"
        />
      </div>
    </div>

    <div>
      <Label for="description">Description</Label>
      <Textarea
        id="description"
        bind:value={description}
        placeholder="An epic battle unfolds..."
      />
    </div>

    <div>
      <Label for="imageId">Image Id</Label>
      <Input
        id="imageId"
        type="text"
        bind:value={imageId}
        placeholder="epic_battle_image"
      />
    </div>

    <div>
      <Label>Outcome Paths</Label>
      {#each paths as path, index}
        <ScenarioPathForm bind:value={path} />
        <button
          class="mt-2 bg-red-500 text-white px-2 py-1 rounded"
          on:click={() => removePath(index)}
        >
          Remove Path
        </button>
      {/each}
      <button
        class="bg-blue-500 text-white px-4 py-2 rounded"
        on:click={addPath}
      >
        Add Path
      </button>
    </div>

    <div>
      <Label for="category">Category</Label>
      <Select id="category" items={categories} bind:value={category} />
    </div>

    <div>
      <Label for="location">Location</Label>
      <Select
        id="location"
        items={locationTypes}
        bind:value={selectedLocationType}
      />
      {#if selectedLocationType === "zoneIds"}
        <Input
          type="text"
          bind:value={zoneIds}
          placeholder="zone1,zone2,zone3"
        />
      {/if}
    </div>

    <div>
      <Label for="unlockRequirement">Unlock Requirement</Label>
      <UnlockRequirementEditor bind:unlockRequirement />
    </div>
  </div>
</FormTemplate>
