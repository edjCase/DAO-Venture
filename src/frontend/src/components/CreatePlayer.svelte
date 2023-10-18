<script lang="ts">
  import {
    playerLedgerAgentFactory,
    mapPosition,
  } from "../ic-agent/PlayerLedger";
  import { Principal } from "@dfinity/principal";
  import { playerStore } from "../stores/PlayerStore";
  import { teamStore } from "../stores/TeamStore";
  import PositionPicker from "./PositionPicker.svelte";
  import { FieldPosition } from "../models/FieldPosition";

  $: teams = $teamStore;

  let name: string;
  let teamId: string;
  let position: FieldPosition;
  let createTeam = function () {
    let mappedPosition = mapPosition(position);
    playerLedgerAgentFactory()
      .create({
        name: name,
        teamId: [Principal.from(teamId)],
        position: mappedPosition,
      })
      .then((result) => {
        console.log("Created player: ", result);
        playerStore.refetch();
      })
      .catch((err) => {
        console.log("Failed to create player: " + err);
      });
  };
  let create2OfEach = async () => {
    let j = 0;
    for (let _ in [1, 2]) {
      let i = 1;
      for (let positionKey in FieldPosition) {
        if (!isNaN(Number(positionKey))) {
          continue;
        }
        let position = FieldPosition[positionKey];
        let mappedPosition = mapPosition(position);
        let teamName = teams.find((team) => team.id.toString() == teamId).name;
        if (teamName.endsWith("s")) {
          teamName = teamName.slice(0, -1);
        }
        let name = teamName + " " + (i + j * 8);
        i++;
        playerLedgerAgentFactory()
          .create({
            name: name,
            teamId: [Principal.from(teamId)],
            position: mappedPosition,
          })
          .then((result) => {
            console.log("Created player: ", result);
            playerStore.refetch();
          })
          .catch((err) => {
            console.log("Failed to create player: " + err);
          });
      }
      j++;
    }
  };
</script>

<div>
  <select id="team" bind:value={teamId}>
    {#each teams as team (team.id)}
      <option value={team.id}>{team.name}</option>
    {/each}
  </select>
  <button on:click={create2OfEach}>Create 2 of each position</button>
</div>

OR

<div>
  <label for="name">Name</label>
  <input type="text" id="name" bind:value={name} />
</div>
<div>
  <label for="team">Team</label>
  <select id="team" bind:value={teamId}>
    {#each teams as team (team.id)}
      <option value={team.id}>{team.name}</option>
    {/each}
  </select>
</div>
<div>
  <label for="position">Position</label>
  <PositionPicker
    takenPositions={[]}
    onPositionChange={(p) => {
      position = p;
    }}
  />
</div>
<button on:click={createTeam}>Create Player</button>
