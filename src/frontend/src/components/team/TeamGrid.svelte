<script lang="ts">
  import { Link } from "svelte-routing";
  import { teamStore } from "../../stores/TeamStore";
  import { Card } from "flowbite-svelte";
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
            <TeamLogo
              {team}
              size="lg"
              borderColor={undefined}
              popoverText={team.id.toString()}
            />
          </Link>
        </div>
        <blockquote class="mx-auto mb-4 max-w-2xl">
          <div class="team-info">
            <div class="text-lg team-info-text text-justify">
              {team.description}
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
  .team-info-text {
    font-weight: normal;
  }
</style>
