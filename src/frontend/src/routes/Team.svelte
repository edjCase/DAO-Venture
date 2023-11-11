<script lang="ts">
  import { Team } from "../ic-agent/League";
  import { teamStore } from "../stores/TeamStore";
  import PlayerRoster from "../components/PlayerRoster.svelte";
  import MatchHistory from "../components/MatchHistory.svelte";

  export let teamIdString: string;

  let team: Team | undefined;
  teamStore.subscribe((teams) => {
    team = teams.find((t) => t.id.toString() === teamIdString);
  });
</script>

{#if team}
  <div class="team-container">
    <img class="team-logo" src={team.logoUrl} alt={`Logo of ${team.name}`} />
    <h1>{team.name}</h1>
    <h2>Division {team.divisionId}</h2>
    <div class="roster-history">
      <PlayerRoster teamId={team.id} />
      <div>
        <h1>Match History</h1>
        <MatchHistory teamId={team.id} />
      </div>
    </div>
  </div>
{/if}

<style>
  .team-container {
    text-align: center;
    margin: 2rem auto;
    padding: 1rem;
    background-color: var(--color-bg-light);
    border-radius: 8px;
    border: 1px solid var(--color-border);
  }

  .team-logo {
    max-width: 200px;
    height: auto;
    margin: 0 auto 1rem;
  }

  .roster-history {
    display: flex;
    flex-direction: row;
    justify-content: space-evenly;
  }

  h1 {
    font-size: 2.5rem;
    color: var(--color-text-light);
    margin-bottom: 0.5rem;
  }

  h2 {
    font-size: 1.25rem;
    color: var(--color-accent);
    margin-bottom: 1rem;
  }
</style>
