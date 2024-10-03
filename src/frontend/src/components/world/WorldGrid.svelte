<script lang="ts">
  import { CharacterWithMetaData } from "../../ic-agent/declarations/main";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import { scenarioStore } from "../../stores/ScenarioStore";
  import { decodeImageToPixels } from "../../utils/PixelUtil";
  import HexGrid, { HexTileData } from "../common/HexGrid.svelte";
  import { AxialCoordinate } from "../common/HexTile.svelte";
  import PixelArtCanvas from "../common/PixelArtCanvas.svelte";
  import Scenario from "../scenario/Scenario.svelte";

  let selectedTile: AxialCoordinate | undefined;
  let gridData: HexTileData[] | undefined;
  let character: CharacterWithMetaData | undefined;

  $: scenarios = $scenarioStore;
  $: currentGame = $currentGameStore;

  $: {
    if (
      currentGame !== undefined &&
      scenarios !== undefined &&
      scenarios.length > 0
    ) {
      if ("inProgress" in currentGame.state) {
        if (gridData === undefined) {
          // Set the selected tile to the character's location on the first render
          selectedTile = {
            q: scenarios.length - 1,
            r: 0,
          };
        }
        gridData = scenarios.map((s, i) => {
          return {
            id: s.id,
            coordinate: {
              q: i,
              r: 0,
            },
          };
        });
      } else {
        gridData = undefined;
      }
    }
  }

  $: {
    character = undefined;
    if (currentGame !== undefined) {
      if ("inProgress" in currentGame.state) {
        character = currentGame.state.inProgress.character;
      }
    }
  }

  let nextScenario = () => {
    if (!selectedTile) {
      return;
    }
    // TODO this is a hack to get the next location
    selectedTile = {
      q: selectedTile.q + 1,
      r: 0,
    };
  };
  let size = 32;

  $: scenario =
    selectedTile !== undefined
      ? scenarios?.find((s) => Number(s.id) === selectedTile!.q) // TODO this is a hack
      : undefined;
</script>

{#if gridData !== undefined}
  <HexGrid {gridData} bind:selectedTile let:coordinate>
    <g>
      <svg x={-size / 2} y={-size / 2} width={size} height={size}>
        <foreignObject width={size} height={size}>
          {#if scenarios[coordinate.q] !== undefined}
            <PixelArtCanvas
              layers={[
                decodeImageToPixels(
                  scenarios[coordinate.q].metaData.image,
                  64,
                  64
                ),
              ]}
              pixelSize={0.5}
            />
          {/if}
        </foreignObject>
      </svg>
    </g>
    <div slot="tileInfo">
      {#if scenario !== undefined && character !== undefined}
        <Scenario {scenario} {nextScenario} {character} />
      {/if}
    </div>
  </HexGrid>
{/if}
