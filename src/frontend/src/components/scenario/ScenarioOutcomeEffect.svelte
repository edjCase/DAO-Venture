<script lang="ts">
  import { OutcomeEffect } from "../../ic-agent/declarations/main";
  import { toJsonString } from "../../utils/StringUtil";
  import CharacterItem from "../content/Item.svelte";
  import CharacterStatIcon from "../character/CharacterStatIcon.svelte";

  export let value: OutcomeEffect;
</script>

<div>
  {#if "text" in value}
    {value.text}
  {:else if "healthDelta" in value}
    HEALTH
    {value.healthDelta >= 0 ? "+" : ""}{value.healthDelta}
    <CharacterStatIcon kind={{ maxHealth: null }} />
  {:else if "maxHealthDelta" in value}
    MAX HEALTH
    {value.maxHealthDelta >= 0 ? "+" : ""}{value.maxHealthDelta}
    <CharacterStatIcon kind={{ maxHealth: null }} />
  {:else if "goldDelta" in value}
    {value.goldDelta >= 0 ? "+" : ""}{value.goldDelta}
    <CharacterStatIcon kind={{ gold: null }} />
  {:else if "addItem" in value}
    +<CharacterItem item={value.addItem.itemId} />
    {#if value.addItem.removedItemId[0] !== undefined}
      -<CharacterItem item={value.addItem.removedItemId[0]} />
    {/if}
  {:else if "removeItem" in value}
    -<CharacterItem item={value.removeItem} />
  {:else if "swapWeapon" in value}
    +{value.swapWeapon.weaponId}
    -{value.swapWeapon.removedWeaponId}
  {:else}
    NOT IMPLEMENTED LOG ENTRY TYPE {toJsonString(value)}
  {/if}
</div>
