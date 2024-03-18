<script lang="ts">
  import { CreatePlayerFluffResult } from "../ic-agent/declarations/players";
  import { teamStore } from "../stores/TeamStore";
  import { playerStore } from "../stores/PlayerStore";
  import { teams as teamData } from "../data/TeamData";
  import { players as playerData } from "../data/PlayerData";
  import { scenarios as scenarioData } from "../data/ScenarioData";
  import { Button } from "flowbite-svelte";
  import { toJsonString } from "../utils/StringUtil";
  import { leagueAgentFactory } from "../ic-agent/League";
  import { playersAgentFactory } from "../ic-agent/Players";
  import { AddScenarioRequest } from "../ic-agent/declarations/league";

  $: teams = $teamStore;
  $: players = $playerStore;

  let createTeams = async function (): Promise<void> {
    let leagueAgent = await leagueAgentFactory();
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
    let playersAgent = await playersAgentFactory();
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
    let leagueAgent = await leagueAgentFactory();
    let promises = [];
    let startTime = new Date().getTime() * 1000000;
    for (let i = 0; i < scenarioData.length; i++) {
      let scenario = scenarioData[i];
      let addScenarioRequest: AddScenarioRequest = {
        ...scenario,
        teamIds: teams.map((team) => team.id),
        startTime: BigInt(startTime),
        endTime: BigInt(startTime + 1000 * 60 * 60 * 24 * 7), // 1 week
      };
      let promise = leagueAgent
        .addScenario(addScenarioRequest)
        .then(async (result) => {
          if ("ok" in result) {
            console.log("Created scenario: ", scenario.id);
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
    let leagueAgent = await leagueAgentFactory();
    await leagueAgent.clearTeams();
    await createTeams();
  };
  let resetPlayers = async function () {
    console.log("resetting players");
    let playersAgent = await playersAgentFactory();
    await playersAgent.clearPlayers();
    await createPlayers();
  };
  let resetTeamsAndPlayers = async function () {
    await resetPlayers();
    await resetTeams();
  };
  // let resetScenarios = async function () {
  //   console.log("resetting scenarios");
  //   let leagueAgent = await leagueAgentFactory();
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
