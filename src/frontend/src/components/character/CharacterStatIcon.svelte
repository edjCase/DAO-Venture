<script lang="ts" context="module">
  export type CharacterStatIconKind =
    | { attack: null }
    | { defense: null }
    | { speed: null }
    | { magic: null }
    | { health: null }
    | { maxHealth: null }
    | { gold: null };

  export const getIconKind = (
    key: string
  ): CharacterStatIconKind | undefined => {
    switch (key) {
      case "attack":
        return { attack: null };
      case "defense":
        return { defense: null };
      case "speed":
        return { speed: null };
      case "magic":
        return { magic: null };
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

{#if "attack" in kind}
  ⚔️
{:else if "defense" in kind}
  🛡️
{:else if "speed" in kind}
  🏃
{:else if "magic" in kind}
  🔮
{:else if "health" in kind}
  🫀
{:else if "maxHealth" in kind}
  🫀
{:else if "gold" in kind}
  🪙
{:else}
  NOT IMPLEMENTED ICON {toJsonString(kind)}
{/if}
