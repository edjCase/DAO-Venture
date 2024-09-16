<script lang="ts">
  import type { ScenarioMetaData } from "../../../../ic-agent/declarations/main";
  import { toJsonString } from "../../../../utils/StringUtil";
  import EntityView from "./EntityView.svelte";
  import UnlockRequirementView from "./UnlockRequirementView.svelte";

  export let scenario: ScenarioMetaData;
</script>

<div class="p-4 rounded-lg shadow">
  <h2 class="text-xl font-bold mb-4">Scenario</h2>
  <EntityView entity={scenario} />

  <div class="mt-4">
    <span class="font-semibold">Category:</span>
    {#if "other" in scenario.category}
      Other
    {:else if "store" in scenario.category}
      Store
    {:else if "combat" in scenario.category}
      Combat
    {:else}
      NOT IMPLEMENTED CATEGORY {toJsonString(scenario.category)}
    {/if}
  </div>

  <div class="mt-2">
    <span class="font-semibold">Image Id:</span>
    {scenario.imageId}
  </div>

  <div class="mt-2">
    <span class="font-semibold">Location:</span>
    {#if "common" in scenario.location}
      Common
    {:else if "zoneIds" in scenario.location}
      Zones: {scenario.location.zoneIds.join(", ")}
    {:else}
      NOT IMPLEMENTED LOCATION {toJsonString(scenario.location)}
    {/if}
  </div>

  <div class="mt-4">
    <h3 class="text-lg font-semibold mb-2">Paths:</h3>
    {#each scenario.paths as path}
      <div class="p-2 rounded mb-2">
        {path.id}:
        <!-- TODO -->
        {#if "choice" in path.kind}
          Choices: {path.kind.choice.choices.length}
        {:else if "combat" in path.kind}
          Combat
        {:else if "reward" in path.kind}
          Reward
        {:else}
          NOT IMPLEMENTED PATH KIND {toJsonString(path.kind)}
        {/if}
      </div>
    {/each}
  </div>

  <UnlockRequirementView value={scenario.unlockRequirement} />
</div>
