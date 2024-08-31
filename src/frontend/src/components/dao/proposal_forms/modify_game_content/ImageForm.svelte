<script lang="ts">
  import FormTemplate from "../FormTemplate.svelte";
  import { Input, Label } from "flowbite-svelte";
  import { CreateWorldProposalRequest } from "../../../../ic-agent/declarations/main";

  let id: string | undefined;
  let imageFile: File | undefined;
  let imageData: number[] | undefined;

  let generateProposal = (): CreateWorldProposalRequest | string => {
    if (id === undefined) {
      return "No id provided";
    }
    if (imageData === undefined) {
      return "No image data provided";
    }

    return {
      modifyGameContent: {
        image: {
          id: id,
          data: imageData,
          kind: { png: null },
        },
      },
    };
  };

  const handleFileChange = (event: Event) => {
    const target = event.target as HTMLInputElement;
    if (target.files) {
      imageFile = target.files[0];
      const reader = new FileReader();
      reader.onload = (e) => {
        if (e.target?.result instanceof ArrayBuffer) {
          imageData = Array.from(new Uint8Array(e.target.result));
        }
      };
      reader.readAsArrayBuffer(imageFile);
    }
  };
</script>

<FormTemplate {generateProposal}>
  <div class="space-y-4">
    <div>
      <Label for="id">Id</Label>
      <Input
        id="id"
        type="text"
        bind:value={id}
        placeholder="unique_image_id"
      />
    </div>

    <div>
      <Label for="imageFile">Image File</Label>
      <Input
        id="imageFile"
        type="file"
        on:change={handleFileChange}
        accept="image/png"
      />
    </div>
  </div>
</FormTemplate>
