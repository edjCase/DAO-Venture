<script lang="ts">
  import PlayerMatchStats from "../components/PlayerMatchStats.svelte";
  import Events from "../components/Events.svelte";
  import ScoreHeader from "../components/ScoreHeader.svelte";
  import { matchStore } from "../stores/MatchStore";
  import type { Match } from "../ic-agent/Stadium";
  import { teamStore } from "../stores/TeamStore";
  import type { Team } from "../ic-agent/League";

  export let id: number;

  let match: Match;
  let team1: Team;
  let team2: Team;
  let loadingTeams = true;
  matchStore.subscribe((matches) => {
    match = matches.find((item) => item.id == id);
    if (match) {
      teamStore.subscribe((teams) => {
        team1 = teams.find(
          (team) => team.id.compareTo(match.teams[0].id) === "eq"
        );
        team2 = teams.find(
          (team) => team.id.compareTo(match.teams[1].id) === "eq"
        );
        loadingTeams = false;
      });
    }
  });
</script>

{#if !loadingTeams}
  <section id="match-details">
    <ScoreHeader {match} />

    <div class="team-stats-container">
      <div class="team-stats">
        <h1>{team1.name}</h1>
        <PlayerMatchStats teamInfo={match.teams[0]} />
      </div>
      <div class="team-stats">
        <h1>{team2.name}</h1>
        <PlayerMatchStats teamInfo={match.teams[1]} />
      </div>
    </div>

    <section class="match-events">
      <h2>Events</h2>
      <Events {match} />
    </section>
  </section>
{:else}
  Loading...
{/if}

<style>
  .team-stats-container {
    display: flex;
    justify-content: space-around;
  }
  .team-stats {
    width: 40%;
  }
  h1,
  h2 {
    color: var(--text-color);
  }

  h1 {
    text-align: center;
  }

  section {
    margin-bottom: 20px;
  }

  .match-events {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
</style>
