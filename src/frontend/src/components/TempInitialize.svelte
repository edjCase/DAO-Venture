<script lang="ts">
  import { CreatePlayerFluffResult } from "../ic-agent/declarations/players";
  import { teamStore } from "../stores/TeamStore";
  import { playerStore } from "../stores/PlayerStore";
  import { teams as teamData } from "../data/TeamData";
  import { players as playerData } from "../data/PlayerData";
  import { toJsonString } from "../utils/StringUtil";
  import { leagueAgentFactory } from "../ic-agent/League";
  import { playersAgentFactory } from "../ic-agent/Players";
  import LoadingButton from "./common/LoadingButton.svelte";

  $: teams = $teamStore;
  $: players = $playerStore;

  let intializing = false;

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
        .addluff({
          name: player.name,
          title: player.title,
          description: player.description,
          likes: player.likes,
          dislikes: player.dislikes,
          quirks: player.quirks,
        })
        .then((result: CreatePlayerFluffResult) => {
          if ("ok" in result) {
            console.log("Added player fluff: ", player.name);
          } else {
            console.log(
              "Failed to add player fluff: ",
              player.name,
              result.invalid,
            );
          }
        });
      promises.push(promise);
    }
    await Promise.all(promises);
  };

  let initialize = async function () {
    intializing = true;
    await createPlayers();
    await createTeams();
    intializing = false;
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
</script>

{#if !teams || !players || players.length + teams.length <= 0}
  <LoadingButton onClick={initialize}>
    Initialize With Default Data
  </LoadingButton>
{:else}
  <div class="flex">
    <div class="flex-1 w-1/2">
      {#if teams.length <= 0}
        <LoadingButton onClick={createTeams}>Create Teams</LoadingButton>
      {:else}
        <LoadingButton onClick={resetTeamsAndPlayers}>
          Reset Teams
        </LoadingButton>
        <div>Teams:</div>
        {#each teams as team}
          <pre class="text-wrap">{toJsonString(team)}</pre>
        {/each}
      {/if}
    </div>
    <div class="flex-1 w-1/2">
      {#if players.length <= 0}
        <LoadingButton onClick={createPlayers}>Create Players</LoadingButton>
      {:else}
        <LoadingButton onClick={resetTeamsAndPlayers}>
          Reset Players
        </LoadingButton>
        <div>Players:</div>
        {#each players as player}
          <pre class="text-wrap">{toJsonString(player)}</pre>
        {/each}
      {/if}
    </div>
  </div>
{/if}
