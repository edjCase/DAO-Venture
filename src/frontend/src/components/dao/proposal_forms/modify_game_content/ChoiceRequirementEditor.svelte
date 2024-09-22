<script lang="ts">
  import { Input } from "flowbite-svelte";
  import { ChoiceRequirement } from "../../../../ic-agent/declarations/main";
  import Label from "flowbite-svelte/Label.svelte";
  import { toJsonString } from "../../../../utils/StringUtil";
  import AttributeChoiceRequirementChooser from "./AttributeChoiceRequirementChooser.svelte";
  import TagsEditor from "./TagsEditor.svelte";

  export let value: ChoiceRequirement;
</script>

{#if "attribute" in value}
  <Label>Attribute</Label>
  <AttributeChoiceRequirementChooser bind:value={value.attribute} />
{:else if "itemWithTags" in value}
  <Label>Items with tags</Label>
  <TagsEditor bind:value={value.itemWithTags} />
{:else if "gold" in value}
  <Label>Gold</Label>
  <Input
    type="number"
    bind:value={value.gold}
    placeholder="Enter gold amount"
  />
{:else}
  NOT IMPLEMETED CHOICE REQUIREMENT {toJsonString(value)}
{/if}
