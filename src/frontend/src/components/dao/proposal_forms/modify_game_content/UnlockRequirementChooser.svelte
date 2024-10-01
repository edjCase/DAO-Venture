<script lang="ts">
  import { Select, SelectOptionType } from "flowbite-svelte";
  import { UnlockRequirement } from "../../../../ic-agent/declarations/main";
  import EntitySelector from "./EntitySelector.svelte";
  import { toJsonString } from "../../../../utils/StringUtil";
  import { achievementStore } from "../../../../stores/AchievementStore";

  export let unlockRequirement: UnlockRequirement;

  let items: SelectOptionType<string>[] = [
    { value: "none", name: "None" },
    { value: "achievement", name: "Achievement" },
  ];
  let selectedAchievementId: string = Object.keys(unlockRequirement)[0];

  let updateUnlockRequirement = () => {
    if (selectedAchievementId === "none") {
      unlockRequirement = { none: null };
    } else {
      unlockRequirement = { achievementId: selectedAchievementId };
    }
  };
</script>

<div>
  <Select
    id="unlockRequirement"
    {items}
    bind:value={selectedAchievementId}
    on:change={updateUnlockRequirement}
  />
  {#if "achievementId" in unlockRequirement}
    <EntitySelector
      bind:value={selectedAchievementId}
      store={achievementStore}
      label="Achievement"
    />
  {:else if "none" in unlockRequirement}
    <span></span>
  {:else}
    NOT IMPLEMENTED UNLOCK REQUIREMENT: {toJsonString(unlockRequirement)}
  {/if}
</div>
