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
  import { traitStore } from "../../../../stores/TraitStore";

  let id: string | undefined;
  let name: string | undefined;
  let description: string | undefined;
  let unlockRequirement: UnlockRequirement | undefined;

  let actionOptions: SelectOptionType<string>[] = [];
  let selectedActions: string[] = [];
  let traitOptions: SelectOptionType<string>[] = [];
  let selectedTraits: string[] = [];

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
          actionIds: selectedActions,
          startingTraitIds: selectedTraits,
          unlockRequirement: unlockRequirement ? [unlockRequirement] : [],
        },
      },
    };
  };

  $: actions = $actionStore;
  $: traits = $traitStore;
  $: {
    actionOptions =
      actions?.map((action) => ({
        value: action.id,
        name: action.name,
      })) || [];
  }
  $: {
    traitOptions =
      traits?.map((action) => ({
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
      <MultiSelect
        items={actionOptions}
        bind:value={selectedActions}
        placeholder="Select actions"
        size="lg"
      />
    </div>
    <div>
      <Label>Traits</Label>
      <MultiSelect
        items={traitOptions}
        bind:value={selectedTraits}
        placeholder="Select traits"
        size="lg"
      />
    </div>

    <div>
      <Label for="unlockRequirement">Unlock Requirement</Label>
      <UnlockRequirementEditor bind:unlockRequirement />
    </div>
  </div>
</FormTemplate>
