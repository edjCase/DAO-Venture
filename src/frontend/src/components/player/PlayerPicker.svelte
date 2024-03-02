<script lang="ts">
  import { onMount } from "svelte";
  import { PlayerWithId } from "../../ic-agent/declarations/players";

  export let players: PlayerWithId[];
  export let onPlayerSelected: (playerId: number) => void;

  onMount(() => {
    if (players.length > 0) {
      onPlayerSelected(players[0].id);
    }
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
