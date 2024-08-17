<script lang="ts">
  import { gameStateStore } from "../../stores/GameStateStore";
  import HexGrid, { HexTileData } from "../common/HexGrid.svelte";
  import Location from "./Location.svelte";
  import LocationInfo from "./LocationInfo.svelte";

  let selectedTileId: number | undefined;
  let gridData: HexTileData[] | undefined;

  gameStateStore.subscribe((newGameState) => {
    if (newGameState === undefined) {
      return;
    }
    if ("inProgress" in newGameState) {
      if (gridData === undefined) {
        // Set the selected tile to the character's location on the first render
        selectedTileId = Number(newGameState.inProgress.characterLocationId);
      }
      gridData = newGameState.inProgress.locations.map((location) => {
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
</script>

{#if gridData !== undefined}
  <HexGrid {gridData} bind:selectedTileId let:id>
    <Location locationId={BigInt(id)} />
    <div slot="tileInfo" let:selectedTile>
      {#if selectedTile !== undefined}
        <LocationInfo locationId={BigInt(selectedTile)} />
      {/if}
    </div>
  </HexGrid>
{/if}
