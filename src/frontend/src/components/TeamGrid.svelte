<script lang="ts">
  import { Link } from "svelte-routing";
  import { teamStore } from "../stores/TeamStore";
  $: teams = $teamStore;
</script>

<div class="team-container">
  {#each teams as team, index}
    <div class="team-card {index % 2 === 0 ? 'even' : 'odd'}">
      <Link to={`/teams/${team.id.toString()}`} class="button-style">
        <div class="link-content">
          <div class="team-logo-container">
            <img
              class="team-logo"
              src={team.logoUrl}
              alt={team.name + " Logo"}
            />
          </div>
          <div class="team-name">{team.name}</div>
        </div>
      </Link>
      <div class="team-content">
        ~~~~~~~~~~~TEAM DESCRIPTION AND FLUFF~~~~~~~~~~~
      </div>
    </div>
  {/each}
</div>

<style>
  .team-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    max-width: 800px;
  }
  .team-card {
    display: flex;
    width: 100%;
    justify-content: space-between;
    padding: 10px;
  }
  .team-card.even {
    flex-direction: row-reverse;
  }
  .team-card.odd {
    flex-direction: row;
  }
  .link-content {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 150px;
  }
  .team-logo-container {
    flex: 1;
    display: flex;
    justify-content: center;
    width: 100px;
  }
  .team-logo {
    width: 75px;
    height: 75px;
  }
  .team-name {
    flex: 2;
    font-size: 20px;
    font-weight: bold;
    text-overflow: ellipsis;
    overflow: hidden;
  }
  .team-content {
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 10px;
  }
</style>
