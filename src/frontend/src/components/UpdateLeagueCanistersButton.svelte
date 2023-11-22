<script lang="ts">
  import { leagueAgentFactory } from "../ic-agent/League";

  let updateLeagueCanisters = () => {
    console.log("Updating league canisters...");
    leagueAgentFactory()
      .updateLeagueCanisters()
      .then((result) => {
        console.log("Updated league canisters: ", result);
      })
      .catch((err) => {
        console.log("Failed to update league canisters: ", err);
      });
  };
</script>

<button on:click={updateLeagueCanisters} class="button-style">
  Update League Canisters
</button>
