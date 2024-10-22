<script lang="ts">
  import { Button, Hr } from "flowbite-svelte";
  import { CompletedScenario } from "../../ic-agent/declarations/main";
  import { decodeImageToPixels } from "../../utils/PixelUtil";
  import PixelArtCanvas from "../common/PixelArtCanvas.svelte";
  import ScenarioStages from "./ScenarioStages.svelte";
  import { scenarioMetaDataStore } from "../../stores/ScenarioMetaDataStore";

  export let scenario: CompletedScenario;
  export let nextLocation: () => void;

  $: metaDataList = $scenarioMetaDataStore;
  $: metaData = metaDataList?.find((m) => m.id === scenario.metaDataId);
</script>

<div class="text-center">
  <div class="text-4xl font-semibold text-center mb-4 text-primary-500">
    {metaData?.name}
  </div>
  <div class="flex justify-center">
    {#if metaData?.image}
      <PixelArtCanvas
        layers={[decodeImageToPixels(metaData.image, 64, 64)]}
        pixelSize={4}
      />
    {/if}
  </div>
  <div class="text-3xl my-2">Scenario Complete</div>
  <Button on:click={nextLocation} class="mb-4">Continue</Button>

  {#if scenario.stages.length > 0}
    <Hr />
    <div class="text-4xl text-primary-500 mb-2">Scenario Log</div>
    <ScenarioStages stages={scenario.stages} />
    {metaData?.description}
  {/if}
</div>
