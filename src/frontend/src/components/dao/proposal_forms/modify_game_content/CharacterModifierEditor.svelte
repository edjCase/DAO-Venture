<script lang="ts">
  import { CharacterModifier } from "../../../../ic-agent/declarations/main";
  import CharacterStatIcon, {
    CharacterStatIconKind,
  } from "../../../character/CharacterStatIcon.svelte";

  export let value: CharacterModifier;

  let label:
    | { icon: CharacterStatIconKind }
    | { label: string; id: string }
    | undefined;
  $: {
    if ("attack" in value) {
      label = { icon: { attack: null } };
    } else if ("defense" in value) {
      label = { icon: { defense: null } };
    } else if ("speed" in value) {
      label = { icon: { speed: null } };
    } else if ("magic" in value) {
      label = { icon: { magic: null } };
    } else if ("health" in value) {
      label = { icon: { health: null } };
    } else if ("maxHealth" in value) {
      label = { icon: { maxHealth: null } };
    } else if ("gold" in value) {
      label = { icon: { gold: null } };
    } else if ("trait" in value) {
      label = { label: "Trait", id: "trait" };
    } else if ("item" in value) {
      label = { label: "Item", id: "item" };
    }
  }
</script>

{#if label === undefined}
  NOT IMPLEMENTED ICON {JSON.stringify(value)}
{:else if "icon" in label}
  <CharacterStatIcon kind={label.icon} />
{:else}
  {label.label}: {label.id}
{/if}
