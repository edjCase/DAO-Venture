<script lang="ts">
  import type { ScenarioMetaData } from "../../../../ic-agent/declarations/main";
  import EntityView from "./EntityView.svelte";
  import UnlockRequirementView from "./UnlockRequirementView.svelte";

  export let scenario: ScenarioMetaData;
</script>

<div class="bg-gray-100 p-4 rounded-lg shadow">
  <h2 class="text-xl font-bold mb-4">Scenario</h2>
  <EntityView entity={scenario} />

  <div class="mt-4">
    <h3 class="text-lg font-semibold mb-2">Data:</h3>
    {#each scenario.data as data}
      <div class="bg-white p-2 rounded mb-2">
        {data.id} ({data.name}):
        {#if "nat" in data.value}
          Nat ({data.value.nat.min}-{data.value.nat.max})
        {:else}
          Text ({#each data.value.text.options as [text, weight], i}{text}: {weight}{i <
            data.value.text.options.length - 1
              ? ", "
              : ""}{/each})
        {/if}
      </div>
    {/each}
  </div>

  <div class="mt-4">
    <span class="font-semibold">Category:</span>
    {#if "other" in scenario.category}Other
    {:else if "store" in scenario.category}Store
    {:else if "combat" in scenario.category}Combat
    {:else}Unknown
    {/if}
  </div>

  <div class="mt-2">
    <span class="font-semibold">Image Id:</span>
    {scenario.imageId}
  </div>

  <div class="mt-2">
    <span class="font-semibold">Location:</span>
    {#if "common" in scenario.location}Common
    {:else if "zoneIds" in scenario.location}Zones: {scenario.location.zoneIds.join(
        ", "
      )}
    {:else}Unknown
    {/if}
  </div>

  <div class="mt-4">
    <h3 class="text-lg font-semibold mb-2">Paths:</h3>
    {#each scenario.paths as path}
      <div class="bg-white p-2 rounded mb-2">
        {path.id}:
        {#if "effects" in path.kind}
          Effects: {path.kind.effects.length}
        {:else}
          Combat
        {/if}
        ({path.paths.length} sub-paths)
      </div>
    {/each}
  </div>

  <UnlockRequirementView value={scenario.unlockRequirement} />
</div>
