<script lang="ts">
  import { Link } from "svelte-routing";
  import { teamStore } from "../stores/TeamStore";
  import { Card } from "flowbite-svelte";
  $: teams = $teamStore;
</script>

<div>
  <Card
    padding="md"
    size="xl"
    class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4"
  >
    {#each teams as team}
      <figure
        class="flex flex-col m-4 justify-center items-center p-8 text-center bg-white rounded-lg border border-gray-200 dark:bg-gray-800 dark:border-gray-700"
      >
        <div class="team-logo-container">
          <img class="team-logo" src={team.logoUrl} alt={team.name + " Logo"} />
        </div>
        <blockquote class="mx-auto mb-4 max-w-2xl">
          <h3 class="text-lg font-semibold">
            <Link to={`/teams/${team.id.toString()}`}>
              {team.name}
            </Link>
          </h3>
          <div class="team-info">
            <div class="team-info-text">{team.description}</div>
            <div class="team-info-title">Managers:</div>
            <div>358</div>
            <div class="team-info">
              <div class="team-info-title">Championship Seasons:</div>
              <div class="team-info-text">Season 1, Season 3</div>
            </div>
            <div class="team-info">
              <div class="team-info-title">Team Motto:</div>
              <div class="team-info-text">{team.motto}</div>
            </div>
            <div class="team-info">
              <div class="team-info-title">Links:</div>
              <div class="team-info-text">
                <a href={""}>Website</a>
                <a href={""}>Twitter</a>
              </div>
            </div>
          </div>
        </blockquote>
      </figure>
    {/each}
  </Card>
</div>

<style>
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

  .team-info {
    display: flex;
    flex-direction: column;
  }
  .team-info-title {
    font-weight: bold;
  }
  .team-info-text {
    font-weight: normal;
  }
</style>
