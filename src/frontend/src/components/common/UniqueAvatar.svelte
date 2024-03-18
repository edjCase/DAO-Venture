<script lang="ts">
  import { toSvg } from "jdenticon";
  import { PlayerCondition } from "../../ic-agent/declarations/stadium";

  export let id: any;
  export let size: number;
  export let condition: PlayerCondition | undefined;
  export let borderStroke: string | undefined;
</script>

<svg width={size} height={size} viewBox="0 0 {size} {size}">
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

  {#if condition}
    {#if "injured" in condition}
      <path
        d="M5 2v3m0 2v1"
        stroke="red"
        stroke-width="2"
        stroke-opacity="0.8"
        stroke-linecap="round"
        fill="none"
      />
    {:else if "dead" in condition}
      <path
        d="M1 1l8 8m0-8L1 9"
        stroke="red"
        stroke-width="2"
        stroke-opacity="0.8"
        stroke-linecap="round"
        fill="none"
      />
    {/if}
  {/if}
</svg>
