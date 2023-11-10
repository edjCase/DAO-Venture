<script lang="ts">
  import {
    playerLedgerAgentFactory,
    mapPosition,
    mapDeity,
  } from "../ic-agent/PlayerLedger";
  import { Principal } from "@dfinity/principal";
  import { playerStore } from "../stores/PlayerStore";
  import { teamStore } from "../stores/TeamStore";
  import PositionPicker from "./PositionPicker.svelte";
  import { FieldPosition } from "../models/FieldPosition";
  import { Deity } from "../models/Deity";

  $: teams = $teamStore;

  let name: string;
  let teamId: string;
  let position: FieldPosition;
  let deity: string;
  let battingAccuracy: number = 0;
  let battingPower: number = 0;
  let throwingAccuracy: number = 0;
  let throwingPower: number = 0;
  let catching: number = 0;
  let defense: number = 0;
  let piety: number = 0;
  let speed: number = 0;

  let createPlayer = function () {
    let mappedPosition = mapPosition(position);
    let mappedDeity = mapDeity(Deity[deity as keyof typeof Deity]);
    playerLedgerAgentFactory()
      .create({
        name: name,
        teamId: [Principal.from(teamId)],
        position: mappedPosition,
        deity: mappedDeity,
        skills: {
          battingAccuracy: battingAccuracy,
          battingPower: battingPower,
          throwingAccuracy: throwingAccuracy,
          throwingPower: throwingPower,
          catching: catching,
          defense: defense,
          piety: piety,
          speed: speed,
        },
      })
      .then((result) => {
        console.log("Created player: ", result);
        playerStore.refetch();
      })
      .catch((err) => {
        console.log("Failed to create player: " + err);
      });
  };
  let deityOptions = Object.keys(Deity).map((deity) => {
    return { value: deity, label: Deity[deity as keyof typeof Deity] };
  });
</script>

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
    onPositionChange={(p) => {
      position = p;
    }}
  />
</div>
<div>
  <label for="deity">Deity</label>
  <select id="deity" bind:value={deity}>
    {#each deityOptions as deity}
      <option value={deity.value}>{deity.label}</option>
    {/each}
  </select>
</div>
<div>
  <label for="battingAccuracy">Batting Accuracy</label>
  <input type="number" id="battingAccuracy" bind:value={battingAccuracy} />
</div>
<div>
  <label for="battingPower">Batting Power</label>
  <input type="number" id="battingPower" bind:value={battingPower} />
</div>
<div>
  <label for="throwingAccuracy">Throwing Accuracy</label>
  <input type="number" id="throwingAccuracy" bind:value={throwingAccuracy} />
</div>
<div>
  <label for="throwingPower">Throwing Power</label>
  <input type="number" id="throwingPower" bind:value={throwingPower} />
</div>
<div>
  <label for="catching">Catching</label>
  <input type="number" id="catching" bind:value={catching} />
</div>
<div>
  <label for="defense">Defense</label>
  <input type="number" id="defense" bind:value={defense} />
</div>
<div>
  <label for="piety">Piety</label>
  <input type="number" id="piety" bind:value={piety} />
</div>
<button on:click={createPlayer}>Create Player</button>
