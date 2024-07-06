<script lang="ts">
  import { LivePlayerState } from "../../ic-agent/declarations/main";
  import { getFontSize } from "../../utils/FieldUtil";
  import { toRgbString } from "../../utils/StringUtil";
  import UniqueAvatar from "../common/UniqueAvatar.svelte";

  export let player: LivePlayerState;
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
