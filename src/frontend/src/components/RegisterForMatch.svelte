<script lang="ts">
  import { teamStore } from "../stores/TeamStore";
  import { stadiumStore } from "../stores/StadiumStore";
  import { teamAgentFactory, type TeamConfig } from "../ic-agent/Team";
  import { playerStore } from "../stores/PlayerStore";
  import { Principal } from "@dfinity/principal";
  import DragDropList from "svelte-dragdroplist";
  import { FieldPosition } from "../models/FieldPosition";
  import type { Player } from "../models/Player";
  import PlayerPicker from "./PlayerPicker.svelte";

  $: teams = $teamStore;
  $: stadiums = $stadiumStore;

  let teamId: string;
  let stadiumId: string;
  let matchId: number;
  let teamPlayers: Player[];
  type StarterPlayer = { id: number; text: string; position: FieldPosition };
  let startingPlayers: StarterPlayer[] = [];
  let substitutes: number[] = [];

  $: {
    playerStore.subscribe((players) => {
      teamPlayers = players
        .filter((p) => p.teamId[0]?.toString() === teamId)
        .sort((a, b) => a.name.localeCompare(b.name));
    });
  }

  let register = function () {
    let config: TeamConfig = {
      pitcher: 0,
      catcher: 0,
      firstBase: 0,
      secondBase: 0,
      thirdBase: 0,
      shortStop: 0,
      leftField: 0,
      centerField: 0,
      rightField: 0,
      battingOrder: startingPlayers.map((p) => p.id),
      substitutes: substitutes,
    };
    startingPlayers.forEach((startingPlayer) => {
      switch (FieldPosition[startingPlayer.position]) {
        case FieldPosition.Pitcher:
          config.pitcher = startingPlayer.id;
          break;
        case FieldPosition.Catcher:
          config.catcher = startingPlayer.id;
          break;
        case FieldPosition.FirstBase:
          config.firstBase = startingPlayer.id;
          break;
        case FieldPosition.SecondBase:
          config.secondBase = startingPlayer.id;
          break;
        case FieldPosition.ThirdBase:
          config.thirdBase = startingPlayer.id;
          break;
        case FieldPosition.ShortStop:
          config.shortStop = startingPlayer.id;
          break;
        case FieldPosition.LeftField:
          config.leftField = startingPlayer.id;
          break;
        case FieldPosition.CenterField:
          config.centerField = startingPlayer.id;
          break;
        case FieldPosition.RightField:
          config.rightField = startingPlayer.id;
          break;
      }
    });
    teamAgentFactory(teamId)
      .registerForMatch(Principal.from(stadiumId), matchId, config)
      .then((result) => {
        console.log("Registered for match: ", result);
        teamStore.refetch();
      })
      .catch((err) => {
        console.log("Failed to make stadium: ", err);
      });
  };
</script>

<div>
  <label for="team">Team</label>
  <select id="team" bind:value={teamId}>
    {#each teams as team (team.id)}
      <option value={team.id.toString()}>{team.name}</option>
    {/each}
  </select>
</div>
{#if teamId}
  <div>
    <label for="stadium">Stadium</label>
    <select id="stadium" bind:value={stadiumId}>
      {#each stadiums as stadium (stadium.id)}
        <option value={stadium.id}>{stadium.name}</option>
      {/each}
    </select>
  </div>
  <div>
    <label for="matchId">Match Id</label>
    <input type="number" id="matchId" bind:value={matchId} />
  </div>
  <div>
    <h2>Team Lineup</h2>
    {#each Object.keys(FieldPosition) as position}
      <div>{FieldPosition[position]}</div>
      <PlayerPicker
        players={teamPlayers}
        initialPlayerId={teamPlayers.find(
          (p) => p.position == FieldPosition[position]
        )?.id}
      />
    {/each}
    <div>
      <h2>Batting Order</h2>
      <DragDropList bind:data={startingPlayers} removesItems={false} />
    </div>
  </div>
  <button on:click={register}>Register</button>
{/if}

<style>
  :global(.dragdroplist) {
    width: 200px;
  } /* entire component */
  :global(.dragdroplist > .list > div.item) {
    background-color: var(--color-bg);
    color: var(--color-text);
  } /* list item */
</style>
