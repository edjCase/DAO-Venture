<script lang="ts">
  import { PlayerState } from "../../ic-agent/Stadium";
  import { BaseEnum } from "../../models/Base";
  import { getFontSize } from "../../utils/FieldUtil";
  import UniqueAvatar from "../common/UniqueAvatar.svelte";

  export let x: number;
  export let y: number;
  export let player: PlayerState | undefined;
  export let teamColor: string;
  export let base: BaseEnum;
  let width = 10;
</script>

<svg {x} {y}>
  {#if player}
    <text
      x={5.5}
      y={3}
      font-size={getFontSize(player.name)}
      text-anchor="middle"
    >
      {player.name}
    </text>
    <g transform="translate(.5, 5)">
      <UniqueAvatar
        id={player.id}
        size={width}
        borderStroke={teamColor}
        condition={player.condition}
      />
    </g>
  {/if}
  <rect
    x={0.5}
    y={5}
    {width}
    height={width}
    fill="none"
    stroke="white"
    stroke-width="1"
    rx="1"
    ry="1"
    opacity="0.5"
  />
</svg>

<style>
  text {
    fill: var(--color-text);
  }
</style>
