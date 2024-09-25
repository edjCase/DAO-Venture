<script lang="ts">
  import { Choice } from "../../../../ic-agent/declarations/main";
  import { Input, Label, Textarea } from "flowbite-svelte";
  import NextPathChooser from "./NextPathChooser.svelte";

  export let value: Choice;
</script>

<div class="border p-4 mb-4">
  <Label for="id">Id</Label>
  <Input id="id" type="text" bind:value={value.id} placeholder="choice_id" />

  <Label for="description">Description</Label>
  <Textarea
    id="description"
    bind:value={value.description}
    placeholder="Describe the choice..."
  />

  <NextPathChooser value={value.nextPath} />
</div>
