<script lang="ts">
  import { Principal } from "@dfinity/principal";
  import { playerLedgerAgentFactory } from "../ic-agent/PlayerLedger";
  import { playerStore } from "../stores/PlayerStore";
  import { teamStore } from "../stores/TeamStore";
  import { Button } from "flowbite-svelte";

  let teamId: string;
  let playerId: number;

  $: teams = $teamStore;
  $: players = $playerStore;

  let assign = function () {
    playerLedgerAgentFactory()
      .setPlayerTeam(playerId, teamId ? [Principal.from(teamId)] : [])
      .then((result) => {
        console.log("Assigned player to team: ", result);
        playerStore.refetch();
      })
      .catch((err) => {
        console.log("Failed to assign player to team: ", err);
      });
  };
</script>

<div>
  <label for="team">Team</label>
  <select id="team" bind:value={teamId}>
    <option value="">None</option>
    {#each teams as team (team.id)}
      <option value={team.id}>{team.name}</option>
    {/each}
  </select>
</div>
<div>
  <label for="player">Player</label>
  <select id="player" bind:value={playerId}>
    {#each players as player (player.id)}
      <option value={player.id}>{player.name}</option>
    {/each}
  </select>
</div>
<div>
  <Button on:click={assign}>Assign</Button>
</div>
