<script lang="ts">
  import { onMount } from "svelte";
  import { Select, Label } from "flowbite-svelte";
  import { UnlockRequirement } from "../../../../ic-agent/declarations/main";

  export let unlockRequirement: UnlockRequirement | undefined;

  let achievements: { id: string; name: string }[] = [];
  let selectedAchievementId: string | undefined;

  onMount(async () => {
    // TODO
    // const mainAgent = await mainAgentFactory();
    try {
      // const fetchedAchievements = await mainAgent.getAchievements();
      // achievements = fetchedAchievements.map((a) => ({
      //   id: a.id,
      //   name: a.name,
      // }));

      // Set initial value if unlockRequirement is defined
      if (unlockRequirement && "acheivementId" in unlockRequirement) {
        selectedAchievementId = unlockRequirement.acheivementId;
      }
    } catch (error) {
      console.error("Error fetching achievements:", error);
    }
  });

  $: {
    if (selectedAchievementId) {
      unlockRequirement = { acheivementId: selectedAchievementId };
    } else {
      unlockRequirement = undefined;
    }
  }
</script>

<div>
  <Label for="unlockRequirement">Unlock Requirement (Achievement)</Label>
  <Select
    id="unlockRequirement"
    items={achievements.map((a) => ({ value: a.id, name: a.name }))}
    bind:value={selectedAchievementId}
    placeholder="Select an achievement"
  />
</div>
