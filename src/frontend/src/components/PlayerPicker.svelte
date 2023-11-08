<script lang="ts">
  import { onMount } from "svelte";
  import type { Player } from "../models/Player";

  export let players: Player[];
  export let onPlayerSelected: (playerId: number) => void;

  onMount(() => {
    onPlayerSelected(players[0].id);
  });
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
