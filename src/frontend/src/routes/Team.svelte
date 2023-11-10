<script lang="ts">
  import { Team } from "../ic-agent/League";
  import { teamStore } from "../stores/TeamStore";
  import { playerStore } from "../stores/PlayerStore";
  import { Player } from "../models/Player";
  import { Deity } from "../models/Deity";

  export let teamIdString: string;

  let team: Team | undefined;
  teamStore.subscribe((teams) => {
    team = teams.find((team) => team.id.toString() === teamIdString);
  });

  let players: Player[] = [];
  playerStore.subscribe((playerList) => {
    players = playerList.filter(
      (player) => player.teamId.toString() === teamIdString
    );
  });
</script>

{#if team}
  <div class="team-container">
    <img class="team-logo" src={team.logoUrl} alt={`Logo of ${team.name}`} />
    <h1>{team.name}</h1>
    <h2>Division {team.divisionId}</h2>
    <div class="player-roster">
      <h3>Player Roster</h3>
      {#each players as player}
        <div class="player">
          <h4>{player.name}</h4>
          <p>Position: {player.position}</p>
          <p>Deity: {Deity[player.deity]}</p>
          <div class="skills">
            <p>Batting Accuracy: {player.skills.battingAccuracy}</p>
            <p>Batting Power: {player.skills.battingPower}</p>
            <p>Throwing Accuracy: {player.skills.throwingAccuracy}</p>
            <p>Throwing Power: {player.skills.throwingPower}</p>
            <p>Catching: {player.skills.catching}</p>
            <p>Defense: {player.skills.defense}</p>
            <p>Piety: {player.skills.piety}</p>
            <p>Speed: {player.skills.speed}</p>
          </div>
        </div>
      {/each}
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
    max-width: 200px; /* Adjust based on your actual logo size */
    height: auto;
    margin: 0 auto 1rem;
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

  .player-roster {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 1rem;
  }

  .player {
    background-color: var(--color-bg-dark);
    color: var(--color-text-light);
    padding: 1rem;
    margin: 1rem 0;
    border-radius: 4px;
    border: 1px solid var(--color-border);
    width: 100%; /* Or max-width for a specific size */
  }

  h3 {
    font-size: 1.5rem;
    margin-bottom: 1rem;
  }

  h4 {
    font-size: 1.25rem;
    margin: 0.5rem 0;
  }

  .skills {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
    gap: 0.5rem;
    margin-top: 0.5rem;
    padding: 0.5rem;
    background-color: var(
      --color-secondary
    ); /* Slightly different background for nested element */
    border-radius: 4px;
    border: 1px solid var(--color-border);
  }

  .skills p {
    font-size: 0.85rem;
    margin: 0;
  }
</style>
