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
  import { toJsonString } from "../../utils/StringUtil";

  export let kind: CharacterStatIconKind;
</script>

{#if "health" in kind}
  🫀
{:else if "maxHealth" in kind}
  🫀
{:else if "gold" in kind}
  🪙
{:else}
  NOT IMPLEMENTED ICON {toJsonString(kind)}
{/if}
