<script lang="ts">
  import { Link } from "svelte-routing";
  import { teamStore } from "../stores/TeamStore";
  $: teams = $teamStore;
</script>

<div class="team-container">
  {#each teams as team (team.id)}
    <Link to={`/teams/${team.id.toString()}`} class="button-style">
      <div class="team-card">
        <div class="team-name">{team.name}</div>
        <div class="team-logo-container">
          <img class="team-logo" src={team.logoUrl} alt={team.name + " Logo"} />
        </div>
      </div>
    </Link>
  {/each}
</div>

<style>
  .team-container {
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
    justify-content: center;
  }
  .team-card {
    width: 100px;
    height: 100px;
  }

  .team-logo-container {
    display: flex;
    justify-content: center;
  }

  .team-logo {
    width: 75px;
    height: 75px;
  }

  .team-name {
    font-size: 20px;
    font-weight: bold;
    width: 100px;
    text-overflow: ellipsis;
    overflow: hidden;
  }
</style>
