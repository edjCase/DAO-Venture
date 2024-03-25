<script lang="ts">
  import { playerStore } from "../../stores/PlayerStore";
  import { PlayerWithId } from "../../ic-agent/declarations/players";
  import PlayerCard from "./PlayerCard.svelte";

  export let teamId: bigint;

  let players: PlayerWithId[] | undefined;
  playerStore.subscribe((playerList) => {
    players = playerList
      ?.filter((p) => p.teamId?.toString() === teamId.toString())
      .sort((a, b) => a.id - b.id);
  });
</script>

{#if players !== undefined}
  <div class="grid grid-cols-1">
    {#each players as player}
      <PlayerCard {player} />
    {/each}
  </div>
{/if}
