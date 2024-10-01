<script lang="ts">
  import FormTemplate from "../FormTemplate.svelte";
  import { Input, Label, Textarea } from "flowbite-svelte";
  import {
    CreateWorldProposalRequest,
    Item,
    UnlockRequirement,
  } from "../../../../ic-agent/declarations/main";
  import PixelArtEditor from "../../../common/PixelArtEditor.svelte";
  import {
    decodeImageToPixels,
    encodePixelsToImage,
    generatePixelGrid,
    PixelGrid,
  } from "../../../../utils/PixelUtil";
  import UnlockRequirementChooser from "./UnlockRequirementChooser.svelte";
  import EntityMultiSelector from "./EntityMultiSelector.svelte";
  import { actionStore } from "../../../../stores/ActionStore";
  import TagsEditor from "./CommaDelimitedEditor.svelte";

  export let value: Item | undefined;

  let id: string | undefined = value?.id;
  let name: string | undefined = value?.name;
  let description: string | undefined = value?.description;
  let tags: string[] = value?.tags ?? [];
  let pixels: PixelGrid =
    value !== undefined
      ? decodeImageToPixels(value.image, 32, 32)
      : generatePixelGrid(32, 32);
  let actionIds: string[] = value?.actionIds ?? [];
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
      <PixelArtEditor bind:pixels pixelSize={8} />
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
        <UnlockRequirementChooser bind:unlockRequirement />
      </div>
    </div>
  </div></FormTemplate
>
