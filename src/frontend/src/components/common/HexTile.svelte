<script lang="ts" context="module">
    export interface AxialCoordinate {
        q: number; // top left -> bottom right
        r: number; // bottom -> top
    }
    export type HexTileKind =
        | { unexplored: null }
        | {
              explored: {
                  towns: { id: bigint; color: [number, number, number] }[];
              };
          };
</script>

<script lang="ts">
    import { onMount } from "svelte";

    import { toRgbString } from "../../utils/StringUtil";

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
    let fill = "";
    let setFillColor = (kind: HexTileKind) => {
        fill = "black";
        if ("explored" in kind) {
            if (kind.explored.towns.length === 1) {
                fill = `rgb(${kind.explored.towns[0].color.join(",")})`;
            } else if (kind.explored.towns.length > 1) {
                // Create a stripe patten of all the colors
                const colors = kind.explored.towns.map((town) =>
                    toRgbString(town.color),
                );
                fill = createStripePatternUrl(colors);
            }
        }
    };

    $: setFillColor(kind);

    onMount(() => setFillColor(kind));

    function createStripePatternUrl(colors: string[]): string {
        const g = document.getElementById("hex-" + id);
        if (!g) {
            return "";
        }
        const defs = document.createElementNS(
            "http://www.w3.org/2000/svg",
            "defs",
        );
        const pattern = document.createElementNS(
            "http://www.w3.org/2000/svg",
            "pattern",
        );

        const patternId = "tile-pattern-" + id;
        const stripeWidth = 10; // Adjust for thicker/thinner stripes
        const patternSize = colors.length * stripeWidth;

        pattern.setAttribute("id", patternId);
        pattern.setAttribute("patternUnits", "userSpaceOnUse");
        pattern.setAttribute("width", patternSize.toString());
        pattern.setAttribute("height", patternSize.toString());
        pattern.setAttribute("patternTransform", "rotate(60)"); // Adjusted rotation angle

        colors.forEach((color: string, index: number) => {
            const rect = document.createElementNS(
                "http://www.w3.org/2000/svg",
                "rect",
            );
            rect.setAttribute("x", (index * stripeWidth).toString());
            rect.setAttribute("y", "0");
            rect.setAttribute("width", stripeWidth.toString());
            rect.setAttribute("height", patternSize.toString());
            rect.setAttribute("fill", color);
            pattern.appendChild(rect);
        });

        defs.appendChild(pattern);
        g?.appendChild(defs);

        return `url(#${patternId})`;
    }
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
        {fill}
        fill-opacity={fillOpacity}
    />
    <slot {id} />
</g>
