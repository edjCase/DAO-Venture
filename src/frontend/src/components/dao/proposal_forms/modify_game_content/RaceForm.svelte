<script lang="ts">
  import FormTemplate from "../FormTemplate.svelte";
  import { Input, Label, Textarea } from "flowbite-svelte";
  import {
    CreateWorldProposalRequest,
    Race,
    UnlockRequirement,
  } from "../../../../ic-agent/declarations/main";
  import UnlockRequirementEditor from "./UnlockRequirementEditor.svelte";
  import { actionStore } from "../../../../stores/ActionStore";
  import { itemStore } from "../../../../stores/ItemStore";
  import EntityMultiSelector from "./EntityMultiSelector.svelte";
  import {
    decodeImageToPixels,
    encodePixelsToImage,
    generatePixelGrid,
    PixelGrid,
  } from "../../../../utils/PixelUtil";
  import PixelArtEditor from "../../../common/PixelArtEditor.svelte";

  export let value: Race | undefined;

  let id: string | undefined = value?.id;
  let name: string | undefined = value?.name;
  let description: string | undefined = value?.description;
  let pixels: PixelGrid = value?.image
    ? decodeImageToPixels(value.image, 32, 32)
    : generatePixelGrid(32, 32);
  let unlockRequirement: UnlockRequirement | undefined =
    value?.unlockRequirement[0];

  let selectedActions: string[] = value?.startingSkillActionIds ?? [];
  let selectedItems: string[] = value?.startingItemIds ?? [];

  let generateProposal = (): CreateWorldProposalRequest | string => {
    if (id === undefined || name === undefined || description === undefined) {
      return "All fields except unlock requirement must be filled";
    }
    return {
      modifyGameContent: {
        race: {
          id,
          name,
          description,
          startingSkillActionIds: selectedActions,
          startingItemIds: selectedItems,
          image: encodePixelsToImage(pixels),
          unlockRequirement: unlockRequirement ? [unlockRequirement] : [],
        },
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
          placeholder="unique_race_id"
        />
      </div>

      <div class="flex-1">
        <Label for="name">Name</Label>
        <Input id="name" type="text" bind:value={name} placeholder="Human" />
      </div>
    </div>

    <div>
      <Label for="description">Description</Label>
      <Textarea
        id="description"
        bind:value={description}
        placeholder="Humans are versatile and adaptable..."
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
      <Label>Items</Label>
      <EntityMultiSelector
        bind:ids={selectedItems}
        store={itemStore}
        label="Items"
      />
    </div>

    <div>
      <Label>Image</Label>
      <PixelArtEditor bind:pixels pixelSize={8} />
    </div>

    <div>
      <Label for="unlockRequirement">Unlock Requirement</Label>
      <UnlockRequirementEditor bind:unlockRequirement />
    </div>
  </div>
</FormTemplate>
