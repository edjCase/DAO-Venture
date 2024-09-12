<script lang="ts">
  import {
    StatusEffect,
    StatusEffectResult,
  } from "../../ic-agent/declarations/main";
  import GameIcon from "../game/GameIcon.svelte";

  export let value: StatusEffectResult | StatusEffect;
</script>

<span>
  {#if "weak" in value.kind}
    <GameIcon value="weak" />
  {:else if "vulnerable" in value.kind}
    <GameIcon value="vulnerable" />
  {:else if "brittle" in value.kind}
    <GameIcon value="brittle" />
  {:else if "necrotic" in value.kind}
    <GameIcon value="necrotic" />
  {:else if "retaliating" in value.kind}
    <GameIcon value="retaliating" />
  {:else if "stunned" in value.kind}
    <GameIcon value="stunned" />
  {:else if "periodic" in value.kind}
    <GameIcon value="periodic" />
    {#if "damage" in value.kind.periodic.kind}
      <GameIcon value="damage" />
    {:else if "heal" in value.kind.periodic.kind}
      <GameIcon value="heal" />
    {:else if "block" in value.kind.periodic.kind}
      <GameIcon value="block" />
    {:else}
      ❓ (NOT IMPLEMENTED)
    {/if}
  {:else}
    ❓ (NOT IMPLEMENTED)
  {/if}
  <span class="text-[0.7em] align-sub leading-[0]">
    {#if "remainingTurns" in value}
      {value.remainingTurns}
    {:else}
      {value.duration}
    {/if}
  </span>
</span>
