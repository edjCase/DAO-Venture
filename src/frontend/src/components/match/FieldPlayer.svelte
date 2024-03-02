<script lang="ts">
  import { PlayerState } from "../../ic-agent/declarations/stadium";
  import { FieldPositionEnum } from "../../models/FieldPosition";
  import { getFontSize } from "../../utils/FieldUtil";
  import UniqueAvatar from "../common/UniqueAvatar.svelte";

  export let player: PlayerState;
  export let position: FieldPositionEnum;
  export let teamColor: string;
  export let x: number;
  export let y: number;
  let width = 10;
</script>

<svg {x} {y}>
  <UniqueAvatar
    id={player.id}
    size={width}
    borderStroke={teamColor}
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
