<script lang="ts">
  import { ChoiceRequirement } from "../../ic-agent/declarations/main";
  import { toJsonString } from "../../utils/StringUtil";
  import Icon from "../character/Icon.svelte";

  export let value: ChoiceRequirement;
</script>

<div>
  Requirements:
  {#if "stat" in value}
    {@const [statKind, v] = value.stat}
    <div class="text-sm">
      {v >= 0 ? "+" : ""}{v}
      <Icon kind={statKind} />
    </div>
  {:else if "race" in value}
    <div class="text-sm">
      {value.race}
    </div>
  {:else if "class" in value}
    <div class="text-sm">
      {value.class}
    </div>
  {:else if "gold" in value}
    <div class="text-sm">
      +{value.gold}
      <Icon kind={{ gold: null }} />
    </div>
  {:else if "item" in value}
    <div class="text-sm">
      Item: {value.item}
    </div>
  {:else if "trait" in value}
    <div class="text-sm">
      Trait: {value.trait}
    </div>
  {:else if "all" in value}
    <div class="text-sm">All TODO</div>
  {:else if "any" in value}
    <div class="text-sm">Any TODO</div>
  {:else}
    NOT IMPLEMENTED REQUIREMENT {toJsonString(value)}
  {/if}
</div>
