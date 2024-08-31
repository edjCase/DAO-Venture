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

  let id: string | undefined;
  let name: string | undefined;
  let description: string | undefined;
  let magic: bigint = 0n;
  let maxHealth: bigint = 100n;
  let speed: bigint = 0n;
  let defense: bigint = 0n;
  let attack: bigint = 0n;
  let health: bigint = 100n;
  let weaponId: string | undefined;

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

  let zoneIds: string[] = [];
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
    if (
      id === undefined ||
      name === undefined ||
      description === undefined ||
      magic === undefined ||
      maxHealth === undefined ||
      speed === undefined ||
      defense === undefined ||
      attack === undefined ||
      health === undefined ||
      weaponId === undefined
    ) {
      return "All fields except unlock requirement must be filled";
    }
    return {
      modifyGameContent: {
        creature: {
          id,
          name,
          description,
          magic,
          maxHealth,
          speed,
          defense,
          attack,
          health,
          weaponId,
          kind,
          location: location,
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
        <Label for="health">
          <CharacterStatIcon kind={{ health: null }} />
        </Label>
        <Input id="health" type="number" bind:value={health} class="w-16" />
      </div>
      <div class="flex flex-col items-center">
        <Label for="maxHealth">
          Max
          <CharacterStatIcon kind={{ health: null }} />
        </Label>
        <Input
          id="maxHealth"
          type="number"
          bind:value={maxHealth}
          class="w-16"
        />
      </div>
      <div class="flex flex-col items-center">
        <Label for="attack">
          <CharacterStatIcon kind={{ attack: null }} />
        </Label>
        <Input id="attack" type="number" bind:value={attack} class="w-16" />
      </div>
      <div class="flex flex-col items-center">
        <Label for="defense">
          <CharacterStatIcon kind={{ defense: null }} />
        </Label>
        <Input id="defense" type="number" bind:value={defense} class="w-16" />
      </div>
      <div class="flex flex-col items-center">
        <Label for="speed">
          <CharacterStatIcon kind={{ speed: null }} />
        </Label>
        <Input id="speed" type="number" bind:value={speed} class="w-16" />
      </div>
      <div class="flex flex-col items-center">
        <Label for="magic">
          <CharacterStatIcon kind={{ magic: null }} />
        </Label>
        <Input id="magic" type="number" bind:value={magic} class="w-16" />
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
        <Input
          id="zoneIds"
          type="text"
          bind:value={zoneIds}
          placeholder="zone1,zone2,zone3"
        />
      </div>
    {/if}

    <div>
      <Label for="unlockRequirement">Unlock Requirement</Label>
      <UnlockRequirementEditor bind:unlockRequirement />
    </div>
  </div>
</FormTemplate>
