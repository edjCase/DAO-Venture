<script lang="ts">
  import { toSvg } from "jdenticon";

  export let id: any;
  export let size: number;
  export let borderStroke: string | undefined;
</script>

<svg>
  <rect
    rx="2"
    ry="2"
    x={0.5}
    y={0.5}
    width={size - 1}
    height={size - 1}
    fill="none"
    stroke={borderStroke || "none"}
    stroke-width=".5"
    stroke-opacity="0.7"
  />
  {@html toSvg(id, size)}
</svg>
