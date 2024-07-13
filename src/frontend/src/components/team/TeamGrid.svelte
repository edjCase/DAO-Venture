<script lang="ts">
  import { Link } from "svelte-routing";
  import { teamStore } from "../../stores/TeamStore";
  import { Button } from "flowbite-svelte";
  import TeamLogo from "./TeamLogo.svelte";
  import { StarSolid } from "flowbite-svelte-icons";
  import { userStore } from "../../stores/UserStore";
  import { Team } from "../../ic-agent/declarations/main";

  $: teams = $teamStore;
  $: user = $userStore;

  let associatedTeamId: bigint | undefined;
  $: {
    associatedTeamId = user?.membership[0]?.teamId[0];
  }

  let selectedTeam: Team | undefined;
  $: selectedTeam = teams && teams[0];
</script>

<div class="flex flex-col justify-between">
  <div class="pb-10">
    {#if selectedTeam}
      <div class="flex justify-center items-center">
        <div class="text-3xl text-center m-5">{selectedTeam.name}</div>
        <div>
          {#if user}
            {#if associatedTeamId !== undefined}
              {#if associatedTeamId == selectedTeam.id}
                <StarSolid size="lg" />
              {/if}
            {/if}
          {/if}
        </div>
      </div>
      <TeamLogo team={selectedTeam} size="lg" />
      <blockquote class="mx-auto mb-4 max-w-2xl">
        <div class="mt-5">
          <div class="text-lg team-info-text text-justify">
            {selectedTeam.description}
          </div>
        </div>
      </blockquote>
      <div class="flex justify-center">
        <Link to={`/teams/${selectedTeam.id.toString()}`}>
          <Button>View Team Page</Button>
        </Link>
      </div>
    {/if}
  </div>
  {#if teams !== undefined}
    <div class="flex flex-wrap justify-around">
      {#each teams as team}
        <div
          class="mb-5 {selectedTeam === team ? 'opacity-50' : ''}"
          role="button"
          tabindex="0"
          on:keydown={() => {}}
          on:click={() => (selectedTeam = team)}
        >
          <TeamLogo {team} size="md" />
        </div>
      {/each}
    </div>
  {/if}
</div>
