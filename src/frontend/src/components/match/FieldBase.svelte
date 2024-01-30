<script lang="ts">
  import { toSvg } from "jdenticon";
  import { PlayerState } from "../../ic-agent/Stadium";
  import { BaseEnum } from "../../models/Base";

  export let x: number;
  export let y: number;
  export let player: PlayerState | undefined;
  export let base: BaseEnum;
  let width = 10;
</script>

<svg {x} {y}>
  {#if player}
    {@html toSvg(player.id.toString(), width)}
    <text x={2} y={15} font-size={3}>#{player.id}</text>
  {/if}
  <rect
    x={0.05}
    y={0.05}
    {width}
    height={width}
    fill="none"
    stroke="white"
    stroke-width=".1"
  />
</svg>

<style>
  text {
    fill: var(--color-text);
  }
</style>
