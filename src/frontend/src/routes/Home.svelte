<script lang="ts">
  import GameCardGrid from "../components/GameCardGrid.svelte";
  import { gamesStore } from "../stores/game-store";
  import type { Game } from "../types/Game";

  let completedGamesStore: Game[];
  let upcomingGamesStore: Game[];

  // Subscribe to the store
  gamesStore.subscribe((games) => {
    // Find the item with the specific id
    completedGamesStore = games.filter((item) => item.end != null);
    upcomingGamesStore = games.filter((item) => item.end == null);
  });
</script>

<div class="latest-games">
  <h1>Latest Games</h1>
  <GameCardGrid games={completedGamesStore} />
</div>

<div class="upcoming-games">
  <h1>Upcoming Games</h1>
  <GameCardGrid games={upcomingGamesStore} />
</div>

<div />

<style>
  .latest-games {
    margin-bottom: 50px;
    text-align: center;
  }
  .upcoming-games {
    margin-bottom: 50px;
    text-align: center;
  }
</style>
