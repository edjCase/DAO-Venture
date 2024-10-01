<script lang="ts">
  import { Accordion, AccordionItem } from "flowbite-svelte";
  import type { ScenarioMetaData } from "../../../../ic-agent/declarations/main";
  import { decodeImageToPixels } from "../../../../utils/PixelUtil";
  import { toJsonString } from "../../../../utils/StringUtil";
  import PixelArtCanvas from "../../../common/PixelArtCanvas.svelte";
  import EntityView from "./EntityView.svelte";
  import ScenarioPathView from "./ScenarioPathView.svelte";
  import UnlockRequirementView from "./UnlockRequirementView.svelte";

  export let scenario: ScenarioMetaData;
</script>

<div>
  <h2 class="text-xl font-bold text-primary-500">Scenario</h2>
  <EntityView entity={scenario} />

  <div class="text-primary-500">Category</div>
  <div>
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

  <div class="text-primary-500">Image</div>
  <div>
    <PixelArtCanvas
      layers={[decodeImageToPixels(scenario.image, 64, 64)]}
      pixelSize={4}
    />
  </div>

  <div class="text-primary-500">Location</div>
  <div>
    {#if "common" in scenario.location}
      Common
    {:else if "zoneIds" in scenario.location}
      Zones: {scenario.location.zoneIds.join(", ")}
    {:else}
      NOT IMPLEMENTED LOCATION {toJsonString(scenario.location)}
    {/if}
  </div>
  <div class="text-primary-500">Paths</div>
  <div>
    <Accordion>
      {#each scenario.paths as path, index}
        <AccordionItem title={path.id}>
          <div slot="header">
            {path.id}
            {#if index === 0}
              (Initial Path)
            {/if}
          </div>
          <ScenarioPathView {path} />
        </AccordionItem>
      {/each}
    </Accordion>
  </div>

  <div class="text-primary-500">Unlock Requirement</div>
  <UnlockRequirementView value={scenario.unlockRequirement} />
</div>
