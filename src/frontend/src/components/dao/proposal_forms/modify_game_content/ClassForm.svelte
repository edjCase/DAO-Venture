<script lang="ts">
  import FormTemplate from "../FormTemplate.svelte";
  import { Input, Label, Textarea } from "flowbite-svelte";
  import {
    CreateWorldProposalRequest,
    UnlockRequirement,
  } from "../../../../ic-agent/declarations/main";
  import UnlockRequirementEditor from "./UnlockRequirementEditor.svelte";
  import EntityMultiSelector from "./EntityMultiSelector.svelte";
  import { actionStore } from "../../../../stores/ActionStore";
  import { itemStore } from "../../../../stores/ItemStore";
  import PixelArtEditor from "../../../common/PixelArtEditor.svelte";
  import {
    encodePixelsToImage,
    generatePixelGrid,
    PixelGrid,
  } from "../../../../utils/PixelUtil";

  let id: string | undefined;
  let name: string | undefined;
  let description: string | undefined;
  let weaponId: string | undefined;
  let unlockRequirement: UnlockRequirement | undefined;
  let pixels: PixelGrid = generatePixelGrid(32, 32);
  let selectedActions: string[] = [];
  let selectedItems: string[] = [];

  let generateProposal = (): CreateWorldProposalRequest | string => {
    if (id === undefined) {
      return "Id must be filled";
    }
    if (name === undefined) {
      return "Name must be filled";
    }
    if (description === undefined) {
      return "Description must be filled";
    }
    if (weaponId === undefined) {
      return "Weapon Id must be filled";
    }
    return {
      modifyGameContent: {
        class: {
          id,
          name,
          description,
          weaponId,
          startingItemIds: selectedItems,
          startingSkillActionIds: selectedActions,
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
          placeholder="unique_class_id"
        />
      </div>

      <div class="flex-1">
        <Label for="name">Name</Label>
        <Input id="name" type="text" bind:value={name} placeholder="Warrior" />
      </div>
    </div>

    <div>
      <Label for="description">Description</Label>
      <Textarea
        id="description"
        bind:value={description}
        placeholder="A skilled fighter proficient in various weapons and armor..."
      />
    </div>

    <div>
      <Label for="weaponId">Weapon Id</Label>
      <Input
        id="weaponId"
        type="text"
        bind:value={weaponId}
        placeholder="longsword"
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
      <Label for="image">Image</Label>
      <PixelArtEditor bind:pixels previewPixelSize={2} pixelSize={8} />
    </div>

    <div>
      <Label for="unlockRequirement">Unlock Requirement</Label>
      <UnlockRequirementEditor bind:unlockRequirement />
    </div>
  </div>
</FormTemplate>
