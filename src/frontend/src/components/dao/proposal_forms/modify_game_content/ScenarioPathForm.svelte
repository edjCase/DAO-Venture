<script lang="ts">
  import { ScenarioPath } from "../../../../ic-agent/declarations/main";
  import { Input, Label, Textarea } from "flowbite-svelte";
  import ChoiceScenarioPathEditor from "./ChoiceScenarioPathEditor.svelte";

  export let value: ScenarioPath;
</script>

<div class="border p-4 mb-4 rounded">
  <Label for="id">Id</Label>
  <Input id="id" type="text" bind:value={value.id} placeholder="path_id" />

  <Label for="description">Description</Label>
  <Textarea
    id="description"
    bind:value={value.description}
    placeholder="Describe the outcome..."
  />

  {#if "choice" in value.kind}
    <ChoiceScenarioPathEditor bind:value={value.kind.choice} />
  {:else if "combat" in value.kind}
    TODO Combat
  {/if}
</div>
