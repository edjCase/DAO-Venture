<script lang="ts">
  import { achievementStore } from "../../../../stores/AchievementStore";
  import EntitySelector from "./EntitySelector.svelte";
  import NatValueEditor from "./NatValueEditor.svelte";
  import { PathEffect } from "../../../../ic-agent/declarations/main";
  import { toJsonString } from "../../../../utils/StringUtil";
  import { itemStore } from "../../../../stores/ItemStore";
  import TagsEditor from "./CommaDelimitedEditor.svelte";

  export let value: PathEffect;
</script>

{#if "damage" in value}
  <NatValueEditor bind:value={value.damage} />
{:else if "heal" in value}
  <NatValueEditor bind:value={value.heal} />
{:else if "removeGold" in value}
  <NatValueEditor bind:value={value.removeGold} />
{:else if "addItem" in value}
  <EntitySelector bind:value={value.addItem} store={itemStore} label="Item" />
{:else if "removeItem" in value}
  <EntitySelector
    bind:value={value.removeItem}
    store={itemStore}
    label="Item"
  />
{:else if "addItemWithTags" in value}
  <TagsEditor bind:value={value.addItemWithTags} />
{:else if "removeItemWithTags" in value}
  <TagsEditor bind:value={value.removeItemWithTags} />
{:else if "achievement" in value}
  <EntitySelector
    bind:value={value.achievement}
    store={achievementStore}
    label="Achievement"
  />
{:else}
  NOT IMPLEMENTED SCENARIO EFFECT : {toJsonString(value)}
{/if}
