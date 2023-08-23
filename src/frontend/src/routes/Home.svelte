<script lang="ts">
  import CreateTeam from "../components/CreateTeam.svelte";
  import MatchCardGrid from "../components/MatchCardGrid.svelte";
  import ScheduleMatch from "../components/ScheduleMatch.svelte";
  import { teamStore } from "../stores/TeamStore";

  $: teams = $teamStore;
</script>

<div class="latest-matches">
  <h1>Latest Matches</h1>
  <MatchCardGrid matchFilter={(match) => !!match.winner[0]} />
</div>

<div class="upcoming-matches">
  <h1>Upcoming Matches</h1>
  <MatchCardGrid matchFilter={(match) => !match.winner[0]} />
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
  <h1>Schedule Match</h1>
  <ScheduleMatch />
</div>
<div>
  <h1>Create Team</h1>
  <CreateTeam />
</div>

<style>
  .latest-matches {
    margin-bottom: 50px;
    text-align: center;
  }
  .upcoming-matches {
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
</style>
