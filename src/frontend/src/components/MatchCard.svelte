<script lang="ts">
  import { Link } from "svelte-routing";
  import type { Match } from "../ic-agent/Stadium";
  import { teamStore } from "../stores/TeamStore";
  import { nanosecondsToDate } from "../utils/DateUtils";
  export let match: Match;

  let team1;
  let team2;
  let loading = true;
  teamStore.subscribe((teams) => {
    team1 = teams.find((team) => team.id.compareTo(match.teams[0].id) === "eq");
    team2 = teams.find((team) => team.id.compareTo(match.teams[1].id) === "eq");
    loading = !(!!team1 && !!team2);
  });
  let startDate = nanosecondsToDate(match.time);
</script>

{#if loading}
  <div>Loading...</div>
{:else}
  <div class="card">
    <Link to={`/matches/${match.id}-${match.stadiumId.toString()}`}>
      <div class="title">
        <div class="team">
          <div class="name">{team1.name}</div>
          <img class="logo" src={team1.logoUrl} alt="{team1.name} Logo" />
        </div>
        <div>vs</div>
        <div class="team">
          <div class="name">{team2.name}</div>
          <img class="logo" src={team2.logoUrl} alt="{team2.name} Logo" />
        </div>
      </div>
      <div class="content">
        {#if "inProgress" in match.state}
          <span class="score">
            <div>Live</div>
            {match.state.inProgress.team1.score} - {match.state.inProgress.team2
              .score}
          </span>
        {:else if "completed" in match.state}
          {#if "played" in match.state.completed}
            <span class="score">
              <div>Final</div>
              {match.state.completed.played.team1.score} - {match.state
                .completed.played.team2.score}
            </span>
          {/if}
        {:else}
          Upcoming
          <span class="date">{startDate.toDateString()}</span>{/if}
      </div>
    </Link>
  </div>
{/if}

<style>
  .card {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    padding: 1rem;
    border: 1px solid #ccc;
    border-radius: 5px;
    box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.3);
    margin: 1rem;
  }
  .card :global(a) {
    text-decoration: none;
    color: inherit;
  }
  .team {
    width: 150px;
    height: 150px;
    margin: 1rem;
  }
  .name {
    font-size: 2rem;
    font-weight: bold;
  }
  .logo {
    width: 75px;
    height: 75px;
  }

  .title {
    margin: 0;
    font-size: 1.5rem;
    display: flex;
    align-items: center;
  }

  .content {
    display: flex;
    flex-direction: column;
  }

  .date {
    text-align: center;
  }

  .score {
    font-size: 2rem;
    font-weight: bold;
  }
</style>
