<script lang="ts">
  import FormTemplate from "../FormTemplate.svelte";
  import {
    Input,
    Label,
    Textarea,
    Button,
    Accordion,
    AccordionItem,
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
  import {
    decodeImageToPixels,
    encodePixelsToImage,
    generatePixelGrid,
    PixelGrid,
  } from "../../../../utils/PixelUtil";
  import PixelArtEditor from "../../../common/PixelArtEditor.svelte";
  import { PlusSolid, TrashBinSolid } from "flowbite-svelte-icons";
  import ScenarioCategoryChooser from "./ScenarioCategoryChooser.svelte";
  import LocationKindChooser from "./LocationKindChooser.svelte";

  export let value: ScenarioMetaData | undefined;

  let id: string | undefined = value?.id;
  let name: string | undefined = value?.name;
  let description: string | undefined = value?.description;
  let pixels: PixelGrid = value?.image
    ? decodeImageToPixels(value.image, 64, 64)
    : generatePixelGrid(64, 64);
  let paths: ScenarioPath[] = value?.paths ?? [];
  let location: LocationKind = value?.location ?? { common: null };
  let category: ScenarioCategory = value?.category ?? { other: null };
  let unlockRequirement: UnlockRequirement | undefined =
    value?.unlockRequirement[0];

  function addPath() {
    paths = [
      ...paths,
      {
        id: "",
        kind: { choice: { choices: [] } },
        description: "",
      },
    ];
  }

  function removePath(index: number) {
    paths = paths.filter((_, i) => i !== index);
  }

  let generateProposal = (): CreateWorldProposalRequest | string => {
    if (!id) return "Id must be filled";
    if (!name) return "Name must be filled";
    if (!description) return "Description must be filled";

    const scenario: ScenarioMetaData = {
      id,
      name,
      description,
      image: encodePixelsToImage(pixels),
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
      <Label>Image</Label>
      <PixelArtEditor bind:pixels pixelSize={8} />
    </div>

    <div>
      <div class="flex items-center gap-2">
        <Label>Paths</Label>
        <Button on:click={addPath}><PlusSolid size="xs" /></Button>
      </div>
      <Accordion>
        {#each paths as path, index}
          <AccordionItem>
            <div
              slot="header"
              class="flex items-center justify-between pr-10 w-full"
            >
              <span
                >{path.id}
                {#if index === 0}
                  (Initial Path)
                {/if}
              </span>
              <Button on:click={() => removePath(index)} color="red">
                <TrashBinSolid size="xs" />
              </Button>
            </div>
            <ScenarioPathForm bind:value={path} />
          </AccordionItem>
        {/each}
      </Accordion>
    </div>

    <div>
      <Label for="category">Category</Label>
      <ScenarioCategoryChooser bind:value={category} />
    </div>

    <div>
      <Label for="location">Location</Label>
      <LocationKindChooser bind:value={location} />
    </div>

    <div>
      <Label for="unlockRequirement">Unlock Requirement</Label>
      <UnlockRequirementEditor bind:unlockRequirement />
    </div>
  </div>
</FormTemplate>
