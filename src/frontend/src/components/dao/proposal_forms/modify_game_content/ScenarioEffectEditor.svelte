<script lang="ts">
  import { achievementStore } from "../../../../stores/AchievementStore";
  import EntitySelector from "./EntitySelector.svelte";
  import NatValueEditor from "./NatValueEditor.svelte";
  import { Effect } from "../../../../ic-agent/declarations/main";
  import { toJsonString } from "../../../../utils/StringUtil";
  import RandomOrSpecificTextValueChooser from "./RandomOrSpecificTextValueChooser.svelte";

  export let value: Effect;
</script>

{#if "damage" in value}
  <NatValueEditor bind:value={value.damage} />
{:else if "heal" in value}
  <NatValueEditor bind:value={value.heal} />
{:else if "removeGold" in value}
  <NatValueEditor bind:value={value.removeGold} />
{:else if "addItem" in value}
  <RandomOrSpecificTextValueChooser bind:value={value.addItem} />
{:else if "removeItem" in value}
  <RandomOrSpecificTextValueChooser bind:value={value.removeItem} />
{:else if "achievement" in value}
  <EntitySelector
    bind:value={value.achievement}
    store={achievementStore}
    label="Achievement"
  />
{:else}
  NOT IMPLEMENETED SCENARIO EFFECT : {toJsonString(value)}
{/if}
