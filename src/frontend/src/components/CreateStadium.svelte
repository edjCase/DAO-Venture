<script lang="ts">
  import { teamStore } from "../stores/TeamStore";
  import { leagueAgentFactory } from "../ic-agent/League";

  let createTeam = function () {
    leagueAgentFactory()
      .createStadium()
      .then(() => {
        teamStore.refetch();
      })
      .catch((err) => {
        console.log("Failed to make stadium: " + err);
      });
  };
</script>

<button on:click={createTeam}>Create Stadium</button>
