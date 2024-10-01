<script lang="ts">
  import { ChoiceRequirement } from "../../../../ic-agent/declarations/main";
  import { toJsonString } from "../../../../utils/StringUtil";
  import CharacterAttributeIcon from "../../../character/CharacterAttributeIcon.svelte";
  import CharacterStatIcon from "../../../character/CharacterStatIcon.svelte";

  export let value: ChoiceRequirement;
</script>

<div>
  {#if "attribute" in value}
    {value.attribute.value}
    <CharacterAttributeIcon value={value.attribute.attribute} />
  {:else if "itemWithTags" in value}
    Item with tags: {value.itemWithTags.join(", ")}
  {:else if "gold" in value}
    {value.gold} <CharacterStatIcon kind={{ gold: null }} />
  {:else}
    NOT IMPLEMENTED CHOICE REQUIREMENT: {toJsonString(value)}
  {/if}
</div>
