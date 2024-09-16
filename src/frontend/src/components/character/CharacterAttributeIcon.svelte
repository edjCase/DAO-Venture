<script lang="ts">
  import { Attribute } from "../../ic-agent/declarations/main";

  export let value: Attribute;
</script>

<span>
  {#if "strength" in value}
    💪
  {:else if "wisdom" in value}
    📖
  {:else if "dexterity" in value}
    🤸
  {:else if "charisma" in value}
    🎭
  {/if}
</span>
