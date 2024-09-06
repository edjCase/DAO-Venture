<script lang="ts">
  import FormTemplate from "../FormTemplate.svelte";
  import {
    Input,
    Label,
    Textarea,
    MultiSelect,
    SelectOptionType,
  } from "flowbite-svelte";
  import {
    CreateWorldProposalRequest,
    Weapon,
    UnlockRequirement,
  } from "../../../../ic-agent/declarations/main";
  import UnlockRequirementEditor from "./UnlockRequirementEditor.svelte";
  import { actionStore } from "../../../../stores/ActionStore";

  let id: string | undefined;
  let name: string | undefined;
  let description: string | undefined;
  let actionIds: string[] = [];
  let unlockRequirement: UnlockRequirement | undefined;

  let actionOptions: SelectOptionType<string>[] = [];
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
      unlockRequirement: unlockRequirement ? [unlockRequirement] : [],
    };

    return {
      modifyGameContent: {
        weapon,
      },
    };
  };

  $: actions = $actionStore;
  $: {
    actionOptions =
      actions?.map((action) => ({
        value: action.id,
        name: action.name,
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
      <MultiSelect
        items={actionOptions}
        bind:value={selectedActions}
        placeholder="Select actions"
        size="lg"
      />
    </div>

    <div>
      <Label for="unlockRequirement">Unlock Requirement</Label>
      <UnlockRequirementEditor bind:unlockRequirement />
    </div>
  </div>
</FormTemplate>
