<script lang="ts">
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import HexGrid, { HexTileData } from "../common/HexGrid.svelte";
  import Location from "./Location.svelte";
  import LocationInfo from "./LocationInfo.svelte";

  let selectedTileId: number | undefined;
  let gridData: HexTileData[] | undefined;

  currentGameStore.subscribe((newGameState) => {
    if (newGameState === undefined) {
      return;
    }
    if ("inProgress" in newGameState.state) {
      if (gridData === undefined) {
        // Set the selected tile to the character's location on the first render
        selectedTileId = Number(
          newGameState.state.inProgress.locations[
            newGameState.state.inProgress.locations.length - 1
          ].id
        );
      }
      gridData = newGameState.state.inProgress.locations.map((location) => {
        return {
          id: Number(location.id),
          kind: { explored: { icon: "" } },
          coordinate: {
            q: Number(location.coordinate.q),
            r: Number(location.coordinate.r),
          },
        };
      });
    } else {
      gridData = undefined;
    }
  });

  let nextScenario = () => {
    if (!gridData) {
      return;
    }
    // TODO this is a hack to get the next location
    let currentIndex = gridData.findIndex(
      (location) => location.id === selectedTileId
    );
    selectedTileId = gridData[currentIndex + 1].id;
  };
</script>

{#if gridData !== undefined}
  <HexGrid {gridData} bind:selectedTileId let:id>
    <Location locationId={BigInt(id)} />
    <div slot="tileInfo" let:selectedTile>
      {#if selectedTile !== undefined}
        <LocationInfo locationId={BigInt(selectedTile)} {nextScenario} />
      {/if}
    </div>
  </HexGrid>
{/if}
