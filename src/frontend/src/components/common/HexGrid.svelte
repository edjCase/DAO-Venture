<script lang="ts">
    import { onMount } from "svelte";
    import HexTile, { AxialCoordinate, HexTileData } from "./HexTile.svelte";

    export let gridData: HexTileData[];
    export let hexSize: number = 60;
    export let onClick: (coord: AxialCoordinate) => void = () => {};

    let selectedTile: number | undefined;

    let svg: SVGSVGElement;

    onMount(() => {
        const bbox = svg.getBBox();
        svg.setAttribute(
            "viewBox",
            `${bbox.x - hexSize} ${bbox.y - hexSize} ${bbox.width + 2 * hexSize} ${bbox.height + 2 * hexSize}`,
        );
    });

    let handleOnClick = (tileId: number) => (coord: AxialCoordinate) => {
        selectedTile = tileId;
        onClick(coord);
    };
</script>

<div>
    <svg bind:this={svg}>
        {#each gridData as tile, id}
            <HexTile
                {tile}
                {id}
                {hexSize}
                faded={tile.faded}
                onClick={handleOnClick(id)}
                selected={selectedTile == id}
            >
                <slot {id} />
            </HexTile>
        {/each}
    </svg>
    {#if selectedTile !== undefined}
        <slot name="tileInfo" {selectedTile} />
    {/if}
</div>
