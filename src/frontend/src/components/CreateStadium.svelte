<script lang="ts">
  import { teamStore } from "../stores/TeamStore";
  import { leagueAgent as leagueAgent } from "../ic-agent/League";

  let name: string;
  let createTeam = function () {
    leagueAgent
      .createStadium(name)
      .then(() => {
        teamStore.refetch();
      })
      .catch((err) => {
        console.log("Failed to make stadium: " + err);
      });
  };
</script>

<div>
  <label for="team-name">Name</label>
  <input type="text" id="team-name" bind:value={name} />
</div>
<button on:click={createTeam}>Create Stadium</button>
