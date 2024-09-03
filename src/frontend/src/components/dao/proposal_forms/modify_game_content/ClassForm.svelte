<script lang="ts">
  import FormTemplate from "../FormTemplate.svelte";
  import { Input, Label, Textarea } from "flowbite-svelte";
  import {
    CreateWorldProposalRequest,
    UnlockRequirement,
    CharacterModifier,
  } from "../../../../ic-agent/declarations/main";
  import UnlockRequirementEditor from "./UnlockRequirementEditor.svelte";
  import CharacterModifierMultiSelect from "./CharacterModifierMultiSelect.svelte";

  let id: string | undefined;
  let name: string | undefined;
  let description: string | undefined;
  let weaponId: string | undefined;
  let unlockRequirement: UnlockRequirement | undefined;
  let modifiers: CharacterModifier[] = [];

  let generateProposal = (): CreateWorldProposalRequest | string => {
    if (
      id === undefined ||
      name === undefined ||
      description === undefined ||
      weaponId === undefined
    ) {
      return "All fields except unlock requirement must be filled";
    }
    return {
      modifyGameContent: {
        class: {
          id,
          name,
          description,
          weaponId,
          unlockRequirement: unlockRequirement ? [unlockRequirement] : [],
          modifiers,
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

    <CharacterModifierMultiSelect bind:modifiers />

    <div>
      <Label for="unlockRequirement">Unlock Requirement</Label>
      <UnlockRequirementEditor bind:unlockRequirement />
    </div>
  </div>
</FormTemplate>
