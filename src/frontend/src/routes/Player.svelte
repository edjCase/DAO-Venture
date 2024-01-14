<script lang="ts">
  import PlayerProfile from "../components/PlayerProfile.svelte";
  import { Player } from "../ic-agent/PlayerLedger";
  import { playerStore } from "../stores/PlayerStore";

  export let playerIdString: string;

  let player: Player | undefined;
  playerStore.subscribe((players) => {
    player = players.find((p) => p.id.toString() === playerIdString);
  });
</script>

{#if player}
  <PlayerProfile {player} />
{/if}
