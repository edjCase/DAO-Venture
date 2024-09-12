<script lang="ts">
  export let value:
    | "health"
    | "block"
    | "damage"
    | "heal"
    | "weak"
    | "vulnerable"
    | "brittle"
    | "necrotic"
    | "retaliating"
    | "stunned"
    | "periodic"
    | "self";
</script>

<span>
  {#if value === "health"}
    ❤️
  {:else if value === "block"}
    🛡️
  {:else if value === "damage"}
    💥
  {:else if value === "heal"}
    💖
  {:else if value === "weak"}
    🐁
  {:else if value === "vulnerable"}
    🎯
  {:else if value === "brittle"}
    🔨
  {:else if value === "necrotic"}
    💉
  {:else if value === "retaliating"}
    🦔
  {:else if value === "stunned"}
    💫
  {:else if value === "periodic"}
    🔃
  {:else if value === "self"}
    ↩️
  {/if}
</span>
