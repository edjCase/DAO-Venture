<script lang="ts">
  import FormTemplate from "../FormTemplate.svelte";
  import { Input, Label, Textarea, Select } from "flowbite-svelte";
  import {
    CreateWorldProposalRequest,
    UnlockRequirement,
    CreatureKind,
    CreatureLocationKind,
  } from "../../../../ic-agent/declarations/main";
  import UnlockRequirementEditor from "./UnlockRequirementEditor.svelte";
  import CharacterStatIcon from "../../../character/CharacterStatIcon.svelte";
  import { actionStore } from "../../../../stores/ActionStore";
  import EntityMultiSelector from "./EntityMultiSelector.svelte";
  import BigIntInput from "../../../common/BigIntInput.svelte";
  import TagsEditor from "./TagsEditor.svelte";

  let id: string | undefined;
  let name: string | undefined;
  let description: string | undefined;
  let maxHealth: bigint = 100n;
  let health: bigint = 100n;
  let weaponId: string | undefined;
  let selectedActions: string[] = [];

  let creatureKinds = [
    { value: "normal", name: "Normal", kind: { normal: null } },
    { value: "boss", name: "Boss", kind: { boss: null } },
    { value: "elite", name: "Elite", kind: { elite: null } },
  ];
  let selectedCreatureKind: string = creatureKinds[0].value;
  let kind: CreatureKind = creatureKinds[0].kind;

  let locationTypes = [
    { value: "common", name: "Common", location: { common: null } },
    { value: "zoneIds", name: "Specific Zones", location: { zoneIds: [] } },
  ];
  let selectedLocationType: string = locationTypes[0].value;
  let location: CreatureLocationKind = locationTypes[0].location;

  let unlockRequirement: UnlockRequirement | undefined;

  $: {
    let selectedKind = creatureKinds.find(
      (ck) => ck.value === selectedCreatureKind
    );
    if (selectedKind) {
      kind = selectedKind.kind;
    }
  }

  $: {
    let selectedLocation = locationTypes.find(
      (lt) => lt.value === selectedLocationType
    );
    if (selectedLocation) {
      location = selectedLocation.location;
    }
  }

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
    if (weaponId === undefined) {
      return "Weapon Id must be filled";
    }
    return {
      modifyGameContent: {
        creature: {
          id,
          name,
          description,
          maxHealth,
          health,
          weaponId,
          kind,
          location: location,
          actionIds: selectedActions,
          unlockRequirement:
            unlockRequirement !== undefined ? [unlockRequirement] : [],
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

    <div>
      <Label for="weaponId">Weapon Id</Label>
      <Input
        id="weaponId"
        type="text"
        bind:value={weaponId}
        placeholder="dragon_claw"
      />
    </div>

    <div class="flex gap-4">
      <div class="flex-1">
        <Label for="kind">Creature Kind</Label>
        <Select
          id="kind"
          items={creatureKinds}
          bind:value={selectedCreatureKind}
        />
      </div>

      <div class="flex-1">
        <Label for="location">Location</Label>
        <Select
          id="location"
          items={locationTypes}
          bind:value={selectedLocationType}
        />
      </div>
    </div>
    {#if "zoneIds" in location}
      <div>
        <Label for="zoneIds">Zone Ids (comma-separated)</Label>
        <TagsEditor bind:value={location.zoneIds} />
      </div>
    {/if}
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
      <UnlockRequirementEditor bind:unlockRequirement />
    </div>
  </div>
</FormTemplate>
