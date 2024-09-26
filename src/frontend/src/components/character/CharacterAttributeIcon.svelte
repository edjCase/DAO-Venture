<script lang="ts">
  import { Tooltip } from "flowbite-svelte";
  import { Attribute } from "../../ic-agent/declarations/main";

  export let value: Attribute;
</script>

{#if "strength" in value}
  <span>💪</span>
  <Tooltip>
    <div class="text-xl text-primary-500">Strength</div>
  </Tooltip>
{:else if "wisdom" in value}
  <span>📖</span>
  <Tooltip>
    <div class="text-xl text-primary-500">Wisdom</div>
  </Tooltip>
{:else if "dexterity" in value}
  <span>🤸</span>
  <Tooltip>
    <div class="text-xl text-primary-500">Dexterity</div>
  </Tooltip>
{:else if "charisma" in value}
  <span>🎭</span>
  <Tooltip>
    <div class="text-xl text-primary-500">Charisma</div>
  </Tooltip>
{/if}
