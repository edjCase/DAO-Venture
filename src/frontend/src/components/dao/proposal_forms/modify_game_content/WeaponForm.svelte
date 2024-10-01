<script lang="ts">
  import FormTemplate from "../FormTemplate.svelte";
  import { Input, Label, Textarea } from "flowbite-svelte";
  import {
    CreateWorldProposalRequest,
    Weapon,
    UnlockRequirement,
  } from "../../../../ic-agent/declarations/main";
  import UnlockRequirementChooser from "./UnlockRequirementChooser.svelte";
  import { actionStore } from "../../../../stores/ActionStore";
  import EntityMultiSelector from "./EntityMultiSelector.svelte";
  import {
    decodeImageToPixels,
    encodePixelsToImage,
    generatePixelGrid,
    PixelGrid,
  } from "../../../../utils/PixelUtil";
  import PixelArtEditor from "../../../common/PixelArtEditor.svelte";

  export let value: Weapon | undefined;

  let id: string | undefined = value?.id;
  let name: string | undefined = value?.name;
  let description: string | undefined = value?.description;
  let actionIds: string[] = value?.actionIds ?? [];
  let unlockRequirement: UnlockRequirement = value?.unlockRequirement ?? {
    none: null,
  };
  let pixels: PixelGrid = value?.image
    ? decodeImageToPixels(value.image, 32, 32)
    : generatePixelGrid(32, 32);
  let selectedActions: string[] = value?.actionIds ?? [];

  const generateProposal = (): CreateWorldProposalRequest | string => {
    if (id === undefined || name === undefined || description === undefined) {
      return "All fields except unlock requirement must be filled";
    }

    const weapon: Weapon = {
      id,
      name,
      description,
      actionIds,
      image: encodePixelsToImage(pixels),
      unlockRequirement: unlockRequirement,
    };

    return {
      modifyGameContent: {
        weapon,
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
          placeholder="unique_weapon_id"
        />
      </div>
      <div class="flex-1">
        <Label for="name">Name</Label>
        <Input
          id="name"
          type="text"
          bind:value={name}
          placeholder="Excalibur"
        />
      </div>
    </div>

    <div>
      <Label for="description">Description</Label>
      <Textarea
        id="description"
        bind:value={description}
        placeholder="A legendary sword of immense power..."
      />
    </div>

    <div>
      <Label>Actions</Label>
      <EntityMultiSelector
        bind:ids={selectedActions}
        store={actionStore}
        label="Actions"
      />
    </div>

    <div>
      <Label>Image</Label>
      <PixelArtEditor bind:pixels pixelSize={8} />
    </div>

    <div>
      <Label for="unlockRequirement">Unlock Requirement</Label>
      <UnlockRequirementChooser bind:unlockRequirement />
    </div>
  </div>
</FormTemplate>
