<script lang="ts">
  import FormTemplate from "../FormTemplate.svelte";
  import { Input, Label, Textarea } from "flowbite-svelte";
  import {
    CreateWorldProposalRequest,
    Weapon,
    UnlockRequirement,
  } from "../../../../ic-agent/declarations/main";
  import UnlockRequirementEditor from "./UnlockRequirementEditor.svelte";
  import { actionStore } from "../../../../stores/ActionStore";
  import EntityMultiSelector from "./EntityMultiSelector.svelte";
  import {
    encodePixelsToImage,
    generatePixelGrid,
    PixelGrid,
  } from "../../../../utils/PixelUtil";
  import PixelArtEditor from "../../../common/PixelArtEditor.svelte";

  let id: string | undefined;
  let name: string | undefined;
  let description: string | undefined;
  let actionIds: string[] = [];
  let unlockRequirement: UnlockRequirement | undefined;
  let pixels: PixelGrid = generatePixelGrid(32, 32);
  let selectedActions: string[] = [];

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
      unlockRequirement: unlockRequirement ? [unlockRequirement] : [],
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
      <PixelArtEditor bind:pixels previewPixelSize={2} pixelSize={8} />
    </div>

    <div>
      <Label for="unlockRequirement">Unlock Requirement</Label>
      <UnlockRequirementEditor bind:unlockRequirement />
    </div>
  </div>
</FormTemplate>
