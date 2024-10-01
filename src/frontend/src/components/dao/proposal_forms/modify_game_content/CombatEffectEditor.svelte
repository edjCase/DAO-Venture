<script lang="ts">
  import { Input, Label } from "flowbite-svelte";
  import { CombatEffect } from "../../../../ic-agent/declarations/main";
  import MinMaxTimingForm from "./MinMaxTimingForm.svelte";
  import StatusEffectChooser from "./StatusEffectChooser.svelte";
  import DurationChooser from "./DurationChooser.svelte";

  export let effect: CombatEffect;
</script>

{#if "damage" in effect.kind}
  <MinMaxTimingForm bind:value={effect.kind.damage} />
{:else if "heal" in effect.kind}
  <MinMaxTimingForm bind:value={effect.kind.heal} />
{:else if "block" in effect.kind}
  <MinMaxTimingForm bind:value={effect.kind.block} />
{:else if "addStatusEffect" in effect.kind}
  <Label>Status</Label>
  <StatusEffectChooser bind:value={effect.kind.addStatusEffect.kind} />
  <Label>Duration</Label>
  <DurationChooser bind:value={effect.kind.addStatusEffect.duration} />
{/if}
