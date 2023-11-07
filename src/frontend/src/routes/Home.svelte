<script lang="ts">
  import { Record } from "@dfinity/candid/lib/cjs/idl";
  import AssignPlayerToTeam from "../components/AssignPlayerToTeam.svelte";
  import CreatePlayer from "../components/CreatePlayer.svelte";
  import CreateStadium from "../components/CreateStadium.svelte";
  import CreateTeam from "../components/CreateTeam.svelte";
  import MatchGroupCard from "../components/MatchGroupCard.svelte";
  import ScheduleMatch from "../components/ScheduleSeason.svelte";
  import TempInitialize from "../components/TempInitialize.svelte";
  import { playerStore } from "../stores/PlayerStore";
  import { stadiumStore } from "../stores/StadiumStore";
  import { teamStore } from "../stores/TeamStore";
  import { matchGroupStore } from "../stores/MatchGroupStore";
  import ScheduleSeason from "../components/ScheduleSeason.svelte";

  $: teams = $teamStore;
  $: stadiums = $stadiumStore;
  $: players = $playerStore;

  let teamNameMap: Record<string, string> = {};
  teamStore.subscribe((teams) => {
    teamNameMap = teams.reduce<Record<string, string>>((acc, team) => {
      acc[team.id.toString()] = team.name;
      return acc;
    }, {});
  });

  let liveMatchGroupIds: number[] = [];
  let historicalMatchGroupIds: number[] = [];
  let upcomingMatchGroupIds: number[] = [];
  matchGroupStore.subscribe((matchGroups) => {
    liveMatchGroupIds = [];
    historicalMatchGroupIds = [];
    upcomingMatchGroupIds = [];
    for (let matchGroup of matchGroups) {
      if ("inProgress" in matchGroup.state) {
        liveMatchGroupIds.push(matchGroup.id);
      } else if ("completed" in matchGroup.state) {
        historicalMatchGroupIds.push(matchGroup.id);
      } else {
        upcomingMatchGroupIds.push(matchGroup.id);
      }
    }
  });
</script>

{#if teams.length === 0}
  <TempInitialize />
{/if}
{#if liveMatchGroupIds.length > 0}
  <div class="live-matches">
    <h1>Live</h1>
    {#each liveMatchGroupIds as liveMatchGroupId (liveMatchGroupId)}
      <MatchGroupCard matchGroupId={liveMatchGroupId} />
    {/each}
  </div>
{/if}

{#if historicalMatchGroupIds.length > 0}
  <div class="latest-matches">
    <h1>Latest</h1>
    {#each historicalMatchGroupIds as historicalMatchGroupId (historicalMatchGroupId)}
      <MatchGroupCard matchGroupId={historicalMatchGroupId} />
    {/each}
  </div>
{/if}

{#if upcomingMatchGroupIds.length > 0}
  <div class="upcoming-matches">
    <h1>Upcoming</h1>
    {#each upcomingMatchGroupIds as upcomingMatchGroupId (upcomingMatchGroupId)}
      <MatchGroupCard matchGroupId={upcomingMatchGroupId} />
    {/each}
  </div>
{/if}

<div>
  <h1>Teams</h1>
  {#each teams as team (team.id)}
    <div class="team-card">
      <div class="team-name">{team.name}</div>
      <div>
        <img class="team-logo" src={team.logoUrl} alt={team.name + " Logo"} />
      </div>
    </div>
  {/each}
</div>

<div>
  <h1>Stadiums</h1>

  {#each stadiums as stadium (stadium.id)}
    <ul>
      <li>{stadium.id}</li>
    </ul>
  {/each}
</div>

<div>
  <h1>Schedule Season</h1>
  <ScheduleSeason />
</div>

<hr style="margin-top: 400px;" />

<div>
  <h1>Schedule Match</h1>
  <ScheduleMatch />
</div>
<div>
  <h1>Create Team</h1>
  <CreateTeam />
</div>
<div>
  <h1>Create Stadium</h1>
  <CreateStadium />
</div>
<div>
  <h1>Players</h1>
  <table>
    <thead>
      <th>Name</th>
      <th>Team</th>
      <th>Position</th>
    </thead>
    <tbody>
      {#each players as player (player.id)}
        <tr>
          <td class="player-name">{player.name}</td>
          <td class="player-team"
            >{teamNameMap[player.teamId?.toString()] || "-"}</td
          >
          <td class="player-position">{player.position}</td>
        </tr>
      {/each}
    </tbody>
  </table>
</div>
<div>
  <h1>Create Player</h1>
  <CreatePlayer />
</div>
<div>
  <h1>Assign Player to Team</h1>
  <AssignPlayerToTeam />
</div>

<style>
  .latest-matches,
  .upcoming-matches,
  .live-matches {
    margin-bottom: 50px;
    text-align: center;
  }
  .team-card {
    display: inline-block;
    border: 1px solid #ccc;
    padding: 10px;
    margin: 10px;
    width: 200px;
    height: 200px;
    text-align: center;
    box-sizing: border-box;
    overflow: hidden;
  }

  .team-logo {
    width: 100px;
    height: 100px;
    margin: 10px 0;
  }

  .team-name {
    font-size: 30px;
    font-weight: bold;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    max-width: 100%;
  }
  .player-name {
    font-weight: bold;
  }
  .player-team {
    font-weight: bolder;
  }
</style>
