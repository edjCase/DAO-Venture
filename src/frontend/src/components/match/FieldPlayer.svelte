<script lang="ts">
  import { toSvg } from "jdenticon";
  import { PlayerState } from "../../ic-agent/Stadium";
  import { FieldPositionEnum } from "../../models/FieldPosition";

  export let player: PlayerState;
  export let position: FieldPositionEnum;
  export let x: number;
  export let y: number;
  let width = 10;
</script>

<svg {x} {y}>
  <rect x={0} y={0} {width} height={width} fill="none" stroke="none" />
  {@html toSvg(player.id.toString(), width)}
  <text x={2} y={15} font-size={3}>#{player.id}</text>
</svg>

<style>
  text {
    fill: var(--color-text);
  }
</style>
