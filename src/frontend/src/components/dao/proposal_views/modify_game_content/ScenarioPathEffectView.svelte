<script lang="ts">
  import { PathEffect } from "../../../../ic-agent/declarations/main";
  import { toJsonString } from "../../../../utils/StringUtil";
  import NatValueView from "./NatValueView.svelte";

  export let value: PathEffect;
</script>

<div>
  {#if "damage" in value}
    <div class="text-primary-500">Damage</div>
    <NatValueView value={value.damage} />
  {:else if "heal" in value}
    <div class="text-primary-500">Heal</div>
    <NatValueView value={value.heal} />
  {:else if "removeItemWithTags" in value}
    <div class="text-primary-500">Remove Item With Tags</div>
    <div>
      {value.removeItemWithTags.join(", ")}
    </div>
  {:else if "achievement" in value}
    <div class="text-primary-500">Achievement</div>
    <div>{value.achievement}</div>
  {:else if "addItem" in value}
    <div class="text-primary-500">Add Item</div>
    <div>{value.addItem}</div>
  {:else if "addItemWithTags" in value}
    <div class="text-primary-500">Add Item With Tags</div>
    <div>
      {value.addItemWithTags.join(", ")}
    </div>
  {:else if "removeGold" in value}
    <div class="text-primary-500">Remove Gold</div>
    <NatValueView value={value.removeGold} />
  {:else if "removeItem" in value}
    <div class="text-primary-500">Remove Item</div>
    <div>{value.removeItem}</div>
  {:else}
    NOT IMPLEMENTED PATH EFFECT: {toJsonString(value)}
  {/if}
</div>
