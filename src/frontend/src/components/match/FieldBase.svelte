<script lang="ts">
  import { PlayerState } from "../../ic-agent/Stadium";
  import { BaseEnum } from "../../models/Base";
  import UniqueAvatar from "../common/UniqueAvatar.svelte";

  export let x: number;
  export let y: number;
  export let player: PlayerState | undefined;
  export let base: BaseEnum;
  let width = 10;
</script>

<svg {x} {y}>
  {#if player}
    <UniqueAvatar id={player.id} size={width} />
    <text x={5} y={13} font-size={3} text-anchor="middle">#{player.id}</text>
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
