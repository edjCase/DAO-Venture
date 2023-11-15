<script lang="ts">
  import { teamStore } from "../stores/TeamStore";
  import { leagueAgentFactory } from "../ic-agent/League";

  let name: string;
  let logoUrl: string;
  let tokenName: string;
  let tokenSymbol: string;
  let createTeam = function () {
    leagueAgentFactory()
      .createTeam({ name, logoUrl, tokenName, tokenSymbol })
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

<button class="button-style" on:click={createTeam}>Create Team</button>
