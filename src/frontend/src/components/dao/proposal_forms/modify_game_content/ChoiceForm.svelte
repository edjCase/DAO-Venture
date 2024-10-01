<script lang="ts">
  import { Choice } from "../../../../ic-agent/declarations/main";
  import { Input, Label, Textarea } from "flowbite-svelte";
  import NextPathChooser from "./NextPathChooser.svelte";

  export let value: Choice;
</script>

<div>
  <Label for="id">Id</Label>
  <Input id="id" type="text" bind:value={value.id} placeholder="choice_id" />

  <Label for="description">Description</Label>
  <Textarea
    id="description"
    bind:value={value.description}
    placeholder="Describe the choice..."
  />

  <Label>Next Path</Label>
  <NextPathChooser value={value.nextPath} />
</div>
