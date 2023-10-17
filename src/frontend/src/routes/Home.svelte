<script lang="ts">
  import AssignPlayerToTeam from "../components/AssignPlayerToTeam.svelte";
  import CreatePlayer from "../components/CreatePlayer.svelte";
  import CreateStadium from "../components/CreateStadium.svelte";
  import CreateTeam from "../components/CreateTeam.svelte";
  import MatchCardGrid from "../components/MatchCardGrid.svelte";
  import RegisterForMatch from "../components/RegisterForMatch.svelte";
  import ScheduleMatch from "../components/ScheduleMatch.svelte";
  import { playerStore } from "../stores/PlayerStore";
  import { stadiumStore } from "../stores/StadiumStore";
  import { teamStore } from "../stores/TeamStore";

  $: teams = $teamStore;
  $: stadiums = $stadiumStore;
  $: players = $playerStore;

  let teamNameMap = {};
  teamStore.subscribe((teams) => {
    teamNameMap = teams.reduce((acc, team) => {
      acc[team.id.toString()] = team.name;
      return acc;
    }, {});
  });
</script>

<div class="live-matches">
  <h1>Live Matches</h1>
  <MatchCardGrid matchFilter={(match) => "inProgress" in match.state} />
</div>

<div class="latest-matches">
  <h1>Latest Matches</h1>
  <MatchCardGrid matchFilter={(match) => "completed" in match.state} />
</div>

<div class="upcoming-matches">
  <h1>Upcoming Matches</h1>
  <MatchCardGrid matchFilter={(match) => "notStarted" in match.state} />
</div>

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
      <li>{stadium.name}</li>
    </ul>
  {/each}
</div>

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
  <h1>Register Matches</h1>
  <RegisterForMatch />
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
            >{teamNameMap[player.teamId[0]?.toString()] || "-"}</td
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
