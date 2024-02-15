<script lang="ts">
  import { leagueAgentFactory } from "../ic-agent/League";
  import {
    CreatePlayerFluffResult,
    playersAgentFactory,
  } from "../ic-agent/Players";
  import { teamStore } from "../stores/TeamStore";
  import { playerStore } from "../stores/PlayerStore";
  import { Team, teams } from "../data/TeamData";
  import { Player, players } from "../data/PlayerData";
  import { Button } from "flowbite-svelte";
  import { scenarios } from "../data/ScenarioData";

  let createTeams = async function (teams: Team[]): Promise<void> {
    let leagueAgent = leagueAgentFactory();
    let promises = [];
    for (let i = 0; i < teams.length; i++) {
      let team = teams[i];
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
    teamStore.refetch();
  };

  let createPlayers = async function (players: Player[]) {
    let playersAgent = playersAgentFactory();
    let promises = [];
    // loop over count
    for (let player of players) {
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
    for (let i = 0; i < scenarios.length; i++) {
      let promise = leagueAgent.addScenarioTemplate(scenarios[i]);
      promises.push(promise);
    }
    await Promise.all(promises);
  };

  let initialize = async function () {
    await createPlayers(players);
    await createTeams(teams);
    await createScenarios();
    playerStore.refetch();
  };
</script>

<Button on:click={initialize}>Initialize With Default Data</Button>
