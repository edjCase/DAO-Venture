<script lang="ts">
  import { Button } from "flowbite-svelte";
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

<Button on:click={updateLeagueCanisters}>Update League Canisters</Button>
