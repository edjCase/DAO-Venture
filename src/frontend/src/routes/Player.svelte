<script lang="ts">
  import PlayerProfile from "../components/player/PlayerProfile.svelte";
  import { PlayerWithId } from "../ic-agent/declarations/league";
  import { playerStore } from "../stores/PlayerStore";

  export let playerIdString: string;

  let player: PlayerWithId | undefined;
  playerStore.subscribe((players) => {
    player = players?.find((p) => p.id.toString() === playerIdString);
  });
</script>

{#if player}
  <PlayerProfile {player} />
{/if}
