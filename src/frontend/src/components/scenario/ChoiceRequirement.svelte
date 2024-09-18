<script lang="ts">
  import { ChoiceRequirement } from "../../ic-agent/declarations/main";
  import { toJsonString } from "../../utils/StringUtil";
  import CharacterStatIcon from "../character/CharacterStatIcon.svelte";

  export let value: ChoiceRequirement;
</script>

<div>
  Requirements:
  {#if "race" in value}
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
      <CharacterStatIcon kind={{ gold: null }} />
    </div>
  {:else if "itemWithTags" in value}
    <div class="text-sm">
      {#if value.itemWithTags.length == 0}
        Any item
      {:else}
        Item with: {value.itemWithTags.join(", ")}
      {/if}
    </div>
  {:else}
    NOT IMPLEMENTED REQUIREMENT {toJsonString(value)}
  {/if}
</div>
