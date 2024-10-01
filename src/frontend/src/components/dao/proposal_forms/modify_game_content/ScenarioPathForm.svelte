<script lang="ts">
  import { ScenarioPath } from "../../../../ic-agent/declarations/main";
  import { Input, Label, Textarea } from "flowbite-svelte";
  import ChoiceScenarioPathEditor from "./ChoiceScenarioPathEditor.svelte";
  import CombatScenarioPathEditor from "./CombatScenarioPathEditor.svelte";
  import { toJsonString } from "../../../../utils/StringUtil";
  import RewardScenarioPathEditor from "./RewardScenarioPathEditor.svelte";

  export let value: ScenarioPath;
</script>

<div>
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
    <CombatScenarioPathEditor bind:value={value.kind.combat} />
  {:else if "reward" in value.kind}
    <RewardScenarioPathEditor bind:value={value.kind.reward} />
  {:else}
    NOT IMPLEMENTED PATH KIND: {toJsonString(value.kind)}
  {/if}
</div>
