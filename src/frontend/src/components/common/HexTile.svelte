<script lang="ts" context="module">
    export interface AxialCoordinate {
        q: number; // left -> right
        r: number; // top-left -> bottom-right
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

    const scaleFactor = 1; // This will make the hexes half their original size

    function hexToPixel(hex: AxialCoordinate): { x: number; y: number } {
        const x =
            hexSize *
            scaleFactor *
            (Math.sqrt(3) * hex.q + (Math.sqrt(3) / 2) * hex.r);
        const y = hexSize * scaleFactor * ((3 / 2) * hex.r);

        return { x, y };
    }

    function getHexPoints(centerX: number, centerY: number): string {
        const points = [];
        for (let i = 0; i < 6; i++) {
            const angle = (Math.PI / 3) * i + Math.PI / 6; // Add PI/6 to rotate 30 degrees
            const x = centerX + hexSize * scaleFactor * Math.cos(angle);
            const y = centerY + hexSize * scaleFactor * Math.sin(angle);
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
    class="cursor-pointer transition-opacity focus:outline-none {selected
        ? ''
        : 'hover:opacity-80'}"
>
    <polygon
        points={getHexPoints(0, 0)}
        stroke-width={1}
        stroke-dasharray={selected ? 3 : undefined}
        stroke="rgb(156, 163, 175)"
        fill="black"
        fill-opacity={fillOpacity}
    />
    <slot {id} />
</g>
