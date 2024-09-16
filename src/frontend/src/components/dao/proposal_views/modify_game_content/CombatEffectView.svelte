<script lang="ts">
  import { CombatEffect } from "../../../../ic-agent/declarations/main";
  import { toJsonString } from "../../../../utils/StringUtil";

  export let effect: CombatEffect;
</script>

<div>
  {#if "damage" in effect.kind}
    Damage: {effect.kind.damage.min}-{effect.kind.damage.max}
  {:else if "heal" in effect.kind}
    Heal: {effect.kind.heal.min}-{effect.kind.heal.max}
  {:else if "addStatusEffect" in effect.kind}
    Add Status Effect:
    {#if "retaliating" in effect.kind.addStatusEffect.kind}
      Retaliating (Flat: {effect.kind.addStatusEffect.kind.retaliating.flat})
    {:else if "weak" in effect.kind.addStatusEffect.kind}
      Weak
    {:else if "vulnerable" in effect.kind.addStatusEffect.kind}
      Vulnerable
    {:else if "stunned" in effect.kind.addStatusEffect.kind}
      Stunned
    {:else if "brittle" in effect.kind.addStatusEffect.kind}
      Brittle
    {:else if "necrotic" in effect.kind.addStatusEffect.kind}
      Necrotic
    {:else}
      NOT IMPLEMENTED ADD STATUS EFFECT KIND: {toJsonString(
        effect.kind.addStatusEffect.kind
      )}
    {/if}
    {#if effect.kind.addStatusEffect.duration}
      for {effect.kind.addStatusEffect.duration[0]} turns
    {:else}
      (duration: indefinite)
    {/if}
  {:else if "block" in effect.kind}
    Block: {effect.kind.block.min}-{effect.kind.block.max}
  {:else}
    NOT IMPLEMENTED EFFECT Kind: {toJsonString(effect.kind)}
  {/if}
  (Target:
  {#if "self" in effect.target}
    Self
  {:else if "targets" in effect.target}
    Targets
  {:else}
    NOT IMPLEMENTED EFFECT TARGET: {toJsonString(effect.target)}
  {/if})
</div>
