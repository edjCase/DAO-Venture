<script lang="ts">
  import FormTemplate from "../FormTemplate.svelte";
  import { Input, Label, Textarea } from "flowbite-svelte";
  import {
    CreateWorldProposalRequest,
    UnlockRequirement,
    Zone,
    ZoneDifficulty,
  } from "../../../../ic-agent/declarations/main";
  import UnlockRequirementChooser from "./UnlockRequirementChooser.svelte";
  import ZoneDifficultyChooser from "./ZoneDifficultyChooser.svelte";

  export let value: Zone | undefined;

  let id: string | undefined = value?.id;
  let name: string | undefined = value?.name;
  let description: string | undefined = value?.description;
  let difficulty: ZoneDifficulty = value?.difficulty ?? { medium: null };
  let unlockRequirement: UnlockRequirement = value?.unlockRequirement ?? {
    none: null,
  };

  let generateProposal = (): CreateWorldProposalRequest | string => {
    if (id === undefined) {
      return "No id provided";
    }
    if (name === undefined) {
      return "No name provided";
    }
    if (description === undefined) {
      return "No description provided";
    }
    return {
      modifyGameContent: {
        zone: {
          id: id,
          name: name,
          description: description,
          difficulty: difficulty,
          unlockRequirement: unlockRequirement,
        },
      },
    };
  };
</script>

<FormTemplate {generateProposal}>
  <div class="space-y-4">
    <div>
      <Label for="id">Id</Label>
      <Input id="id" type="text" bind:value={id} placeholder="unique_zone_id" />
    </div>

    <div>
      <Label for="name">Name</Label>
      <Input
        id="name"
        type="text"
        bind:value={name}
        placeholder="Enchanted Forest"
      />
    </div>

    <div>
      <Label for="description">Description</Label>
      <Textarea
        id="description"
        bind:value={description}
        placeholder="A mystical forest filled with ancient magic and hidden secrets..."
      />
    </div>

    <div>
      <Label>Difficulty</Label>
      <ZoneDifficultyChooser bind:value={difficulty} />
    </div>

    <div>
      <Label for="unlockRequirement">Unlock Requirement</Label>
      <UnlockRequirementChooser bind:unlockRequirement />
    </div>
  </div>
</FormTemplate>
