<script lang="ts">
  import { CreatePlayerFluffResult } from "../ic-agent/declarations/players";
  import { teamStore } from "../stores/TeamStore";
  import { playerStore } from "../stores/PlayerStore";
  import { teams as teamData } from "../data/TeamData";
  import { players as playerData } from "../data/PlayerData";
  import { scenarios as scenarioData } from "../data/ScenarioData";
  import { Button } from "flowbite-svelte";
  import { toJsonString } from "../utils/JsonUtil";
  import { leagueAgentFactory } from "../ic-agent/League";
  import { playersAgentFactory } from "../ic-agent/Players";

  $: teams = $teamStore;
  $: players = $playerStore;

  let createTeams = async function (): Promise<void> {
    let leagueAgent = leagueAgentFactory();
    let promises = [];
    for (let i = 0; i < teamData.length; i++) {
      let team = teamData[i];
      let promise = leagueAgent.createTeam(team).then(async (result) => {
        if ("ok" in result) {
          let teamId = result.ok;
          console.log("Created team: ", teamId);
        } else {
          console.log("Failed to make team: ", result);
        }
      });
      promises.push(promise);
    }
    await Promise.all(promises);
    await teamStore.refetch();
    await playerStore.refetch();
  };

  let createPlayers = async function () {
    let playersAgent = playersAgentFactory();
    let promises = [];
    // loop over count
    for (let player of playerData) {
      let promise = playersAgent
        .createFluff({
          name: player.name,
          title: player.title,
          description: player.description,
          likes: player.likes,
          dislikes: player.dislikes,
          quirks: player.quirks,
        })
        .then((result: CreatePlayerFluffResult) => {
          if ("created" in result) {
            console.log("Created player: ", player.name);
          } else {
            console.log("Failed to make player: ", player.name, result.invalid);
          }
        });
      promises.push(promise);
    }
    await Promise.all(promises);
  };

  let createScenarios = async function () {
    let leagueAgent = leagueAgentFactory();
    let promises = [];
    for (let i = 0; i < scenarioData.length; i++) {
      let scenario = scenarioData[i];
      let promise = leagueAgent.addScenario(scenario).then(async (result) => {
        if ("ok" in result) {
          let scenarioId = result.ok;
          console.log("Created scenario: ", scenarioId);
        } else {
          console.log("Failed to make scenario: ", result);
        }
      });
      promises.push(promise);
    }
    await Promise.all(promises);
  };

  let initialize = async function () {
    await createPlayers();
    await createTeams();
    await createScenarios();
  };
  let resetTeams = async function () {
    console.log("resetting teams");
    let leagueAgent = leagueAgentFactory();
    await leagueAgent.clearTeams();
    await createTeams();
  };
  let resetPlayers = async function () {
    console.log("resetting players");
    let playersAgent = playersAgentFactory();
    await playersAgent.clearPlayers();
    await createPlayers();
  };
  let resetTeamsAndPlayers = async function () {
    await resetPlayers();
    await resetTeams();
  };
  // let resetScenarios = async function () {
  //   console.log("resetting scenarios");
  //   let leagueAgent = leagueAgentFactory();
  //   await leagueAgent.clearScenarios();
  //   await createScenarios();
  // };
</script>

{#if players.length + teams.length <= 0}
  <Button on:click={initialize}>Initialize With Default Data</Button>
{:else}
  <div class="flex">
    <div class="flex-1 w-1/3">
      <Button on:click={createScenarios}>Create Scenarios</Button>
    </div>
    <div class="flex-1 w-1/3">
      {#if teams.length <= 0}
        <Button on:click={createTeams}>Create Teams</Button>
      {:else}
        <Button on:click={resetTeamsAndPlayers}>Reset Teams</Button>
        <div>Teams:</div>
        {#each teams as team}
          <pre class="text-wrap">{toJsonString(team)}</pre>
        {/each}
      {/if}
    </div>
    <div class="flex-1 w-1/3">
      {#if players.length <= 0}
        <Button on:click={createPlayers}>Create Players</Button>
      {:else}
        <Button on:click={resetTeamsAndPlayers}>Reset Players</Button>
        <div>Players:</div>
        {#each players as player}
          <pre class="text-wrap">{toJsonString(player)}</pre>
        {/each}
      {/if}
    </div>
  </div>
{/if}
