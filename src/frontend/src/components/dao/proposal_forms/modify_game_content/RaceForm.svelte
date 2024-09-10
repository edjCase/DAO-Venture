<script lang="ts">
  import FormTemplate from "../FormTemplate.svelte";
  import { Input, Label, Textarea } from "flowbite-svelte";
  import {
    CreateWorldProposalRequest,
    UnlockRequirement,
  } from "../../../../ic-agent/declarations/main";
  import UnlockRequirementEditor from "./UnlockRequirementEditor.svelte";
  import { actionStore } from "../../../../stores/ActionStore";
  import { itemStore } from "../../../../stores/ItemStore";
  import EntityMultiSelector from "./EntityMultiSelector.svelte";

  let id: string | undefined;
  let name: string | undefined;
  let description: string | undefined;
  let unlockRequirement: UnlockRequirement | undefined;

  let selectedActions: string[] = [];
  let selectedItems: string[] = [];

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
          startingActionIds: selectedActions,
          startingItemIds: selectedItems,
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
      <Label for="unlockRequirement">Unlock Requirement</Label>
      <UnlockRequirementEditor bind:unlockRequirement />
    </div>
  </div>
</FormTemplate>
