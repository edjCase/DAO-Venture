<script lang="ts">
  import { PlayerStateWithId } from "../../ic-agent/declarations/stadium";
  import { getFontSize } from "../../utils/FieldUtil";
  import { toRgbString } from "../../utils/StringUtil";
  import UniqueAvatar from "../common/UniqueAvatar.svelte";

  export let player: PlayerStateWithId;
  export let teamColor: [number, number, number];
  export let x: number;
  export let y: number;
  let width = 10;
  let color = toRgbString(teamColor);
</script>

<svg {x} {y}>
  <UniqueAvatar
    id={player.id}
    size={width}
    borderStroke={color}
    condition={player.condition}
  />
  <text x={5} y={13} font-size={getFontSize(player.name)} text-anchor="middle">
    {player.name}
  </text>
</svg>

<style>
  text {
    fill: var(--color-text);
  }
</style>
