<script lang="ts" context="module">
  export interface HexTileData {
    coordinate: AxialCoordinate;
  }
</script>

<script lang="ts">
  import { onMount } from "svelte";
  import { tweened } from "svelte/motion";
  import { cubicOut } from "svelte/easing";
  import HexTile, {
    AxialCoordinate,
    coordinateEquals,
    getHexPolygonPoints,
  } from "./HexTile.svelte";

  export let gridData: HexTileData[];
  export let hexSize: number = 20;
  export let selectedTile: AxialCoordinate | undefined;

  let svg: SVGSVGElement;
  let isPanning = false;
  let lastX: number;

  // Use a tweened store for smooth animation
  const panX = tweened(0, {
    duration: 300,
    easing: cubicOut,
  });

  function hexToPixelX(q: number, r: number): number {
    const hexWidth = hexSize * Math.sqrt(3);
    const viewBoxCenter = -hexSize;
    return viewBoxCenter + hexWidth * (q + r / 2) - hexWidth / 2;
  }

  function findNearestHex(x: number): HexTileData {
    return gridData.reduce((nearest, current) => {
      const currentX = hexToPixelX(current.coordinate.q, current.coordinate.r);
      const nearestX = hexToPixelX(nearest.coordinate.q, nearest.coordinate.r);
      return Math.abs(currentX - x) < Math.abs(nearestX - x)
        ? current
        : nearest;
    });
  }

  function centerOnHex(hexData: HexTileData) {
    const hexX = hexToPixelX(hexData.coordinate.q, hexData.coordinate.r);
    panX.set(hexX); // This will trigger a smooth animation
  }

  onMount(() => {
    const verticalPadding = hexSize * 0.1;
    const x = -hexSize * 10;
    const y = -hexSize - verticalPadding;
    const width = hexSize * 24;
    const height = hexSize * 2 + verticalPadding * 2;
    svg.setAttribute("viewBox", `${x} ${y} ${width} ${height}`);

    svg.addEventListener("mousedown", startPan);
    window.addEventListener("mousemove", pan);
    window.addEventListener("mouseup", endPan);
  });

  function startPan(event: MouseEvent) {
    if (!svg) return;
    isPanning = true;
    lastX = event.clientX;
    svg.style.cursor = "grabbing";
  }

  function pan(event: MouseEvent) {
    if (!svg || !isPanning) return;

    const dx = event.clientX - lastX;
    const svgRect = svg.getBoundingClientRect();
    const viewBox = svg.viewBox.baseVal;

    let newPanX = $panX - (dx / svgRect.width) * viewBox.width;

    panX.set(newPanX, { duration: 0 }); // Update without animation during panning

    lastX = event.clientX;
  }

  function endPan() {
    if (!svg) return;
    isPanning = false;
    svg.style.cursor = "move";

    // Snap to nearest hex with animation
    const nearestHex = findNearestHex($panX);
    centerOnHex(nearestHex);
    selectedTile = nearestHex.coordinate;
  }

  let handleOnClickTile = (coord: AxialCoordinate) => {
    selectedTile = coord;

    const selectedHex = gridData.find((tile) =>
      coordinateEquals(tile.coordinate, selectedTile!)
    );
    if (selectedHex) {
      centerOnHex(selectedHex);
    }
  };

  // Watch for changes in selectedTileId
  $: if (selectedTile !== undefined) {
    const selectedHex = gridData.find((tile) =>
      coordinateEquals(tile.coordinate, selectedTile!)
    );
    if (selectedHex) {
      centerOnHex(selectedHex);
    }
  }
</script>

<div>
  <svg bind:this={svg} cursor="move" width="100%" height="100%">
    <g transform={`translate(${-$panX},0)`}>
      {#each gridData as tile}
        <HexTile
          coordinate={tile.coordinate}
          {hexSize}
          onClick={handleOnClickTile}
          selected={coordinateEquals(
            tile.coordinate,
            selectedTile || { q: 0, r: 0 }
          )}
        >
          <slot />
        </HexTile>
      {/each}
      <!-- Draw a white border around the selected tile LAST -->
      {#if selectedTile !== undefined}
        <polygon
          points={getHexPolygonPoints(hexSize, selectedTile)}
          fill="none"
          stroke="white"
          stroke-width="3"
          pointer-events="none"
        />
      {/if}
    </g>
  </svg>
</div>
