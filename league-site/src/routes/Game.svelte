<script lang="ts">
  import PlayerGameStats from "../components/PlayerGameStats.svelte";
  import type { Game, Team } from "../types/Game";
  import Events from "../components/Events.svelte";
  import ScoreHeader from "../components/ScoreHeader.svelte";
  import { gamesStore } from "../stores/game-store";
  import { get } from "svelte/store";

  export let id;

  let game: Game = get(gamesStore).find((item) => item.id == id);
</script>

{#if game}
  <section id="game-details">
    <ScoreHeader {game} />

    <div class="team-stats-container">
      <div class="team-stats">
        <h1>{game.team1.name}</h1>
        <PlayerGameStats teamInfo={game.team1} />
      </div>
      <div class="team-stats">
        <h1>{game.team2.name}</h1>
        <PlayerGameStats teamInfo={game.team2} />
      </div>
    </div>

    <section class="game-events">
      <h2>Scoring Events</h2>
      <Events {game} />
    </section>

    <section id="projections">
      <h2>Performance vs Projections</h2>
      <div id="team1-projections">
        <p><strong>Projected Runs:</strong> 4</p>
        <p><strong>Actual Runs:</strong> 5</p>
      </div>
      <div id="team2-projections">
        <p><strong>Projected Runs:</strong> 5</p>
        <p><strong>Actual Runs:</strong> 3</p>
      </div>
    </section>

    <section id="injuries">
      <h2>Player Injuries</h2>
      <ul id="injuries-list">
        <li>Bob Johnson was injured in the 6th inning.</li>
      </ul>
    </section>

    <section id="upcoming-games">
      <h2>Upcoming Matchups</h2>
      <div id="team1-next-game">
        <p><strong>Stars vs Moonwalkers</strong> on June 15th at 7:00pm</p>
      </div>
      <div id="team2-next-game">
        <p><strong>Comets vs Sunrisers</strong> on June 16th at 8:00pm</p>
      </div>
    </section>
  </section>
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

  #projections {
    display: flex;
    justify-content: space-around;
  }

  #upcoming-games {
    display: flex;
    justify-content: space-around;
  }

  .game-events {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
</style>
