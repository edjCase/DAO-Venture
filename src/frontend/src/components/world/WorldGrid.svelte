<script lang="ts">
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import { scenarioStore } from "../../stores/ScenarioStore";
  import GameImage from "../common/GameImage.svelte";
  import HexGrid, { HexTileData } from "../common/HexGrid.svelte";
  import { AxialCoordinate } from "../common/HexTile.svelte";
  import Scenario from "../scenario/Scenario.svelte";

  let selectedTile: AxialCoordinate | undefined;
  let gridData: HexTileData[] | undefined;

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
  let size = 40;

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
            <GameImage id={scenarios[coordinate.q].metaData.imageId} />
          {/if}
        </foreignObject>
      </svg>
    </g>
    <div slot="tileInfo">
      {#if scenario !== undefined}
        <Scenario {scenario} {nextScenario} />
      {/if}
    </div>
  </HexGrid>
{/if}
