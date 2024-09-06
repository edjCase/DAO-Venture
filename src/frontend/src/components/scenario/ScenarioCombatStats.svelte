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
<div class="flex justify-center">
  {#if value.statusEffects.length > 0}
    {#each value.statusEffects as effect}
      <div>
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
      </div>
    {/each}
  {/if}
</div>
