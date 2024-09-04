<script lang="ts" context="module">
  export interface AxialCoordinate {
    q: number; // left -> right
    r: number; // top-left -> bottom-right
  }

  export function coordinateEquals(
    a: AxialCoordinate,
    b: AxialCoordinate
  ): boolean {
    return a.q === b.q && a.r === b.r;
  }
  const scaleFactor = 1; // This will make the hexes half their original size

  export function hexToPixel(
    hexSize: number,
    coordinate: AxialCoordinate
  ): { x: number; y: number } {
    const x =
      hexSize *
      scaleFactor *
      (Math.sqrt(3) * coordinate.q + (Math.sqrt(3) / 2) * coordinate.r);
    const y = hexSize * scaleFactor * ((3 / 2) * coordinate.r);

    return { x, y };
  }

  export function getHexPolygonPoints(
    hexSize: number,
    coordinate: AxialCoordinate | undefined
  ): string {
    const points = [];
    for (let i = 0; i < 6; i++) {
      const angle = (Math.PI / 3) * i + Math.PI / 6; // Add PI/6 to rotate 30 degrees
      let offset =
        coordinate === undefined
          ? { x: 0, y: 0 }
          : hexToPixel(hexSize, coordinate);
      const x = offset.x + hexSize * scaleFactor * Math.cos(angle);
      const y = offset.y + hexSize * scaleFactor * Math.sin(angle);
      points.push(`${x},${y}`);
    }
    return points.join(" ");
  }
</script>

<script lang="ts">
  export let coordinate: AxialCoordinate;
  export let hexSize: number;
  export let selected: boolean;
  export let onClick: (coord: AxialCoordinate) => void = () => {};

  const { x, y } = hexToPixel(hexSize, coordinate);

  function handleClick(coord: AxialCoordinate) {
    onClick(coord);
  }

  let id = coordinate.q + "-" + coordinate.r;
</script>

<g
  id={"hex-" + id}
  transform={`translate(${x}, ${y})`}
  on:click={() => handleClick(coordinate)}
  on:keypress={() => handleClick(coordinate)}
  role="button"
  tabindex={0}
  class="cursor-pointer transition-opacity focus:outline-none {selected
    ? ''
    : 'hover:opacity-80'}"
>
  <clipPath id={"hex-clip-" + id}>
    <polygon points={getHexPolygonPoints(hexSize, undefined)} />
  </clipPath>

  <polygon
    points={getHexPolygonPoints(hexSize, undefined)}
    stroke-width={selected ? 2 : 0}
    stroke="rgb(156, 163, 175)"
  />

  <g clip-path={`url(#hex-clip-${id})`}>
    <slot {id} />
  </g>
</g>
