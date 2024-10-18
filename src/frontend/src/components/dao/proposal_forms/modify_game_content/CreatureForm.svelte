<script lang="ts">
  import FormTemplate from "../FormTemplate.svelte";
  import { Input, Label, Textarea } from "flowbite-svelte";
  import {
    CreateWorldProposalRequest,
    UnlockRequirement,
    CreatureKind,
    CreatureLocationKind,
    Creature,
  } from "../../../../ic-agent/declarations/main";
  import UnlockRequirementChooser from "./UnlockRequirementChooser.svelte";
  import CharacterStatIcon from "../../../character/CharacterStatIcon.svelte";
  import { actionStore } from "../../../../stores/ActionStore";
  import EntityMultiSelector from "./EntityMultiSelector.svelte";
  import BigIntInput from "../../../common/BigIntInput.svelte";
  import CreatureLocationChooser from "./CreatureLocationChooser.svelte";
  import CreatureKindChooser from "./CreatureKindChooser.svelte";

  export let value: Creature | undefined;

  let id: string | undefined = value?.id;
  let name: string | undefined = value?.name;
  let description: string | undefined = value?.description;
  let maxHealth: bigint = value?.maxHealth ?? 100n;
  let health: bigint = value?.health ?? 100n;
  let selectedActions: string[] = value?.actionIds ?? [];
  let location: CreatureLocationKind = value?.location ?? { common: null };
  let unlockRequirement: UnlockRequirement = value?.unlockRequirement ?? {
    none: null,
  };
  let kind: CreatureKind = value?.kind ?? { normal: null };

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
    if (maxHealth === undefined) {
      return "Max health must be filled";
    }
    if (health === undefined) {
      return "Health must be filled";
    }
    return {
      modifyGameContent: {
        creature: {
          id,
          name,
          description,
          maxHealth,
          health,
          kind,
          location: location,
          actionIds: selectedActions,
          unlockRequirement: unlockRequirement,
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
          placeholder="unique_creature_id"
        />
      </div>

      <div class="flex-1">
        <Label for="name">Name</Label>
        <Input
          id="name"
          type="text"
          bind:value={name}
          placeholder="Fierce Dragon"
        />
      </div>
    </div>

    <div>
      <Label for="description">Description</Label>
      <Textarea
        id="description"
        bind:value={description}
        placeholder="A mighty dragon that breathes fire..."
      />
    </div>

    <div class="flex flex-wrap gap-4">
      <div class="flex flex-col items-center">
        <Label>
          <CharacterStatIcon kind={{ health: null }} />
        </Label>
        <BigIntInput bind:value={health} />
      </div>
      <div class="flex flex-col items-center">
        <Label>
          Max
          <CharacterStatIcon kind={{ health: null }} />
        </Label>
        <BigIntInput bind:value={maxHealth} />
      </div>
    </div>

    <div class="flex gap-4">
      <div class="flex-1">
        <Label for="kind">Kind</Label>
        <CreatureKindChooser bind:value={kind} />
      </div>

      <div class="flex-1">
        <Label for="kind">Location</Label>
        <CreatureLocationChooser bind:value={location} />
      </div>
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
      <Label for="unlockRequirement">Unlock Requirement</Label>
      <UnlockRequirementChooser bind:unlockRequirement />
    </div>
  </div>
</FormTemplate>
