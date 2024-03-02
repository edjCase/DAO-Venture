<script lang="ts">
  import { CreatePlayerFluffResult } from "../ic-agent/declarations/players";
  import { teamStore } from "../stores/TeamStore";
  import { playerStore } from "../stores/PlayerStore";
  import { teams as teamData } from "../data/TeamData";
  import { players as playerData } from "../data/PlayerData";
  import { traits as traitData } from "../data/TraitData";
  import { Button } from "flowbite-svelte";
  import { scenarios as scenarioData } from "../data/ScenarioData";
  import { traitStore } from "../stores/TraitStore";
  import { toJsonString } from "../utils/JsonUtil";
  import { leagueAgentFactory } from "../ic-agent/League";
  import { scenarioStore } from "../stores/ScenarioStore";

  $: teams = $teamStore;
  $: players = $playerStore;
  $: scenarios = $scenarioStore;
  $: traits = $traitStore;

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

  let createTraits = async function () {
    let playersAgent = playersAgentFactory();
    let promises = [];
    for (let i = 0; i < traitData.length; i++) {
      let trait = traitData[i];
      let promise = playersAgent.addTrait(trait).then((result) => {
        if ("ok" in result) {
          console.log("Created trait: ", trait.id);
        } else {
          console.log("Failed to make trait: ", trait.id, result);
        }
      });
      promises.push(promise);
    }
    await Promise.all(promises);
    console.log("Created traits");
    await traitStore.refetch();
  };

  let createScenarios = async function () {
    let leagueAgent = leagueAgentFactory();
    let promises = [];
    for (let i = 0; i < scenarioData.length; i++) {
      let scenario = scenarioData[i];
      let promise = leagueAgent.addScenarioTemplate(scenario).then((result) => {
        if ("ok" in result) {
          console.log("Created scenario: ", scenario.id);
        } else {
          console.log("Failed to make scenario: ", scenario.id, result);
        }
      });
      promises.push(promise);
    }
    await Promise.all(promises);
    console.log("Created scenarios");
    await scenarioTemplateStore.refetch();
  };

  let initialize = async function () {
    await createPlayers();
    await createTeams();
    await createTraits();
    await createScenarios();
  };
  let resetTraits = async function () {
    console.log("resetting traits");
    let playersAgent = playersAgentFactory();
    await playersAgent.clearTraits();
    await createTraits();
  };
  let resetScenarios = async function () {
    console.log("resetting scenarios");
    let leagueAgent = leagueAgentFactory();
    await leagueAgent.clearScenarioTemplates();
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
  let resetTraitsAndScenarios = async function () {
    await resetTraits();
    await resetScenarios();
  };
  let resetTeamsAndPlayers = async function () {
    await resetPlayers();
    await resetTeams();
  };
</script>

{#if players.length + teams.length + scenarioTemplates.length + traits.length <= 0}
  <Button on:click={initialize}>Initialize With Default Data</Button>
{:else}
  <div class="flex">
    <div class="flex-1 w-1/4">
      {#if traits.length <= 0}
        <Button on:click={createTraits}>Create Traits</Button>
      {:else}
        <Button on:click={resetTraitsAndScenarios}>Reset Traits</Button>
        <div>Traits:</div>
        {#each traits as trait}
          <pre class="text-wrap">{toJsonString(trait)}</pre>
        {/each}
      {/if}
    </div>
    <div class="flex-1 w-1/4">
      {#if scenarioTemplates.length <= 0}
        <Button on:click={createScenarios}>Create Scenarios</Button>
      {:else}
        <Button on:click={resetTraitsAndScenarios}>Reset Scenarios</Button>
        <div>Scenarios:</div>
        {#each scenarioTemplates as scenario}
          <pre class="text-wrap">{toJsonString(scenario)}</pre>
        {/each}
      {/if}
    </div>
    <div class="flex-1 w-1/4">
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
    <div class="flex-1 w-1/4">
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
