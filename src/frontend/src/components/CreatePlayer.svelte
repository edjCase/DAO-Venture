<script lang="ts">
  import { playerLedgerAgent } from "../ic-agent/PlayerLedger";
  import { Principal } from "@dfinity/principal";
  import { playerStore } from "../stores/PlayerStore";
  import { teamStore } from "../stores/TeamStore";

  $: teams = $teamStore;

  let name: string;
  let teamId: string;
  let createTeam = function () {
    playerLedgerAgent
      .create({
        name: name,
        teamId: teamId ? [Principal.from(teamId)] : [],
      })
      .then((result) => {
        console.log("Created player: ", result);
        playerStore.refetch();
      })
      .catch((err) => {
        console.log("Failed to create player: " + err);
      });
  };
</script>

<div>
  <label for="name">Name</label>
  <input type="text" id="name" bind:value={name} />
</div>
<div>
  <label for="team">Team</label>
  <select id="team" bind:value={teamId}>
    {#each teams as team (team.id)}
      <option value={team.id}>{team.name}</option>
    {/each}
  </select>
</div>
<button on:click={createTeam}>Create Player</button>
