<script lang="ts">
  import { ScenarioWithMetaData } from "../../ic-agent/declarations/main";
  import { decodeImageToPixels } from "../../utils/PixelUtil";
  import { toJsonString } from "../../utils/StringUtil";
  import HexGrid, { HexTileData } from "../common/HexGrid.svelte";
  import { AxialCoordinate } from "../common/HexTile.svelte";
  import PixelArtCanvas from "../common/PixelArtCanvas.svelte";

  export let selectedScenarioId: number;
  export let scenarios: ScenarioWithMetaData[];

  let selectedTile: AxialCoordinate = { q: selectedScenarioId, r: 0 };
  let gridData: HexTileData[] | undefined;

  let size = 32;

  $: selectedScenarioId = selectedTile.q;
</script>

{#if gridData !== undefined}
  <HexGrid {gridData} bind:selectedTile>
    <g>
      <svg x={-size / 2} y={-size / 2} width={size} height={size}>
        <foreignObject width={size} height={size}>
          {#if scenarios[selectedScenarioId] !== undefined}
            {@const scenario = scenarios[selectedScenarioId]}
            {#if "started" in scenario.state}
              <PixelArtCanvas
                layers={[
                  decodeImageToPixels(
                    scenario.state.started.metaData.image,
                    64,
                    64
                  ),
                ]}
                pixelSize={0.5}
              />
            {:else if "notStarted" in scenario.state}
              CROSSROADS
            {:else}
              NOT IMPLEMENTED SCENARIO STATE {toJsonString(scenario.state)}
            {/if}
          {/if}
        </foreignObject>
      </svg>
    </g>
  </HexGrid>
{/if}
