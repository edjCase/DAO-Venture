<script lang="ts">
  import { CharacterModifier } from "../../../../ic-agent/declarations/main";

  export let value: CharacterModifier;
</script>

{#if "attack" in value}
  <div>Attack: {value.attack}</div>
{:else if "defense" in value}
  <div>Defense: {value.defense}</div>
{:else if "health" in value}
  <div>Health: {value.health}</div>
{:else if "maxHealth" in value}
  <div>Max Health: {value.maxHealth}</div>
{:else if "speed" in value}
  <div>Speed: {value.speed}</div>
{:else if "magic" in value}
  <div>Magic: {value.magic}</div>
{:else if "trait" in value}
  <div>Trait: {value.trait}</div>
{:else if "item" in value}
  <div>Item: {value.item}</div>
{:else if "gold" in value}
  <div>Gold: {value.gold}</div>
{:else}
  NOT IMPLEMENTED MODIFIER: <pre>{JSON.stringify(value)}</pre>
{/if}
