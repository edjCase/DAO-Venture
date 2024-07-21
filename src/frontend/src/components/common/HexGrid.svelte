<script lang="ts">
    import { Title } from "chart.js";
    import { onMount } from "svelte";

    interface AxialCoord {
        q: number; // top left -> bottom right
        r: number; // bottom -> top
    }

    interface HexTile {
        coord: AxialCoord;
        value: number;
    }

    export let gridData: HexTile[];
    export let hexSize: number = 30;
    export let onClick: (coord: AxialCoord) => void = () => {};

    let svg: SVGSVGElement;

    function hexToPixel(hex: AxialCoord): { x: number; y: number } {
        const x = hexSize * ((3 / 2) * hex.q);
        const y = hexSize * ((Math.sqrt(3) / 2) * hex.q + Math.sqrt(3) * hex.r);

        return { x, y };
    }

    function getHexPoints(centerX: number, centerY: number): string {
        const points = [];
        for (let i = 0; i < 6; i++) {
            const angle = ((2 * Math.PI) / 6) * i;
            const x = centerX + hexSize * Math.cos(angle);
            const y = centerY + hexSize * Math.sin(angle);
            points.push(`${x},${y}`);
        }
        return points.join(" ");
    }

    onMount(() => {
        const bbox = svg.getBBox();
        svg.setAttribute(
            "viewBox",
            `${bbox.x - hexSize} ${bbox.y - hexSize} ${bbox.width + 2 * hexSize} ${bbox.height + 2 * hexSize}`,
        );
    });

    function handleClick(coord: AxialCoord) {
        onClick(coord);
    }
</script>

<div class="w-full h-full overflow-auto">
    <svg bind:this={svg} class="w-full h-full">
        {#each gridData as tile, i}
            {@const { x, y } = hexToPixel(tile.coord)}
            <g
                transform={`translate(${x}, ${y})`}
                on:click={() => handleClick(tile.coord)}
                on:keypress={() => handleClick(tile.coord)}
                role="button"
                tabindex={i}
                class="cursor-pointer hover:opacity-80 transition-opacity"
            >
                <polygon points={getHexPoints(0, 0)} class="stroke-gray-400" />
                <text
                    x="0"
                    y="0"
                    text-anchor="middle"
                    dominant-baseline="middle"
                    class="text-xs fill-gray-700"
                >
                    {tile.value}
                </text>
            </g>
        {/each}
    </svg>
</div>
