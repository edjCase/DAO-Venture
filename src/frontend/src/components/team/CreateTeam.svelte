<script lang="ts">
  import { teamStore } from "../../stores/TeamStore";
  import { leagueAgentFactory } from "../../ic-agent/League";
  import { Button } from "flowbite-svelte";

  let name: string;
  let logoUrl: string;
  let tokenName: string;
  let tokenSymbol: string;
  let motto: string;
  let description: string;
  let createTeam = function () {
    leagueAgentFactory()
      .createTeam({ name, logoUrl, tokenName, tokenSymbol, motto, description })
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
  <input type="text" bind:value={logoUrl} />
</div>
<div>
  <label for="token-name">Token Name</label>
  <input type="text" bind:value={tokenName} />
</div>
<div>
  <label for="token-symbol">Token Symbol</label>
  <input type="text" bind:value={tokenSymbol} />
</div>
<div>
  <label for="motto">Motto</label>
  <input type="text" bind:value={motto} />
</div>
<div>
  <label for="description">Description</label>
  <input type="text" bind:value={description} />
</div>
<Button on:click={createTeam}>Create Team</Button>
