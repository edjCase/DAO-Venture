<script lang="ts">
  import { CombatCreatureKind } from "../../../../ic-agent/declarations/main";
  import { toJsonString } from "../../../../utils/StringUtil";
  export let value: CombatCreatureKind;
</script>

{#if "id" in value}
  {value.id}
{:else if "filter" in value}
  Creatures
  {#if "any" in value.filter.location}
    from any location
  {:else if "zone" in value.filter.location}
    from zone {value.filter.location.zone}
  {:else if "common" in value.filter.location}
    that are common to all locations
  {:else}
    NOT IMPLEMENTED CREATURE LOCATION FILTER KIND: {toJsonString(
      value.filter.location
    )}
  {/if}
{:else}
  NOT IMPLEMENTED COMBAT CREATURE KIND: {toJsonString(value)}
{/if}
