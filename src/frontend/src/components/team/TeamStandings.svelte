<script lang="ts">
  import { Card } from "flowbite-svelte";
  import { CompletedSeason } from "../../ic-agent/declarations/main";
  import TeamStanding from "./TeamStanding.svelte";

  export let completedSeason: CompletedSeason;

  let teamStandings = completedSeason.teams.slice().sort((a, b) => {
    if (b.wins > a.wins) return 1;
    if (b.wins < a.wins) return -1;
    if (b.losses > a.losses) return -1;
    if (b.losses < a.losses) return 1;
    return 0;
  });
</script>

<div>
  <div class="text-center text-3xl font-bold my-4">Team Standings</div>
  <ul class="list-none p-0">
    {#each teamStandings as team, index}
      <div class="mb-1">
        <Card padding="none">
          <TeamStanding
            positionIndex={index}
            teamId={team.id}
            wins={team.wins}
            losses={team.losses}
          />
        </Card>
      </div>
    {/each}
  </ul>
</div>
