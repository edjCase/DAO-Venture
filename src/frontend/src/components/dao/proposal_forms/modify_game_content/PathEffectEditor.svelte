<script lang="ts">
  import { achievementStore } from "../../../../stores/AchievementStore";
  import EntitySelector from "./EntitySelector.svelte";
  import NatValueEditor from "./NatValueEditor.svelte";
  import { PathEffect } from "../../../../ic-agent/declarations/main";
  import { toJsonString } from "../../../../utils/StringUtil";
  import { Input, Button } from "flowbite-svelte";

  export let value: PathEffect;

  function addItem(list: string[]) {
    list.push("");
    value = { ...value }; // Trigger reactivity
  }

  function removeItem(list: string[], index: number) {
    list.splice(index, 1);
    value = { ...value }; // Trigger reactivity
  }
</script>

{#if "damage" in value}
  <NatValueEditor bind:value={value.damage} />
{:else if "heal" in value}
  <NatValueEditor bind:value={value.heal} />
{:else if "removeGold" in value}
  <NatValueEditor bind:value={value.removeGold} />
{:else if "addItem" in value}
  <Input type="text" bind:value={value.addItem} />
{:else if "removeItem" in value}
  <Input type="text" bind:value={value.removeItem} />
{:else if "addItemWithTags" in value}
  <div>
    {#each value.addItemWithTags as _, index}
      <div class="flex items-center mb-2">
        <Input type="text" bind:value={value.addItemWithTags[index]} />
        <Button
          color="red"
          size="xs"
          class="ml-2"
          on:click={() => {
            if ("addItemWithTags" in value) {
              removeItem(value.addItemWithTags, index);
            }
          }}>Remove</Button
        >
      </div>
    {/each}
    <Button
      color="green"
      size="sm"
      on:click={() => {
        if ("addItemWithTags" in value) {
          addItem(value.addItemWithTags);
        }
      }}>Add Item</Button
    >
  </div>
{:else if "removeItemWithTags" in value}
  <div>
    {#each value.removeItemWithTags as _, index}
      <div class="flex items-center mb-2">
        <Input type="text" bind:value={value.removeItemWithTags[index]} />
        <Button
          color="red"
          size="xs"
          class="ml-2"
          on:click={() => {
            if ("removeItemWithTags" in value) {
              removeItem(value.removeItemWithTags, index);
            }
          }}>Remove</Button
        >
      </div>
    {/each}
    <Button
      color="green"
      size="sm"
      on:click={() => {
        if ("removeItemWithTags" in value) {
          addItem(value.removeItemWithTags);
        }
      }}>Add Item</Button
    >
  </div>
{:else if "achievement" in value}
  <EntitySelector
    bind:value={value.achievement}
    store={achievementStore}
    label="Achievement"
  />
{:else}
  NOT IMPLEMENTED SCENARIO EFFECT : {toJsonString(value)}
{/if}
