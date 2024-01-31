<script lang="ts">
  import { PlayerState } from "../../ic-agent/Stadium";
  import { FieldPositionEnum } from "../../models/FieldPosition";
  import UniqueAvatar from "../common/UniqueAvatar.svelte";

  export let player: PlayerState;
  export let position: FieldPositionEnum;
  export let x: number;
  export let y: number;
  let width = 10;
</script>

<svg {x} {y}>
  <rect x={0} y={0} {width} height={width} fill="none" stroke="none" />
  <UniqueAvatar id={player.id} size={width} />
  <text x={5} y={13} font-size={3} text-anchor="middle">#{player.id}</text>
</svg>

<style>
  text {
    fill: var(--color-text);
  }
</style>
