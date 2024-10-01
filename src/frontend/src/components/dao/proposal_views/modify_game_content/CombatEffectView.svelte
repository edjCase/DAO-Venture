<script lang="ts">
  import { CombatEffect } from "../../../../ic-agent/declarations/main";
  import { toJsonString } from "../../../../utils/StringUtil";
  import GameIcon from "../../../game/GameIcon.svelte";
  import MinMaxTimingView from "./MinMaxTimingView.svelte";

  export let effect: CombatEffect;
</script>

<div>
  {#if "damage" in effect.kind}
    <div class="text-primary-500">Damage</div>
    <MinMaxTimingView value={effect.kind.damage} />
  {:else if "heal" in effect.kind}
    <div class="text-primary-500">Heal</div>
    <MinMaxTimingView value={effect.kind.heal} />
  {:else if "block" in effect.kind}
    <div class="text-primary-500">Block</div>
    <MinMaxTimingView value={effect.kind.block} />
  {:else if "addStatusEffect" in effect.kind}
    <div class="text-primary-500">Add Status Effect</div>
    {#if "retaliating" in effect.kind.addStatusEffect.kind}
      <GameIcon value="retaliating" /> ({effect.kind.addStatusEffect.kind
        .retaliating.flat} damage)
    {:else if "weak" in effect.kind.addStatusEffect.kind}
      <GameIcon value="weak" />
    {:else if "vulnerable" in effect.kind.addStatusEffect.kind}
      <GameIcon value="vulnerable" />
    {:else if "stunned" in effect.kind.addStatusEffect.kind}
      <GameIcon value="stunned" />
    {:else if "brittle" in effect.kind.addStatusEffect.kind}
      <GameIcon value="brittle" />
    {:else if "necrotic" in effect.kind.addStatusEffect.kind}
      <GameIcon value="necrotic" />
    {:else}
      NOT IMPLEMENTED ADD STATUS EFFECT KIND: {toJsonString(
        effect.kind.addStatusEffect.kind
      )}
    {/if}
    {#if effect.kind.addStatusEffect.duration}
      for {effect.kind.addStatusEffect.duration[0]} turns
    {/if}
  {:else}
    NOT IMPLEMENTED EFFECT Kind: {toJsonString(effect.kind)}
  {/if}

  {#if "self" in effect.target}
    (Self)
  {:else if "targets" in effect.target}
    <span></span>
  {:else}
    NOT IMPLEMENTED EFFECT TARGET: {toJsonString(effect.target)}
  {/if}
</div>
