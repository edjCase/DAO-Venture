<script lang="ts">
  import type { Player } from "../models/Player";

  export let players: Player[];
  export let onPlayerSelected: (playerId: number) => void;
</script>

<select
  id="player"
  on:change={(e) => {
    onPlayerSelected(Number(e.currentTarget.value));
  }}
>
  {#each players as player (player.id)}
    <option value={player.id}>{player.name}</option>
  {/each}
</select>
