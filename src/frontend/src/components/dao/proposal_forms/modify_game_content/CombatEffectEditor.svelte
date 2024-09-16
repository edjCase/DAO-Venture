<script lang="ts">
  import { Select, Input, SelectOptionType } from "flowbite-svelte";
  import { CombatEffect } from "../../../../ic-agent/declarations/main";
  import MinMaxTimingForm from "./MinMaxTimingForm.svelte";

  export let effect: CombatEffect;

  const statusEffectKinds: SelectOptionType<string>[] = [
    { value: "weak", name: "Weak" },
    { value: "vulnerable", name: "Vulnerable" },
    { value: "stunned", name: "Stunned" },
    { value: "retaliating", name: "Retaliating" },
  ];
</script>

{#if "damage" in effect.kind}
  <MinMaxTimingForm bind:value={effect.kind.damage} />
{:else if "heal" in effect.kind}
  <MinMaxTimingForm bind:value={effect.kind.heal} />
{:else if "block" in effect.kind}
  <MinMaxTimingForm bind:value={effect.kind.block} />
{:else if "addStatusEffect" in effect.kind}
  <div class="flex gap-2 mt-2">
    <Select
      items={statusEffectKinds}
      bind:value={effect.kind.addStatusEffect.kind}
    />
    <Input
      type="number"
      bind:value={effect.kind.addStatusEffect.duration[0]}
      placeholder="Duration"
    />
  </div>
{/if}
