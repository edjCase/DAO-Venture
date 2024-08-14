<script lang="ts" context="module">
    export interface HexTileData {
        id: number;
        kind: HexTileKind;
        coordinate: AxialCoordinate;
    }
</script>

<script lang="ts">
    import { onMount } from "svelte";
    import HexTile, { AxialCoordinate, HexTileKind } from "./HexTile.svelte";

    export let gridData: HexTileData[];
    export let hexSize: number = 60;
    export let selectedTileId: number | undefined;
    export let onClick: (coord: AxialCoordinate) => void = () => {};

    let svg: SVGSVGElement;
    let svgGroup: SVGGElement;
    let panX = 0;
    let isPanning = false;
    let lastX: number;

    onMount(() => {
        const verticalPadding = hexSize * 0.1; // Add some vertical padding
        const height = hexSize * 2 + verticalPadding * 2; // One hex tall plus padding
        svg.setAttribute(
            "viewBox",
            `${-hexSize * 2} ${-hexSize - verticalPadding} ${hexSize * 4} ${height}`,
        );

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

        // Only update panX for horizontal movement
        panX -= (dx / svgRect.width) * viewBox.width;
        let minX = 0;
        if (panX < minX) {
            panX = minX;
        }

        let maxX = hexSize * gridData.length - 1;
        if (panX > maxX) {
            panX = maxX;
        }

        lastX = event.clientX;

        updateTransform();
    }

    function endPan() {
        if (!svg) return;
        isPanning = false;
        svg.style.cursor = "move";
    }

    function updateTransform() {
        svgGroup.setAttribute("transform", `translate(${-panX},0)`);
    }

    let handleOnClick = (tileId: number) => (coord: AxialCoordinate) => {
        console.log("Clicked on tile", tileId, coord);
        selectedTileId = tileId;
        onClick(coord);
    };
</script>

<div>
    <svg bind:this={svg} cursor="move" width="100%" height="100%">
        <g bind:this={svgGroup}>
            {#each gridData as tile}
                <HexTile
                    coordinate={tile.coordinate}
                    kind={tile.kind}
                    id={tile.id}
                    {hexSize}
                    onClick={handleOnClick(tile.id)}
                    selected={selectedTileId == tile.id}
                >
                    <slot id={tile.id} />
                </HexTile>
            {/each}
        </g>
    </svg>
    {#if selectedTileId !== undefined}
        <slot name="tileInfo" selectedTile={selectedTileId} />
    {/if}
</div>
