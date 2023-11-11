<script lang="ts">
  import { divisionStore } from "../stores/DivisionStore";
  import { leagueAgentFactory } from "../ic-agent/League";

  let name: string;
  let createDivision = function () {
    leagueAgentFactory()
      .createDivision({ name })
      .then(() => {
        divisionStore.refetch();
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
<button class="button-style" on:click={createDivision}>Create Division</button>
