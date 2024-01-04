<script lang="ts">
  import { Card } from "flowbite-svelte";
  import { CompletedSeason } from "../models/Season";

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
  <div class="text-center text-3xl font-bold my-4">Player Awards</div>
  <div class="podium">
    <div class="place first-place">
      <img
        class="podium-image"
        src={teamStandings[0].logoUrl}
        alt={teamStandings[0].name}
      />
      1st<br />{teamStandings[0].name}<br />{teamStandings[0].wins} Wins
    </div>
    <div class="place second-place">
      <img
        class="podium-image"
        src={teamStandings[1].logoUrl}
        alt={teamStandings[1].name}
      />
      2nd<br />{teamStandings[1].name}<br />{teamStandings[1].wins} Wins
    </div>
    <div class="place third-place">
      <img
        class="podium-image"
        src={teamStandings[2].logoUrl}
        alt={teamStandings[2].name}
      />
      3rd<br />{teamStandings[2].name}<br />{teamStandings[2].wins} Wins
    </div>
  </div>

  <ul class="leaderboard">
    {#each teamStandings.slice(3) as team, index}
      <div class="card-container">
        <Card padding="none">
          <div class="team">
            <span class="team-position">{index + 4}</span>
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
  .podium {
    display: flex;
    flex-direction: row;
    align-items: flex-end;
    gap: 20px;
    margin: 20px 0;
    height: 150px;
  }

  .podium > .place {
    border-radius: 50%;
    width: 100px;
    height: 100px;
    display: flex;
    justify-content: center;
    align-items: center;
    flex-direction: column;
    text-align: center;
    padding: 10px;
    color: white;
    font-weight: bold;
    border-width: 3px;
    position: relative;
    overflow: hidden;
    position: relative;
    text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
  }

  .podium-image {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    object-fit: cover;
    z-index: -1;
    filter: brightness(50%) contrast(120%);
  }

  .first-place {
    transform: translateY(-50px); /* Adjust this value as needed */
    border-color: gold;
  }

  .second-place {
    transform: translateY(-25px); /* Adjust this value as needed */
    border-color: silver;
  }
  .third-place {
    border-color: #cd7f32;
  }

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
