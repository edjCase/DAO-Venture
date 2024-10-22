<script lang="ts">
  import {
    CompletedRouteLocationKind,
    InProgressRouteLocationKind,
    RouteLocation,
  } from "../../ic-agent/declarations/main";
  import HexGrid, { HexTileData } from "../common/HexGrid.svelte";
  import { AxialCoordinate } from "../common/HexTile.svelte";
  import ScenarioIcon from "../scenario/ScenarioIcon.svelte";
  import ZoneIcon from "./ZoneIcon.svelte";

  export let selectedLocationIndex: number;
  export let route: RouteLocation[];
  export let completedLocations: CompletedRouteLocationKind[];
  export let currentLocation: InProgressRouteLocationKind;

  $: selectedTile = { q: selectedLocationIndex, r: 0 };
  let gridData: HexTileData[] | undefined;

  $: gridData = route.map((_, i) => ({
    coordinate: { q: i, r: 0 },
    selectable: i <= completedLocations.length,
  }));

  let size = 32;

  let onSelect = (c: AxialCoordinate) => {
    selectedTile = c;
    selectedLocationIndex = c.q;
  };
</script>

{#if gridData !== undefined}
  <HexGrid {gridData} let:coordinate {selectedTile} {onSelect}>
    <g>
      <svg x={-size / 2} y={-size / 2} width={size} height={size}>
        <foreignObject width={size} height={size}>
          {#if route[coordinate.q] !== undefined}
            {@const location = route[coordinate.q]}
            <div class="flex h-full w-full items-center justify-center">
              {#if coordinate.q > completedLocations.length}
                <ZoneIcon zoneId={location.zoneId} />
              {:else if coordinate.q == completedLocations.length}
                <ScenarioIcon
                  metaDataId={currentLocation.scenario.metaDataId}
                />
              {:else}
                {@const completedLocation = completedLocations[coordinate.q]}
                <ScenarioIcon
                  metaDataId={completedLocation.scenario.metaDataId}
                />
              {/if}
            </div>
          {/if}
        </foreignObject>
      </svg>
    </g>
  </HexGrid>
{/if}
