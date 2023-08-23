<script lang="ts">
  import { teamStore } from "../stores/TeamStore";
  import { agent as leagueAgent } from "../ic-agent/League";

  let name: string;
  let logoUrl: string;
  let createTeam = function () {
    leagueAgent
      .createTeam(name, logoUrl)
      .then(() => {
        teamStore.refetch();
      })
      .catch((err) => {
        window.alert("Failed to make team: " + err);
      });
  };
</script>

<div>
  <label for="team-name">Name</label>
  <input type="text" id="team-name" bind:value={name} />
</div>
<div>
  <label for="logo">Logo Url</label>
  <input type="text" id="logo" bind:value={logoUrl} />
</div>
<button on:click={createTeam}>Create Team</button>
