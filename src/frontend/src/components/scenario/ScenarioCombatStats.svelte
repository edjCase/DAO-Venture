<script lang="ts">
  import { StatusEffectResult } from "../../ic-agent/declarations/main";
  import GameIcon from "../game/GameIcon.svelte";
  import StatusEffect from "./StatusEffect.svelte";

  export let value: {
    block: bigint;
    health: bigint;
    maxHealth: bigint;
    statusEffects: StatusEffectResult[];
  };
</script>

<p><GameIcon value="health" /> {value.health}/{value.maxHealth}</p>
<p><GameIcon value="block" /> {value.block}</p>
<div class="flex justify-center">
  {#if value.statusEffects.length > 0}
    {#each value.statusEffects as effect}
      <StatusEffect value={effect} />
    {/each}
  {/if}
</div>
