<script lang="ts">
  import type { Player } from "../models/Player";

  export let players: Player[];
  export let initialPlayerId: number | undefined;

  let playerId: number = initialPlayerId;
</script>

<select id="player" bind:value={playerId}>
  {#each players as player (player.id)}
    <option value={player.id}>{player.name}</option>
  {/each}
</select>
