<script lang="ts">
    import { onMount } from "svelte";
    import HexTile, { AxialCoordinate, HexTileKind } from "./HexTile.svelte";

    interface HexTileData {
        kind: HexTileKind;
        coordinate: AxialCoordinate;
    }

    export let gridData: HexTileData[];
    export let hexSize: number = 60;
    export let onClick: (coord: AxialCoordinate) => void = () => {};

    let selectedTile: number | undefined;
    let svg: SVGSVGElement;
    let svgGroup: SVGGElement;
    let zoom = 1;
    let panX = 0;
    let panY = 0;
    let isPanning = false;
    let lastX: number, lastY: number;

    onMount(() => {
        const bbox = svgGroup.getBBox();
        svg.setAttribute(
            "viewBox",
            `${bbox.x - hexSize} ${bbox.y - hexSize} ${bbox.width + 2 * hexSize} ${bbox.height + 2 * hexSize}`,
        );

        svg.addEventListener("wheel", handleWheel, { passive: false });
        svg.addEventListener("mousedown", startPan);
        window.addEventListener("mousemove", pan);
        window.addEventListener("mouseup", endPan);
    });

    function handleWheel(event: WheelEvent) {
        if (!svg) return;
        event.preventDefault();
        const delta = event.deltaY;
        const scaleAmount = delta > 0 ? 0.9 : 1.1;

        const svgRect = svg.getBoundingClientRect();
        const mouseX = event.clientX - svgRect.left;
        const mouseY = event.clientY - svgRect.top;

        const viewBox = svg.viewBox.baseVal;
        const viewX = viewBox.x + (mouseX / svgRect.width) * viewBox.width;
        const viewY = viewBox.y + (mouseY / svgRect.height) * viewBox.height;

        zoom *= scaleAmount;
        panX = viewX - (viewX - panX) * scaleAmount;
        panY = viewY - (viewY - panY) * scaleAmount;

        updateTransform();
    }

    function startPan(event: MouseEvent) {
        if (!svg) return;
        isPanning = true;
        lastX = event.clientX;
        lastY = event.clientY;
        svg.style.cursor = "grabbing";
    }

    function pan(event: MouseEvent) {
        if (!svg) return;
        if (!isPanning) return;

        const dx = event.clientX - lastX;
        const dy = event.clientY - lastY;

        const svgRect = svg.getBoundingClientRect();
        const viewBox = svg.viewBox.baseVal;

        // Invert the direction of panning
        panX += (dx / svgRect.width) * viewBox.width;
        panY += (dy / svgRect.height) * viewBox.height;

        lastX = event.clientX;
        lastY = event.clientY;

        updateTransform();
    }

    function endPan() {
        if (!svg) return;
        isPanning = false;
        svg.style.cursor = "move";
    }

    function updateTransform() {
        svgGroup.setAttribute(
            "transform",
            `translate(${panX},${panY}) scale(${zoom})`,
        );
    }

    let handleOnClick = (tileId: number) => (coord: AxialCoordinate) => {
        selectedTile = tileId;
        onClick(coord);
    };
</script>

<div>
    <svg bind:this={svg} cursor="move" width="100%" height="100%">
        <g bind:this={svgGroup}>
            {#each gridData as tile, id}
                <HexTile
                    coordinate={tile.coordinate}
                    kind={tile.kind}
                    {id}
                    {hexSize}
                    onClick={handleOnClick(id)}
                    selected={selectedTile == id}
                >
                    <slot {id} />
                </HexTile>
            {/each}
        </g>
    </svg>
    {#if selectedTile !== undefined}
        <slot name="tileInfo" {selectedTile} />
    {/if}
</div>
