<script lang="ts">
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

    <section class="match-events">
      <h2>Events</h2>
      <Events {match} />
    </section>
  </section>
{:else}
  Loading...
{/if}

<style>
  section {
    margin-bottom: 20px;
  }

  .match-events {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
</style>
