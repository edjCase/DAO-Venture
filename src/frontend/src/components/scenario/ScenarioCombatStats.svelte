<script lang="ts">
  import { StatusEffectResult } from "../../ic-agent/declarations/main";

  export let value: {
    shield: bigint;
    health: bigint;
    maxHealth: bigint;
    statusEffects: StatusEffectResult[];
  };
</script>

<p>❤️ {value.health}/{value.maxHealth}</p>
<p>🛡️ {value.shield}</p>
{#if value.statusEffects.length > 0}
  {#each value.statusEffects as effect}
    <p>
      {#if "weak" in effect.kind}
        🐁
      {:else if "vulnerable" in effect.kind}
        🎯
      {:else if "retaliating" in effect.kind}
        🦔
      {:else if "stunned" in effect.kind}
        💫
      {:else if "periodic" in effect.kind}
        🔃
        {#if "damage" in effect.kind.periodic.kind}
          💥
        {:else if "heal" in effect.kind.periodic.kind}
          💖
        {:else if "shield" in effect.kind.periodic.kind}
          🛡️
        {:else}
          ❓ (NOT IMPLEMENTED)
        {/if}
      {:else}
        ❓ (NOT IMPLEMENTED)
      {/if}
      ✨ {value.statusEffects.map((effect) => effect.kind).join(", ")}
    </p>
  {/each}
{/if}
