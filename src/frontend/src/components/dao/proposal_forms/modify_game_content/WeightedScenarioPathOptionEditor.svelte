<script lang="ts">
  import { Input, Label } from "flowbite-svelte";
  import { WeightedScenarioPathOption } from "../../../../ic-agent/declarations/main";
  import { PlusSolid, TrashBinSolid } from "flowbite-svelte-icons";
  import Button from "flowbite-svelte/Button.svelte";
  import PathEffectChooser from "./PathEffectChooser.svelte";
  import OptionWeightKindChooser from "./OptionWeightKindChooser.svelte";

  export let value: WeightedScenarioPathOption;

  function addEffect() {
    value.effects.push({ damage: { raw: 0n } });
    value = { ...value };
  }

  function removeEffect(index: number) {
    value.effects = value.effects.filter((_, i) => i !== index);
    value = { ...value };
  }
</script>

<div>
  <Label>Description</Label>
  <Input type="text" bind:value={value.description} placeholder="Description" />
  <Label>Base Weight</Label>
  <Input type="number" bind:value={value.weight.value} />
  <Label>Weight Kind</Label>
  <OptionWeightKindChooser bind:value={value.weight.kind} />
  <Label>Next Path Id</Label>
  <Input
    type="text"
    bind:value={value.pathId[0]}
    placeholder="Leave blank to end scenario"
  />

  <div class="flex items-center gap-2">
    <Label>Effects</Label>

    <Button on:click={() => addEffect()}>
      <PlusSolid size="xs" />
    </Button>
  </div>
  {#each value.effects as effect, effectIndex}
    <div class="mb-2 pl-10">
      <PathEffectChooser bind:value={effect} />
      <Button color="red" on:click={() => removeEffect(effectIndex)}>
        <TrashBinSolid size="xs" />
      </Button>
    </div>
  {/each}
</div>
