<script lang="ts">
  import FormTemplate from "../FormTemplate.svelte";
  import {
    Input,
    Label,
    MultiSelect,
    SelectOptionType,
    Textarea,
  } from "flowbite-svelte";
  import {
    CreateWorldProposalRequest,
    UnlockRequirement,
  } from "../../../../ic-agent/declarations/main";
  import UnlockRequirementEditor from "./UnlockRequirementEditor.svelte";
  import { actionStore } from "../../../../stores/ActionStore";
  import { itemStore } from "../../../../stores/ItemStore";

  let id: string | undefined;
  let name: string | undefined;
  let description: string | undefined;
  let weaponId: string | undefined;
  let unlockRequirement: UnlockRequirement | undefined;

  let actionOptions: SelectOptionType<string>[] = [];
  let selectedActions: string[] = [];
  let itemOptions: SelectOptionType<string>[] = [];
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
          actionIds: selectedActions,
          unlockRequirement: unlockRequirement ? [unlockRequirement] : [],
        },
      },
    };
  };

  $: actions = $actionStore;
  $: items = $itemStore;
  $: {
    actionOptions =
      actions?.map((action) => ({
        value: action.id,
        name: action.name,
      })) || [];
  }
  $: {
    itemOptions =
      items?.map((item) => ({
        value: item.id,
        name: item.name,
      })) || [];
  }
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
      <MultiSelect
        items={actionOptions}
        bind:value={selectedActions}
        placeholder="Select actions"
        size="lg"
      />
    </div>
    <div>
      <Label>Items</Label>
      <MultiSelect
        items={itemOptions}
        bind:value={selectedItems}
        placeholder="Select Items"
        size="lg"
      />
    </div>

    <div>
      <Label for="unlockRequirement">Unlock Requirement</Label>
      <UnlockRequirementEditor bind:unlockRequirement />
    </div>
  </div>
</FormTemplate>
