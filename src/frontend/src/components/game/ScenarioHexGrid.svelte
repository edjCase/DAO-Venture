<script lang="ts">
  import { ScenarioWithMetaData } from "../../ic-agent/declarations/main";
  import { decodeImageToPixels } from "../../utils/PixelUtil";
  import { toJsonString } from "../../utils/StringUtil";
  import HexGrid, { HexTileData } from "../common/HexGrid.svelte";
  import { AxialCoordinate } from "../common/HexTile.svelte";
  import PixelArtCanvas from "../common/PixelArtCanvas.svelte";
  import ScenarioKindIcon from "../scenario/ScenarioKindIcon.svelte";

  export let currentScenarioId: number;
  export let selectedScenarioId: number;
  export let scenarios: ScenarioWithMetaData[];

  $: selectedTile = { q: selectedScenarioId, r: 0 };
  let gridData: HexTileData[] | undefined;

  $: gridData = scenarios.map((_, i) => ({
    coordinate: { q: i, r: 0 },
    selectable: i <= currentScenarioId,
  }));

  let size = 32;

  let onSelect = (c: AxialCoordinate) => {
    selectedTile = c;
    selectedScenarioId = c.q;
  };
</script>

{#if gridData !== undefined}
  <HexGrid {gridData} let:coordinate {selectedTile} {onSelect}>
    <g>
      <svg x={-size / 2} y={-size / 2} width={size} height={size}>
        <foreignObject width={size} height={size}>
          {#if scenarios[coordinate.q] !== undefined}
            {@const scenario = scenarios[coordinate.q]}
            <div class="flex h-full w-full items-center justify-center">
              {#if coordinate.q > currentScenarioId}
                -
              {:else if "started" in scenario.state}
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
                {@const notStartedState = scenario.state.notStarted}
                {#if notStartedState.options.length == 1}
                  <ScenarioKindIcon value={notStartedState.options[0]} />
                {:else}
                  🔀
                {/if}
              {:else}
                NOT IMPLEMENTED SCENARIO STATE {toJsonString(scenario.state)}
              {/if}
            </div>
          {/if}
        </foreignObject>
      </svg>
    </g>
  </HexGrid>
{/if}
