<script lang="ts">
  import { Link } from "svelte-routing";
  import { teamStore } from "../stores/TeamStore";
  import { Button, Card, Hr } from "flowbite-svelte";
  import TeamLogo from "./TeamLogo.svelte";
  $: teams = $teamStore;
</script>

<div>
  <Card
    padding="none"
    size="xl"
    class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4"
  >
    {#each teams as team}
      <figure
        class="p-8 rounded-t-lg border-b md:rounded-t-none md:rounded-tl-lg md:border-e bg-white border-gray-200 dark:bg-gray-800 dark:border-gray-700"
      >
        <div class="text-2xl font-semibold text-center">
          {team.name}
        </div>
        <div class="team-logo-container m-5">
          <Link to={`/teams/${team.id.toString()}`}>
            <TeamLogo {team} size="lg" />
          </Link>
        </div>
        <blockquote class="mx-auto mb-4 max-w-2xl">
          <div class="team-info">
            <div class="text-lg team-info-text text-justify">
              {team.description}
            </div>
          </div>
          <Hr />
          <div class="team-info">
            <div class="team-info-title">Team Motto</div>
            <div class="team-info-text">{team.motto}</div>
          </div>
          <div class="team-info inline">
            <div class="team-info-title">Managers:</div>
            <div class="team-info-text">0</div>
          </div>
          <div class="team-info inline">
            <div class="team-info-title">Championship Seasons:</div>
            <div class="team-info-text"></div>
          </div>
          <div class="team-info">
            <div class="team-info-title">Links:</div>
            <div class="team-info-text">
              <Button href={""}>Website</Button>
              <Button href={""}>Twitter</Button>
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
  }

  .team-info {
    margin: 5px 0;
    display: block;
  }
  .team-info-title {
    font-weight: bold;
    font-size: larger;
  }
  .team-info-text {
    font-weight: normal;
  }
  .team-info.inline div {
    display: inline;
  }
</style>
