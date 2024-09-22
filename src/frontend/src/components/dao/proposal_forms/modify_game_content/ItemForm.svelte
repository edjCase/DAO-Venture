<script lang="ts">
  import FormTemplate from "../FormTemplate.svelte";
  import { Input, Label, Textarea } from "flowbite-svelte";
  import {
    CreateWorldProposalRequest,
    UnlockRequirement,
  } from "../../../../ic-agent/declarations/main";
  import PixelArtEditor from "../../../common/PixelArtEditor.svelte";
  import {
    encodePixelsToImage,
    generatePixelGrid,
    PixelGrid,
  } from "../../../../utils/PixelUtil";
  import UnlockRequirementEditor from "./UnlockRequirementEditor.svelte";
  import EntityMultiSelector from "./EntityMultiSelector.svelte";
  import { actionStore } from "../../../../stores/ActionStore";
  import TagsEditor from "./TagsEditor.svelte";

  let id: string | undefined;
  let name: string | undefined;
  let description: string | undefined;
  let tags: string[] = [];
  let pixels: PixelGrid = generatePixelGrid(32, 32);
  let actionIds: string[] = [];
  let unlockRequirement: UnlockRequirement | undefined;

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
    if (pixels === undefined) {
      return "No pixels provided";
    }
    return {
      modifyGameContent: {
        item: {
          id: id,
          name: name,
          description: description,
          image: encodePixelsToImage(pixels),
          tags: tags,
          actionIds: actionIds,
          unlockRequirement:
            unlockRequirement === undefined ? [] : [unlockRequirement],
        },
      },
    };
  };
</script>

<FormTemplate {generateProposal}>
  <div class="space-y-4">
    <div>
      <Label for="id">Id</Label>
      <Input id="id" type="text" bind:value={id} placeholder="unique_item_id" />
    </div>

    <div>
      <Label for="name">Name</Label>
      <Input
        id="name"
        type="text"
        bind:value={name}
        placeholder="Magical Sword"
      />
    </div>

    <div>
      <Label for="description">Description</Label>
      <Textarea
        id="description"
        bind:value={description}
        placeholder="A powerful sword imbued with ancient magic..."
      />
    </div>

    <div>
      <Label for="tags">Tags</Label>
      <TagsEditor bind:value={tags} />
    </div>

    <div>
      <Label for="image">Image</Label>
      <PixelArtEditor bind:pixels previewPixelSize={2} pixelSize={8} />
    </div>

    <div>
      <Label for="actionIds">Action Ids</Label>
      <EntityMultiSelector
        bind:ids={actionIds}
        store={actionStore}
        label="Action"
      />
      <div>
        <Label for="unlockRequirement">Unlock Requirement</Label>
        <UnlockRequirementEditor bind:unlockRequirement />
      </div>
    </div>
  </div></FormTemplate
>
