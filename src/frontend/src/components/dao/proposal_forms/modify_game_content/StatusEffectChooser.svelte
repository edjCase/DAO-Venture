<script lang="ts">
  import { Select, SelectOptionType, Label } from "flowbite-svelte";
  import { StatusEffectKind } from "../../../../ic-agent/declarations/main";
  import BigIntInput from "../../../common/BigIntInput.svelte";

  export let value: StatusEffectKind;

  const statusEffectKinds: SelectOptionType<string>[] = [
    { value: "weak", name: "Weak" },
    { value: "vulnerable", name: "Vulnerable" },
    { value: "stunned", name: "Stunned" },
    { value: "retaliating", name: "Retaliating" },
    { value: "brittle", name: "Brittle" },
    { value: "necrotic", name: "Necrotic" },
  ];
  let selectedStatusEffectKind: string = Object.keys(value)[0];

  const updateStatusEffectKind = () => {
    if (selectedStatusEffectKind === "retaliating") {
      value = { retaliating: { flat: 1n } };
    } else if (selectedStatusEffectKind === "weak") {
      value = { weak: null };
    } else if (selectedStatusEffectKind === "vulnerable") {
      value = { vulnerable: null };
    } else if (selectedStatusEffectKind === "stunned") {
      value = { stunned: null };
    } else if (selectedStatusEffectKind === "brittle") {
      value = { brittle: null };
    } else if (selectedStatusEffectKind === "necrotic") {
      value = { necrotic: null };
    } else {
      throw new Error(
        "Invalid status effect kind: " + selectedStatusEffectKind
      );
    }
  };
</script>

<Select
  items={statusEffectKinds}
  on:change={updateStatusEffectKind}
  bind:value={selectedStatusEffectKind}
/>
{#if "retaliating" in value}
  <Label>Damage</Label>
  <BigIntInput bind:value={value.retaliating.flat} />
{/if}
