<script lang="ts" context="module">
  export type CharacterStatIconKind =
    | { health: null }
    | { maxHealth: null }
    | { gold: null };

  export const getIconKind = (
    key: string
  ): CharacterStatIconKind | undefined => {
    switch (key) {
      case "health":
        return { health: null };
      case "maxHealth":
        return { maxHealth: null };
      case "gold":
        return { gold: null };
      default:
        return undefined;
    }
  };
</script>

<script lang="ts">
  import { Tooltip } from "flowbite-svelte";

  import { toJsonString } from "../../utils/StringUtil";

  export let kind: CharacterStatIconKind;
</script>

{#if "health" in kind}
  <span>🫀</span>
  <Tooltip>
    <div class="text-xl text-primary-500">Health</div>
  </Tooltip>
{:else if "maxHealth" in kind}
  <span>🫀</span>
  <Tooltip>
    <div class="text-xl text-primary-500">Max Health</div>
  </Tooltip>
{:else if "gold" in kind}
  <span>🪙</span>
  <Tooltip>
    <div class="text-xl text-primary-500">Gold</div>
  </Tooltip>
{:else}
  NOT IMPLEMENTED ICON {toJsonString(kind)}
{/if}
