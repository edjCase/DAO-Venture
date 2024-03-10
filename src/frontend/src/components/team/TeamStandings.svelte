<script lang="ts">
  import { Card } from "flowbite-svelte";
  import { CompletedSeason } from "../../ic-agent/declarations/league";

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
  <ul class="leaderboard">
    {#each teamStandings as team, index}
      <div class="card-container">
        <Card padding="none">
          <div class="team">
            <span class="team-position">{index + 1}</span>
            <img class="team-icon" src={team.logoUrl} alt={team.name} />
            <span class="team-name">{team.name}</span>
            <span class="team-score">{team.wins} - {team.losses}</span>
          </div>
        </Card>
      </div>
    {/each}
  </ul>
</div>

<style>
  .leaderboard {
    list-style: none;
    padding: 0;
  }

  .card-container {
    margin-bottom: 5px;
  }

  .team {
    display: flex;
    flex-direction: row;
    align-items: center;
    margin: 5px;
  }

  .team-position {
    width: 30px;
    margin-right: 10px;
    display: flex;
    justify-content: center;
  }

  .team-icon {
    width: 50px;
    height: 50px;
    margin-right: 10px;
  }

  .team-name {
    margin-right: 10px;
    width: 120px;
  }

  .team-score {
    font-weight: bold;
  }
</style>
