<script lang="ts">
  import { Record } from "@dfinity/candid/lib/cjs/idl";
  import LastAndCurrentMatchGroups from "../components/LastAndCurrentMatchGroups.svelte";
  import { scheduleStore } from "../stores/ScheduleStore";
  import { SeasonStatus } from "../models/Season";

  let seasonStatus: SeasonStatus | undefined;

  // type SeasonSummary = {
  //   standings: Record<string, number>;
  // };

  // let seasonSummary: SeasonSummary | undefined;
  scheduleStore.subscribeStatus((status) => {
    seasonStatus = status;

    // if (seasonStatus && "completed" in seasonStatus) {
    //   seasonSummary = {
    //     standings: Object.keys(seasonStatus.completed.)
    //   }
    // }
  });
  let topPlayers = [];
</script>

<div class="content">
  {#if seasonStatus}
    {#if "notStarted" in seasonStatus}
      <div>
        <h1>Season Not Started</h1>
      </div>
    {:else if "completed" in seasonStatus}
      Season Complete

      <div>
        <h2>Team Standings</h2>
        <table class="team-standings">
          <thead>
            <tr>
              <th>Team</th>
              <th>Wins</th>
              <th>Losses</th>
            </tr>
          </thead>
          <tbody>
            {#each seasonStatus.completed.teams as team}
              <tr>
                <td>{team.name}</td>
                <td>{team.wins}</td>
                <td>{team.losses}</td>
              </tr>
            {/each}
          </tbody>
        </table>

        <h2>Top Players</h2>
        <table class="top-players">
          <thead>
            <tr>
              <th>Player</th>
              <th>Team</th>
              <th>Stat</th>
            </tr>
          </thead>
          <tbody>
            {#each topPlayers as player}
              <tr>
                <td>{player.name}</td>
                <td>{player.team}</td>
                <td>{player.stat}</td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    {:else}
      <LastAndCurrentMatchGroups />
    {/if}
  {/if}
</div>

<style>
  .team-standings,
  .top-players {
    margin: 20px 0;
  }

  table {
    width: 100%;
    border-collapse: collapse;
  }

  th,
  td {
    border: 1px solid #ddd;
    padding: 8px;
    text-align: left;
  }

  th {
    background-color: #f4f4f4;
  }
</style>
