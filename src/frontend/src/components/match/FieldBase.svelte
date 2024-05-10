<script lang="ts">
  import { PlayerStateWithId as PlayerState } from "../../ic-agent/declarations/stadium";
  import { getFontSize } from "../../utils/FieldUtil";
  import { toRgbString } from "../../utils/StringUtil";
  import UniqueAvatar from "../common/UniqueAvatar.svelte";

  export let x: number;
  export let y: number;
  export let player: PlayerState | undefined;
  export let teamColor: [number, number, number];
  let width = 10;

  let color = toRgbString(teamColor);
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
        borderStroke={color}
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
