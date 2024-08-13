<script lang="ts" context="module">
    export interface AxialCoordinate {
        q: number; // top left -> bottom right
        r: number; // bottom -> top
    }
    export type HexTileKind =
        | { unexplored: null }
        | {
              explored: {
                  icon: string;
              };
          };
</script>

<script lang="ts">
    export let kind: HexTileKind;
    export let coordinate: AxialCoordinate;
    export let id: number;
    export let hexSize: number;
    export let selected: boolean;
    export let onClick: (coord: AxialCoordinate) => void = () => {};

    const { x, y } = hexToPixel(coordinate);

    function hexToPixel(hex: AxialCoordinate): { x: number; y: number } {
        const x = hexSize * ((3 / 2) * hex.q);
        const y =
            hexSize *
            ((Math.sqrt(3) / 2) * Number(hex.q) + Math.sqrt(3) * hex.r);

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

    function handleClick(coord: AxialCoordinate) {
        onClick(coord);
    }

    $: fillOpacity = "unexplored" in kind ? 0.1 : 1;
</script>

<g
    id={"hex-" + id}
    transform={`translate(${x}, ${y})`}
    on:click={() => handleClick(coordinate)}
    on:keypress={() => handleClick(coordinate)}
    role="button"
    tabindex={id}
    class="cursor-pointer hover:opacity-80 transition-opacity focus:outline-none"
>
    <polygon
        points={getHexPoints(0, 0)}
        stroke-width={selected ? 4 : 1}
        stroke="rgb(156, 163, 175)"
        fill="black"
        fill-opacity={fillOpacity}
    />
    <slot {id} />
</g>
