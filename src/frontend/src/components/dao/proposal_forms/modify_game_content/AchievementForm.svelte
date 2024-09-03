<script lang="ts">
  import FormTemplate from "../FormTemplate.svelte";
  import { Input, Label, Textarea } from "flowbite-svelte";
  import {
    CreateWorldProposalRequest,
    Achievement,
  } from "../../../../ic-agent/declarations/main";

  let id: string | undefined;
  let name: string | undefined;
  let description: string | undefined;

  const generateProposal = (): CreateWorldProposalRequest | string => {
    if (id === undefined || name === undefined || description === undefined) {
      return "All fields must be filled";
    }

    const achievement: Achievement = {
      id,
      name,
      description,
    };

    return {
      modifyGameContent: {
        achievement,
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
          placeholder="unique_achievement_id"
        />
      </div>

      <div class="flex-1">
        <Label for="name">Name</Label>
        <Input
          id="name"
          type="text"
          bind:value={name}
          placeholder="Master Explorer"
        />
      </div>
    </div>

    <div>
      <Label for="description">Description</Label>
      <Textarea
        id="description"
        bind:value={description}
        placeholder="Awarded to players who have explored all zones in the game."
      />
    </div>
  </div>
</FormTemplate>
